import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../theme/akili_theme.dart';
import '../widgets/akili_button.dart';
import '../widgets/focusable.dart';
import '../widgets/live_badge.dart';
import 'live_stream_controller.dart';

/// Video surface + status overlays + controls.
///
/// Touch: tap to show/hide controls.
/// TV remote: any button shows controls, D-pad moves between them, OK
/// selects, Back leaves.
class LivePlayerView extends StatefulWidget {
  const LivePlayerView({
    super.key,
    required this.controller,
    this.onToggleFullscreen,
    this.isFullscreen = false,
    this.autofocus = false,
    this.tvMode = false,
  });

  final LiveStreamController controller;
  final VoidCallback? onToggleFullscreen;
  final bool isFullscreen;
  final bool autofocus;
  final bool tvMode;

  @override
  State<LivePlayerView> createState() => _LivePlayerViewState();
}

class _LivePlayerViewState extends State<LivePlayerView> {
  final FocusNode _rootFocus = FocusNode(debugLabel: 'player');
  final FocusNode _playFocus = FocusNode(debugLabel: 'player-play');
  bool _controlsVisible = false;
  Timer? _hideTimer;

  LiveStreamController get _stream => widget.controller;

  @override
  void dispose() {
    _hideTimer?.cancel();
    _rootFocus.dispose();
    _playFocus.dispose();
    super.dispose();
  }

  void _showControls({bool focusPlay = false}) {
    setState(() => _controlsVisible = true);
    if (focusPlay) _playFocus.requestFocus();
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), _hideControls);
  }

  void _hideControls() {
    if (!mounted) return;
    // Don't hide while paused: viewers need to find the play button again.
    if (_stream.status == StreamStatus.paused) return;
    if (_playFocus.hasFocus || (_rootFocus.hasFocus && !_rootFocus.hasPrimaryFocus)) {
      _rootFocus.requestFocus();
    }
    setState(() => _controlsVisible = false);
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      _hideControls();
    } else {
      _showControls();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.browserBack) {
      return KeyEventResult.ignored;
    }
    // Remote play/pause keys work any time.
    if (key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.mediaPlay ||
        key == LogicalKeyboardKey.mediaPause) {
      _stream.togglePlay();
      _showControls();
      return KeyEventResult.handled;
    }
    if (!_controlsVisible && _stream.status != StreamStatus.error) {
      // First press only wakes the controls (like any TV app).
      _showControls(focusPlay: true);
      return KeyEventResult.handled;
    }
    _showControls();
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _rootFocus,
      autofocus: widget.autofocus,
      onKeyEvent: _onKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: ColoredBox(
          color: Colors.black,
          child: ListenableBuilder(
            listenable: _stream,
            builder: (context, _) => Stack(
              fit: StackFit.expand,
              children: [
                _buildVideo(),
                _buildStatusOverlay(),
                if (_stream.isPlaying || _stream.status == StreamStatus.buffering)
                  Positioned(
                    top: widget.tvMode ? 28 : 12,
                    right: widget.tvMode ? 32 : 12,
                    child: const LiveBadge(compact: true),
                  ),
                if (_stream.isReady) _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideo() {
    final video = _stream.video;
    if (video == null || !video.value.isInitialized) {
      return const SizedBox.shrink();
    }
    final ratio = video.value.aspectRatio;
    return Center(
      child: AspectRatio(
        aspectRatio: ratio > 0 ? ratio : 16 / 9,
        child: VideoPlayer(video),
      ),
    );
  }

  Widget _buildStatusOverlay() {
    switch (_stream.status) {
      case StreamStatus.idle:
      case StreamStatus.connecting:
        return const _StatusMessage(
          spinner: true,
          title: 'Connecting to Akili TV…',
        );
      case StreamStatus.reconnecting:
        return const _StatusMessage(
          spinner: true,
          title: 'Reconnecting…',
          subtitle: 'Hang tight, the show will be right back.',
          dimBackground: true,
        );
      case StreamStatus.buffering:
        return const _StatusMessage(spinner: true, dimBackground: true);
      case StreamStatus.error:
        return _StatusMessage(
          icon: Icons.wifi_off_rounded,
          title: "We can't reach the live stream",
          subtitle: 'Check your internet connection and try again.',
          action: AkiliButton(
            label: 'Try again',
            icon: Icons.refresh_rounded,
            autofocus: true,
            onPressed: _stream.retry,
          ),
        );
      case StreamStatus.unsupported:
        return const _StatusMessage(
          icon: Icons.tv_rounded,
          title: 'Watch in the Akili TV app',
          subtitle: 'Live streaming is available on Android phones, '
              'tablets and Android TV.',
        );
      case StreamStatus.playing:
      case StreamStatus.paused:
        return const SizedBox.shrink();
    }
  }

  Widget _buildControls() {
    final paused = _stream.status == StreamStatus.paused;
    final visible = _controlsVisible || paused;
    final iconSize = widget.tvMode ? 34.0 : 26.0;

    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeFocus(
        excluding: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.transparent,
                ],
              ),
            ),
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.symmetric(
              horizontal: widget.tvMode ? 40 : 12,
              vertical: widget.tvMode ? 32 : 8,
            ),
            child: Row(
              children: [
                _ControlButton(
                  focusNode: _playFocus,
                  icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  label: paused ? 'Play' : 'Pause',
                  size: iconSize,
                  onPressed: () {
                    _stream.togglePlay();
                    _showControls();
                  },
                ),
                const SizedBox(width: 8),
                _ControlButton(
                  icon: _stream.muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  label: _stream.muted ? 'Unmute' : 'Mute',
                  size: iconSize,
                  onPressed: () {
                    _stream.toggleMute();
                    _showControls();
                  },
                ),
                const Spacer(),
                if (widget.onToggleFullscreen != null)
                  _ControlButton(
                    icon: widget.isFullscreen
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    label: widget.isFullscreen
                        ? 'Exit full screen'
                        : 'Full screen',
                    size: iconSize,
                    onPressed: widget.onToggleFullscreen!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.size,
    this.focusNode,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final double size;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Focusable(
        focusNode: focusNode,
        onActivate: onPressed,
        semanticLabel: label,
        focusScale: 1.12,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    this.spinner = false,
    this.icon,
    this.title,
    this.subtitle,
    this.action,
    this.dimBackground = false,
  });

  final bool spinner;
  final IconData? icon;
  final String? title;
  final String? subtitle;
  final Widget? action;
  final bool dimBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dimBackground ? Colors.black.withValues(alpha: 0.45) : null,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (spinner)
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AkiliColors.blue,
                ),
              ),
            if (icon != null)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AkiliColors.textSecondary, size: 26),
              ),
            if (title != null) ...[
              const SizedBox(height: 14),
              Text(title!, style: AkiliText.title, textAlign: TextAlign.center),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: AkiliText.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
