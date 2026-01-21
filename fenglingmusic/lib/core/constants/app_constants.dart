/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Application info
  static const String appName = '风铃音乐';
  static const String appVersion = '1.0.0';
  static const String appDescription = '现代化跨平台音乐播放器，支持 120fps 顺滑动画';

  // Database
  static const String databaseName = 'fenglingmusic.db';
  static const int databaseVersion = 1;

  // Hive boxes
  static const String settingsBox = 'settings';
  static const String playerStateBox = 'player_state';

  // Supported audio formats
  static const List<String> supportedAudioFormats = [
    'mp3',
    'flac',
    'wav',
    'aac',
    'm4a',
    'ogg',
    'opus',
  ];

  // Default values
  static const int defaultVolume = 80;
  static const int defaultFadeInDuration = 500; // milliseconds
  static const int defaultFadeOutDuration = 500; // milliseconds

  // Cache settings
  static const int maxCoverCacheSize = 100 * 1024 * 1024; // 100 MB
  static const int maxAudioCacheSize = 500 * 1024 * 1024; // 500 MB
  static const Duration cacheExpiration = Duration(days: 7);

  // Network
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Download
  static const int maxConcurrentDownloads = 3;
  static const int downloadChunkSize = 1024 * 1024; // 1 MB

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxSearchResults = 100;

  // UI
  static const double defaultCoverArtSize = 200.0;
  static const double defaultThumbnailSize = 50.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;

  // Lyrics
  static const Duration lyricsScrollDuration = Duration(milliseconds: 300);
  static const Duration autoScrollBackDelay = Duration(seconds: 3);

  // Playlist limits
  static const int maxPlaylistNameLength = 100;
  static const int maxSongsInPlaylist = 10000;
}
