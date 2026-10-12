import 'package:flutter/material.dart';

import '../services/device_service.dart';
import '../theme/akili_theme.dart';
import '../widgets/focusable.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _features = [
    (
      Icons.family_restroom_rounded,
      'Family first',
      'A safe viewing space for children, teens and parents to enjoy '
          'together. Every show is curated to be fun, educational and '
          'family-friendly.',
    ),
    (
      Icons.auto_awesome_rounded,
      'Stories that inspire',
      'From animated adventures to real-life African stories, Akili TV '
          'entertains while encouraging creativity, learning and '
          'imagination.',
    ),
    (
      Icons.public_rounded,
      'Made for Kenya',
      'Showcasing African culture, education and storytelling, and '
          'connecting families across the country.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tv = DeviceService.isTv;
    final scale = tv ? 1.15 : 1.0;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AkiliColors.backdrop),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? (tv ? 64 : 40) : 22,
                vertical: tv ? 40 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/logo.png', height: 48 * scale),
                      const SizedBox(height: 28),
                      Text(
                        'More fun, more learning,\nfor everyone.',
                        style: AkiliText.scaled(AkiliText.headline, scale),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Text(
                          "Akili TV is Kenya's family channel: free, safe and "
                          'educational entertainment straight to your home. '
                          'Formerly Akili Kids!, the channel became Akili TV '
                          'to serve the whole family, with top-rated kids’ '
                          'shows and programmes everyone can watch together.',
                          style: AkiliText.scaled(AkiliText.body, scale),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text('Why Akili TV?',
                          style: AkiliText.scaled(AkiliText.title, scale)),
                      const SizedBox(height: 14),
                      if (wide)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < _features.length; i++) ...[
                                if (i > 0) const SizedBox(width: 14),
                                Expanded(
                                  child: _FeatureCard(
                                    feature: _features[i],
                                    scale: scale,
                                    autofocus: tv && i == 0,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      else
                        for (final f in _features) ...[
                          _FeatureCard(feature: f, scale: scale),
                          const SizedBox(height: 12),
                        ],
                      const SizedBox(height: 36),
                      Center(
                        child: Text(
                          '© Akili Network',
                          style: AkiliText.scaled(AkiliText.caption, scale),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.feature,
    required this.scale,
    this.autofocus = false,
  });

  final (IconData, String, String) feature;
  final double scale;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final (icon, title, body) = feature;
    return Focusable(
      autofocus: autofocus,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AkiliColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AkiliColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AkiliColors.brandGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 14),
            Text(title,
                style: AkiliText.scaled(
                    AkiliText.title.copyWith(fontSize: 16), scale)),
            const SizedBox(height: 6),
            Text(body, style: AkiliText.scaled(AkiliText.bodySmall, scale)),
          ],
        ),
      ),
    );
  }
}
