import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/app_config.dart';
import 'screens/shell_screen.dart';
import 'services/device_service.dart';
import 'theme/akili_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeviceService.init();

  if (DeviceService.isTv) {
    // TVs are driven by a remote: always show where focus is.
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AkiliApp());
}

class AkiliApp extends StatelessWidget {
  const AkiliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AkiliTheme.theme,
      // The centre "OK" button on TV remotes sends the `select` key.
      shortcuts: <ShortcutActivator, Intent>{
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      home: const ShellScreen(),
    );
  }
}
