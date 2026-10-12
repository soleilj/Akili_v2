/// App-wide configuration. Change values here, not inside screens.
class AppConfig {
  AppConfig._();

  static const String appName = 'Akili TV';

  /// Optional override at build time:
  ///   flutter build apk --dart-define=STREAM_URL=https://.../playlist.m3u8
  static const String _streamUrlOverride = String.fromEnvironment('STREAM_URL');

  /// Live stream sources, tried in order.
  ///
  /// 1. The adaptive "master" playlist: the player picks the best quality the
  ///    viewer's connection can handle (important on mobile data).
  /// 2. The fixed ~2.5 Mbps rendition the app originally used, as a fallback.
  ///
  /// TODO(akili): confirm the master playlist URL with the CDN provider. If the
  /// CDN issues a different URL, put it first here.
  static List<String> get streamUrls => [
        if (_streamUrlOverride.isNotEmpty) _streamUrlOverride,
        'https://m6.livecdn.io/akilikids.co.ke/akilikids.smil/playlist.m3u8',
        'https://m6.livecdn.io/akilikids.co.ke/akilikids.smil/chunklist_w88071026_b2528000_slke.m3u8',
      ];
}
