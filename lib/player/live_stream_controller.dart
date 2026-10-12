import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

import '../config/app_config.dart';
import '../services/device_service.dart';

enum StreamStatus {
  /// Not started, or stopped because the app went to the background.
  idle,
  connecting,
  playing,
  buffering,
  reconnecting,
  paused,

  /// Gave up after several automatic retries; the viewer can retry by hand.
  error,

  /// Platform can't play HLS (e.g. the web build in Chrome).
  unsupported,
}

/// Owns the video player and keeps the live stream healthy:
/// - tries each stream URL in [AppConfig.streamUrls], falling back on failure
/// - reconnects automatically with backoff (2s, 4s, 8s, 16s)
/// - restarts if the stream stalls while buffering
/// - stops the stream when the app is backgrounded (saves viewers' data)
///   and resumes when it comes back
/// - keeps the screen awake only while the stream is active
class LiveStreamController extends ChangeNotifier with WidgetsBindingObserver {
  LiveStreamController() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const int maxAutoRetries = 4;
  static const Duration initTimeout = Duration(seconds: 20);
  static const Duration stallTimeout = Duration(seconds: 25);

  /// After a pause longer than this, resuming jumps back to the live edge.
  static const Duration livePauseLimit = Duration(seconds: 30);

  VideoPlayerController? _video;
  StreamStatus _status = StreamStatus.idle;
  bool _muted = false;
  bool _userPaused = false;
  bool _suspended = false;
  bool _disposed = false;
  int _attempt = 0;
  int _urlIndex = 0;
  int _generation = 0;
  DateTime? _pausedAt;
  Timer? _retryTimer;
  Timer? _stallTimer;

  VideoPlayerController? get video => _video;
  StreamStatus get status => _status;
  bool get muted => _muted;
  bool get isReady => _video?.value.isInitialized ?? false;
  bool get isPlaying => _status == StreamStatus.playing;

  /// True when the screen should show a spinner.
  bool get isBusy =>
      _status == StreamStatus.idle ||
      _status == StreamStatus.connecting ||
      _status == StreamStatus.buffering ||
      _status == StreamStatus.reconnecting;

  // ---------------------------------------------------------------------------
  // Lifecycle of the stream
  // ---------------------------------------------------------------------------

  Future<void> start() async {
    if (_disposed) return;
    if (kIsWeb) {
      _setStatus(StreamStatus.unsupported);
      return;
    }

    _retryTimer?.cancel();
    _stallTimer?.cancel();
    final gen = ++_generation;
    _setStatus(
        _attempt == 0 ? StreamStatus.connecting : StreamStatus.reconnecting);

    await _teardownVideo();
    if (gen != _generation || _disposed) return;

    final urls = AppConfig.streamUrls;
    final url = urls[_urlIndex % urls.length];
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      formatHint: VideoFormat.hls,
    );
    _video = controller;

    try {
      await controller.initialize().timeout(initTimeout);
      // A newer start() or dispose() happened while we were connecting; that
      // call has already cleaned this controller up.
      if (gen != _generation || _disposed) return;

      controller.addListener(_onVideoChanged);
      await controller.setVolume(_muted ? 0 : 1);
      if (!_userPaused) await controller.play();
      if (gen != _generation || _disposed) return;

      _attempt = 0;
      _setStatus(_userPaused ? StreamStatus.paused : StreamStatus.playing);
    } catch (error) {
      if (gen != _generation || _disposed) return;
      debugPrint('Akili stream: could not connect to $url ($error)');
      _scheduleRetry(tryNextUrl: true);
    }
  }

  /// Manual "Try again" from the error screen.
  void retry() {
    _retryTimer?.cancel();
    _attempt = 0;
    _urlIndex = 0;
    _userPaused = false;
    start();
  }

  Future<void> togglePlay() async {
    if (_status == StreamStatus.error) {
      retry();
      return;
    }
    final c = _video;
    if (c == null || !c.value.isInitialized) return;

    if (c.value.isPlaying) {
      _userPaused = true;
      _pausedAt = DateTime.now();
      await c.pause();
      _setStatus(StreamStatus.paused);
      return;
    }

    _userPaused = false;
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt != null &&
        DateTime.now().difference(pausedAt) > livePauseLimit) {
      // Too far behind live: reconnect so viewers see what's on now.
      _attempt = 0;
      await start();
      return;
    }
    await c.play();
    _setStatus(StreamStatus.playing);
  }

  void toggleMute() {
    _muted = !_muted;
    _video?.setVolume(_muted ? 0 : 1);
    if (!_disposed) notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Health monitoring
  // ---------------------------------------------------------------------------

  void _onVideoChanged() {
    final c = _video;
    if (c == null || _disposed) return;
    final value = c.value;

    if (value.hasError) {
      debugPrint('Akili stream: playback error (${value.errorDescription})');
      _scheduleRetry(tryNextUrl: false);
      return;
    }

    if (_status == StreamStatus.paused ||
        _status == StreamStatus.reconnecting ||
        _status == StreamStatus.connecting) {
      return;
    }

    if (value.isBuffering) {
      if (_status != StreamStatus.buffering) {
        _setStatus(StreamStatus.buffering);
        _stallTimer?.cancel();
        _stallTimer = Timer(stallTimeout, () {
          if (_status == StreamStatus.buffering) {
            debugPrint('Akili stream: stalled, reconnecting');
            _scheduleRetry(tryNextUrl: false, immediate: true);
          }
        });
      }
    } else if (value.isPlaying && _status != StreamStatus.playing) {
      _stallTimer?.cancel();
      _setStatus(StreamStatus.playing);
    }
  }

  void _scheduleRetry({required bool tryNextUrl, bool immediate = false}) {
    if (_disposed) return;
    if (_retryTimer?.isActive ?? false) return;
    _stallTimer?.cancel();

    if (tryNextUrl) _urlIndex++;

    if (_attempt >= maxAutoRetries) {
      ++_generation;
      _teardownVideo();
      _setStatus(StreamStatus.error);
      return;
    }

    _attempt++;
    _setStatus(StreamStatus.reconnecting);
    final delay =
        immediate ? Duration.zero : Duration(seconds: 2 << (_attempt - 1));
    _retryTimer = Timer(delay, () => start());
  }

  // ---------------------------------------------------------------------------
  // App going to / coming back from the background
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;

    final goingAway = state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused;

    if (goingAway && !_suspended && _status != StreamStatus.unsupported) {
      _suspended = true;
      _retryTimer?.cancel();
      _stallTimer?.cancel();
      ++_generation;
      _teardownVideo();
      _setStatus(StreamStatus.idle);
    } else if (state == AppLifecycleState.resumed && _suspended) {
      _suspended = false;
      _attempt = 0;
      _userPaused = false;
      start();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setStatus(StreamStatus next) {
    if (_disposed || next == _status) return;
    _status = next;
    DeviceService.setKeepScreenOn(next == StreamStatus.playing ||
        next == StreamStatus.buffering ||
        next == StreamStatus.connecting ||
        next == StreamStatus.reconnecting);
    notifyListeners();
  }

  Future<void> _teardownVideo() async {
    final c = _video;
    _video = null;
    if (c == null) return;
    c.removeListener(_onVideoChanged);
    try {
      await c.dispose();
    } catch (_) {
      // Already disposed.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    WidgetsBinding.instance.removeObserver(this);
    _retryTimer?.cancel();
    _stallTimer?.cancel();
    _teardownVideo();
    DeviceService.setKeepScreenOn(false);
    super.dispose();
  }
}
