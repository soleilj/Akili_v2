import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:akili_tv/main.dart';
import 'package:akili_tv/screens/about_screen.dart';
import 'package:akili_tv/screens/home_screen.dart';
import 'package:akili_tv/theme/akili_theme.dart';

// Note: these use pump() rather than pumpAndSettle() because the LIVE badge
// pulses forever.

void main() {
  testWidgets('Phone: app opens on Home with a Watch Live button',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AkiliApp());
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Watch Live'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Phone: About tab opens', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AkiliApp());
    await tester.pump();
    await tester.tap(find.text('About'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AboutScreen), findsOneWidget);
    expect(find.text('Why Akili TV?'), findsOneWidget);
  });

  testWidgets('Tablet / TV size: side rail layout without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AkiliApp());
    await tester.pump();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Watch Live'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Brand fonts are wired to the registered font families', () {
    expect(AkiliText.display.fontFamily, 'PublicSans');
    expect(AkiliText.body.fontFamily, 'Inter');
  });
}
