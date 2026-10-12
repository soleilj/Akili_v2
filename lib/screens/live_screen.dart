import 'package:flutter/material.dart';

import '../player/live_player_view.dart';
import '../player/live_stream_controller.dart';
import '../services/device_service.dart';
import '../theme/akili_theme.dart';
import '../widgets/focusable.dart';
import 'fullscreen_player_screen.dart';

/// The "Live" tab: player plus programme info.
class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final LiveStreamController _controller = LiveStreamController();

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen() =>
      FullscreenPlayerScreen.open(context, controller: _controller);

  @override
  Widget build(BuildContext context) {
    final tv = DeviceService.isTv;
    final player = ClipRRect(
      borderRadius: BorderRadius.circular(tv ? 20 : 0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: LivePlayerView(
          controller: _controller,
          onToggleFullscreen: _openFullscreen,
          autofocus: tv,
          tvMode: tv,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760 &&
            constraints.maxHeight >= 420;

        if (!wide) {
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                player,
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                    children: [_LiveInfo(controller: _controller)],
                  ),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tv ? 48 : 28,
              vertical: tv ? 40 : 24,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: player),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: _LiveInfo(controller: _controller, tv: tv),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveInfo extends StatelessWidget {
  const _LiveInfo({required this.controller, this.tv = false});

  final LiveStreamController controller;
  final bool tv;

  String _statusText(StreamStatus status) {
    switch (status) {
      case StreamStatus.playing:
        return 'Streaming now';
      case StreamStatus.paused:
        return 'Paused';
      case StreamStatus.buffering:
        return 'Buffering…';
      case StreamStatus.reconnecting:
        return 'Reconnecting…';
      case StreamStatus.error:
        return 'Stream unavailable';
      case StreamStatus.unsupported:
        return 'Available in the Android app';
      case StreamStatus.idle:
      case StreamStatus.connecting:
        return 'Connecting…';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = tv ? 1.15 : 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Akili TV Live',
            style: AkiliText.scaled(AkiliText.headline, scale)),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final live = controller.isPlaying;
            return Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: live ? AkiliColors.live : AkiliColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _statusText(controller.status),
                  style: AkiliText.scaled(AkiliText.caption, scale),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Text(
          'Edutainment for the whole family, streaming 24/7. '
          'The same channel you know from free-to-air TV.',
          style: AkiliText.scaled(AkiliText.body, scale),
        ),
        const SizedBox(height: 22),
        _InfoTile(
          icon: Icons.schedule_rounded,
          title: 'On all day, every day',
          body: 'Tune in anytime, 24 hours a day.',
          scale: scale,
        ),
        const SizedBox(height: 12),
        _InfoTile(
          icon: Icons.family_restroom_rounded,
          title: 'Made for families',
          body: 'Kid-safe shows curated for children, teens and parents.',
          scale: scale,
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.body,
    this.scale = 1.0,
  });

  final IconData icon;
  final String title;
  final String body;
  final double scale;

  @override
  Widget build(BuildContext context) {
    // Focusable so TV remotes can scroll down to it.
    return Focusable(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AkiliColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AkiliColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AkiliColors.blue.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AkiliColors.blue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AkiliText.scaled(
                          AkiliText.title.copyWith(fontSize: 15), scale)),
                  const SizedBox(height: 3),
                  Text(body,
                      style: AkiliText.scaled(AkiliText.bodySmall, scale)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
