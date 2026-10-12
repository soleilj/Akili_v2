import 'package:flutter/material.dart';

import '../services/device_service.dart';
import '../theme/akili_theme.dart';
import 'about_screen.dart';
import 'fullscreen_player_screen.dart';
import 'home_screen.dart';
import 'live_screen.dart';

/// App frame: bottom tab bar on phones, side rail on tablets and TVs.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  static const _destinations = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.live_tv_outlined, Icons.live_tv_rounded, 'Live'),
    (Icons.info_outline_rounded, Icons.info_rounded, 'About'),
  ];

  void _select(int index) => setState(() => _index = index);

  void _watchLive() {
    if (DeviceService.isTv) {
      // On TV, "Watch Live" goes straight to full-screen playback.
      FullscreenPlayerScreen.open(context);
    } else {
      _select(1);
    }
  }

  Widget _page() {
    switch (_index) {
      case 1:
        return const LiveScreen();
      case 2:
        return const AboutScreen();
      default:
        return HomeScreen(onWatchLive: _watchLive);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Back from Live/About returns Home instead of closing the app.
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = DeviceService.isTv ||
              (constraints.maxWidth >= 760 && constraints.maxHeight >= 500);
          return useRail ? _buildWithRail() : _buildWithBottomBar();
        },
      ),
    );
  }

  Widget _buildWithBottomBar() {
    return Scaffold(
      body: _page(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          for (final (icon, selectedIcon, label) in _destinations)
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selectedIcon),
              label: label,
            ),
        ],
      ),
    );
  }

  Widget _buildWithRail() {
    final tv = DeviceService.isTv;
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              minWidth: tv ? 104 : 88,
              groupAlignment: 0,
              leading: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Image.asset(
                  'assets/images/icon_mark.png',
                  width: tv ? 52 : 44,
                ),
              ),
              destinations: [
                for (final (icon, selectedIcon, label) in _destinations)
                  NavigationRailDestination(
                    icon: Icon(icon, size: tv ? 30 : 24),
                    selectedIcon: Icon(selectedIcon, size: tv ? 30 : 24),
                    label: Text(label),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: AkiliColors.outline),
          Expanded(child: _page()),
        ],
      ),
    );
  }
}
