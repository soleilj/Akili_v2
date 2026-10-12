import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Talks to the small amount of native Android code in MainActivity.kt.
class DeviceService {
  DeviceService._();

  static const MethodChannel _channel = MethodChannel('com.akilitv.app/device');

  /// True on Android TV, Google TV and Fire TV.
  static bool isTv = false;

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> init() async {
    if (!_isAndroid) return;
    try {
      isTv = await _channel.invokeMethod<bool>('isTelevision') ?? false;
    } catch (_) {
      isTv = false;
    }
  }

  /// Stops the screen from dimming or sleeping while the stream plays.
  static Future<void> setKeepScreenOn(bool on) async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setKeepScreenOn', {'on': on});
    } catch (_) {
      // Not fatal: the worst case is the screen dims during playback.
    }
  }
}
