import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../player/live_player_view.dart';
import '../player/live_stream_controller.dart';
import '../services/device_service.dart';

/// Edge-to-edge playback. Used for phone full screen, and as the main
/// watching screen on TV.
///
/// Pass an existing [controller] to keep playing the same stream (no
/// reconnect); leave it null and this screen runs its own.
class FullscreenPlayerScreen extends StatefulWidget {
  const FullscreenPlayerScreen({super.key, this.controller});

  final LiveStreamController? controller;

  static Future<void> open(
    BuildContext context, {
    LiveStreamController? controller,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) =>
            FullscreenPlayerScreen(controller: controller),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<FullscreenPlayerScreen> createState() => _FullscreenPlayerScreenState();
}

class _FullscreenPlayerScreenState extends State<FullscreenPlayerScreen> {
  late final LiveStreamController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? LiveStreamController();
    if (_ownsController) _controller.start();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!DeviceService.isTv) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!DeviceService.isTv) {
      // Empty list = back to the app's normal rotation behaviour.
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[]);
    }
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tv = DeviceService.isTv;
    return Scaffold(
      backgroundColor: Colors.black,
      body: LivePlayerView(
        controller: _controller,
        isFullscreen: true,
        autofocus: true,
        tvMode: tv,
        // On TV the remote's Back button exits; no on-screen button needed.
        onToggleFullscreen: tv ? null : () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
