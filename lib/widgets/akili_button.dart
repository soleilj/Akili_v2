import 'package:flutter/material.dart';

import '../theme/akili_theme.dart';
import 'focusable.dart';

enum AkiliButtonStyle { primary, secondary }

/// The one button used across the app, on phone and TV.
class AkiliButton extends StatelessWidget {
  const AkiliButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AkiliButtonStyle.primary,
    this.autofocus = false,
    this.focusNode,
    this.expand = false,
    this.large = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AkiliButtonStyle style;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool expand;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final primary = style == AkiliButtonStyle.primary;
    final height = large ? 60.0 : 52.0;
    final radius = BorderRadius.circular(height / 2);

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: large ? 28 : 24),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: large
              ? AkiliText.scaled(AkiliText.button, 1.15)
              : AkiliText.button,
        ),
      ],
    );

    return Focusable(
      onActivate: onPressed,
      autofocus: autofocus,
      focusNode: focusNode,
      borderRadius: radius,
      semanticLabel: label,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: large ? 36 : 28),
        decoration: BoxDecoration(
          gradient: primary ? AkiliColors.brandGradient : null,
          color: primary ? null : Colors.white.withValues(alpha: 0.10),
          borderRadius: radius,
          border: primary ? null : Border.all(color: AkiliColors.outline),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: AkiliColors.blueDeep.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: content,
      ),
    );
  }
}
