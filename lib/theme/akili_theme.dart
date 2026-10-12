import 'package:flutter/material.dart';

/// The Akili TV design system: every color and text style lives here, so the
/// phone and TV apps look like one product.
class AkiliColors {
  AkiliColors._();

  // Backgrounds, from the deep navy of the Akili "A" mark.
  static const Color background = Color(0xFF050D2B);
  static const Color surface = Color(0xFF0B1A47);
  static const Color surfaceHigh = Color(0xFF13265E);
  static const Color outline = Color(0x26FFFFFF);

  // Brand.
  static const Color blue = Color(0xFF197FE6);
  static const Color blueDeep = Color(0xFF074CFF);
  static const Color live = Color(0xFFFF3B3B);

  // Text.
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xC7FFFFFF);
  static const Color textMuted = Color(0x8AFFFFFF);

  // Focus ring for TV remotes and keyboards.
  static const Color focus = Color(0xFFFFFFFF);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [blue, blueDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backdrop = LinearGradient(
    colors: [Color(0xFF0A2470), background],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    stops: [0.0, 0.65],
  );
}

class AkiliText {
  AkiliText._();

  static const String _heading = 'PublicSans';
  static const String _body = 'Inter';

  /// Both font files are "variable" fonts, so the weight is set twice: once
  /// for Flutter's layout and once on the font's weight axis.
  static TextStyle _style(
    String family,
    double size,
    int weight, {
    Color color = AkiliColors.text,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [FontVariation('wght', weight.toDouble())],
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static final TextStyle display =
      _style(_heading, 44, 800, height: 1.05, letterSpacing: -1.2);
  static final TextStyle headline =
      _style(_heading, 28, 800, height: 1.15, letterSpacing: -0.6);
  static final TextStyle title = _style(_heading, 19, 700, height: 1.25);
  static final TextStyle body = _style(_body, 15, 400,
      color: AkiliColors.textSecondary, height: 1.55);
  static final TextStyle bodySmall = _style(_body, 13, 400,
      color: AkiliColors.textSecondary, height: 1.5);
  static final TextStyle button = _style(_body, 16, 700, letterSpacing: 0.2);
  static final TextStyle label = _style(_body, 12, 700, letterSpacing: 1.4);
  static final TextStyle caption =
      _style(_body, 12, 500, color: AkiliColors.textMuted);

  /// Larger type for TV, read from across the room.
  static TextStyle scaled(TextStyle style, double factor) =>
      style.copyWith(fontSize: (style.fontSize ?? 14) * factor);
}

class AkiliTheme {
  AkiliTheme._();

  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AkiliColors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AkiliColors.blue,
      onPrimary: Colors.white,
      surface: AkiliColors.background,
      onSurface: AkiliColors.text,
      error: AkiliColors.live,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AkiliColors.background,
      fontFamily: 'Inter',
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AkiliColors.surface,
        indicatorColor: AkiliColors.blue.withValues(alpha: 0.22),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AkiliText.caption.copyWith(
            color: selected ? AkiliColors.text : AkiliColors.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AkiliColors.text : AkiliColors.textMuted,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AkiliColors.surface,
        indicatorColor: AkiliColors.blue.withValues(alpha: 0.30),
        selectedIconTheme: const IconThemeData(color: AkiliColors.text),
        unselectedIconTheme: const IconThemeData(color: AkiliColors.textMuted),
        selectedLabelTextStyle:
            AkiliText.caption.copyWith(color: AkiliColors.text),
        unselectedLabelTextStyle: AkiliText.caption,
      ),
    );
  }
}
