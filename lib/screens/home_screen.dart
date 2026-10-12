import 'package:flutter/material.dart';

import '../services/device_service.dart';
import '../theme/akili_theme.dart';
import '../widgets/akili_button.dart';
import '../widgets/live_badge.dart';

/// Landing page. Phones get a stacked layout; tablets and TVs get a
/// side-by-side "hero" layout. Same content, same styling.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onWatchLive});

  final VoidCallback onWatchLive;

  static const double wideBreakpoint = 760;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AkiliColors.backdrop),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Phones in landscape are wide but short: keep them on the
          // scrolling layout so nothing gets cut off.
          final wide = constraints.maxWidth >= wideBreakpoint &&
              constraints.maxHeight >= 500;
          return wide
              ? _WideHome(onWatchLive: onWatchLive)
              : _NarrowHome(onWatchLive: onWatchLive);
        },
      ),
    );
  }
}

class _NarrowHome extends StatelessWidget {
  const _NarrowHome({required this.onWatchLive});

  final VoidCallback onWatchLive;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        children: [
          Center(child: Image.asset('assets/images/logo.png', height: 44)),
          const SizedBox(height: 20),
          const _HeroImage(height: 230),
          const SizedBox(height: 22),
          const Align(
            alignment: Alignment.centerLeft,
            child: LiveBadge(label: 'LIVE NOW'),
          ),
          const SizedBox(height: 14),
          Text('Watch Akili TV live', style: AkiliText.display),
          const SizedBox(height: 10),
          Text(
            'Fun, safe, educational shows for the whole family. '
            'Free, 24 hours a day.',
            style: AkiliText.body,
          ),
          const SizedBox(height: 24),
          AkiliButton(
            label: 'Watch Live',
            icon: Icons.play_arrow_rounded,
            expand: true,
            onPressed: onWatchLive,
          ),
          const SizedBox(height: 24),
          const _HighlightChips(),
        ],
      ),
    );
  }
}

class _WideHome extends StatelessWidget {
  const _WideHome({required this.onWatchLive});

  final VoidCallback onWatchLive;

  @override
  Widget build(BuildContext context) {
    final tv = DeviceService.isTv;
    final scale = tv ? 1.15 : 1.0;

    return SafeArea(
      child: Padding(
        // TVs crop the edges of the picture, so keep content inside the
        // standard 5% "overscan safe" margin.
        padding: EdgeInsets.symmetric(
          horizontal: tv ? 64 : 40,
          vertical: tv ? 40 : 28,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 56 * scale),
                  const Spacer(),
                  const LiveBadge(label: 'LIVE NOW'),
                  const SizedBox(height: 16),
                  Text(
                    'Watch Akili TV live',
                    style: AkiliText.scaled(AkiliText.display, scale * 1.1),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      'Fun, safe, educational shows for the whole family. '
                      'Free, 24 hours a day.',
                      style: AkiliText.scaled(AkiliText.body, scale * 1.1),
                    ),
                  ),
                  const SizedBox(height: 30),
                  AkiliButton(
                    label: 'Watch Live',
                    icon: Icons.play_arrow_rounded,
                    large: true,
                    autofocus: true,
                    onPressed: onWatchLive,
                  ),
                  const SizedBox(height: 28),
                  const _HighlightChips(),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            const Expanded(flex: 6, child: _HeroImage()),
          ],
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    final image = Stack(
      alignment: Alignment.center,
      children: [
        // Soft brand-blue glow behind the family.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AkiliColors.blue.withValues(alpha: 0.55),
                  AkiliColors.blue.withValues(alpha: 0.0),
                ],
                radius: 0.7,
              ),
            ),
          ),
        ),
        Image.asset(
          'assets/images/hero.png',
          fit: BoxFit.contain,
          semanticLabel: 'A family watching Akili TV together',
        ),
      ],
    );
    return height == null ? image : SizedBox(height: height, child: image);
  }
}

class _HighlightChips extends StatelessWidget {
  const _HighlightChips();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.child_care_rounded, 'Kid-safe'),
      (Icons.school_rounded, 'Educational'),
      (Icons.schedule_rounded, '24/7'),
      (Icons.money_off_rounded, 'Free'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (icon, label) in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AkiliColors.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: AkiliColors.textSecondary),
                const SizedBox(width: 6),
                Text(label, style: AkiliText.caption),
              ],
            ),
          ),
      ],
    );
  }
}
