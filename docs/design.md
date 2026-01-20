# FLMusic 音乐软件设计文档

## 文档版本
- **版本**: v1.0
- **创建日期**: 2026-01-20
- **最后更新**: 2026-01-20
- **作者**: FLMusic 开发团队

---

## 目录
1. [系统架构设计](#1-系统架构设计)
2. [技术栈详细设计](#2-技术栈详细设计)
3. [数据库设计](#3-数据库设计)
4. [核心模块设计](#4-核心模块设计)
5. [UI/UX 设计规范](#5-uiux-设计规范)
6. [动画系统设计](#6-动画系统设计)
7. [性能优化方案](#7-性能优化方案)
8. [API 设计](#8-api-设计)
9. [跨平台适配方案](#9-跨平台适配方案)
10. [安全性设计](#10-安全性设计)

---

## 1. 系统架构设计

### 1.1 整体架构

采用 **Clean Architecture** 分层架构，确保代码的可维护性、可测试性和可扩展性。

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    Pages     │  │   Widgets    │  │    Themes    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓↑
┌─────────────────────────────────────────────────────────────┐
│                 Business Logic Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │State Manager │  │   Services   │  │  Use Cases   │      │
│  │(Riverpod)    │  │              │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓↑
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Models     │  │ Repositories │  │ Data Sources │      │
│  └──────────────┘  └──────────────┘  └──────┬───────┘      │
│                                              │               │
│                           ┌──────────────────┴──────┐        │
│                           ↓                         ↓        │
│                    ┌─────────────┐         ┌─────────────┐  │
│                    │Local Storage│         │Remote API   │  │
│                    │(SQLite/Hive)│         │(Dio/HTTP)   │  │
│                    └─────────────┘         └─────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓↑
┌─────────────────────────────────────────────────────────────┐
│                     Core Layer                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    Utils     │  │  Constants   │  │  Extensions  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 目录结构

```
lib/
├── main.dart                          # 应用入口
├── app.dart                           # 应用配置
│
├── core/                              # 核心层
│   ├── constants/                     # 常量定义
│   │   ├── app_constants.dart
│   │   ├── animation_constants.dart   # 动画常量（120fps相关）
│   │   └── route_constants.dart
│   ├── theme/                         # 主题配置
│   │   ├── app_theme.dart
│   │   ├── light_theme.dart
│   │   └── dark_theme.dart
│   ├── utils/                         # 工具类
│   │   ├── file_utils.dart
│   │   ├── time_utils.dart
│   │   └── format_utils.dart
│   ├── extensions/                    # 扩展方法
│   │   ├── string_extension.dart
│   │   └── duration_extension.dart
│   └── errors/                        # 错误处理
│       └── exceptions.dart
│
├── data/                              # 数据层
│   ├── models/                        # 数据模型
│   │   ├── song_model.dart
│   │   ├── playlist_model.dart
│   │   ├── artist_model.dart
│   │   └── album_model.dart
│   ├── datasources/                   # 数据源
│   │   ├── local/
│   │   │   ├── database_helper.dart
│   │   │   ├── hive_service.dart
│   │   │   └── file_scanner.dart
│   │   └── remote/
│   │       ├── music_api_client.dart
│   │       └── lyrics_api_client.dart
│   └── repositories/                  # 仓库实现
│       ├── song_repository_impl.dart
│       ├── playlist_repository_impl.dart
│       └── online_music_repository_impl.dart
│
├── domain/                            # 业务逻辑层
│   ├── entities/                      # 业务实体
│   │   ├── song.dart
│   │   ├── playlist.dart
│   │   └── artist.dart
│   ├── repositories/                  # 仓库接口
│   │   ├── song_repository.dart
│   │   └── playlist_repository.dart
│   └── usecases/                      # 用例
│       ├── play_song_usecase.dart
│       ├── search_music_usecase.dart
│       └── download_song_usecase.dart
│
├── presentation/                      # 表现层
│   ├── providers/                     # 状态管理（Riverpod）
│   │   ├── player_provider.dart
│   │   ├── playlist_provider.dart
│   │   ├── theme_provider.dart
│   │   └── animation_provider.dart    # 动画状态管理
│   ├── pages/                         # 页面
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── widgets/
│   │   ├── player/
│   │   │   ├── player_page.dart
│   │   │   └── widgets/
│   │   ├── library/
│   │   │   ├── library_page.dart
│   │   │   └── widgets/
│   │   ├── search/
│   │   │   ├── search_page.dart
│   │   │   └── widgets/
│   │   └── settings/
│   │       ├── settings_page.dart
│   │       └── widgets/
│   ├── widgets/                       # 公共组件
│   │   ├── animated_player_bar.dart   # 带动画的播放控制栏
│   │   ├── smooth_list_view.dart      # 120fps优化列表
│   │   ├── album_cover_transition.dart # 专辑封面过渡动画
│   │   └── custom_button.dart
│   └── animations/                    # 动画组件
│       ├── page_transitions.dart
│       ├── list_animations.dart
│       └── gesture_animations.dart
│
└── services/                          # 服务层
    ├── audio/                         # 音频服务
    │   ├── audio_player_service.dart
    │   ├── audio_handler.dart         # 后台播放处理
    │   └── equalizer_service.dart
    ├── storage/                       # 存储服务
    │   ├── database_service.dart
    │   └── cache_service.dart
    ├── network/                       # 网络服务
    │   └── dio_client.dart
    ├── animation/                     # 动画服务
    │   ├── animation_controller_manager.dart
    │   ├── high_refresh_rate_detector.dart # 高刷检测
    │   └── frame_scheduler.dart       # 帧调度器
    └── platform/                      # 平台特定服务
        ├── windows_service.dart
        └── android_service.dart
```

---

## 2. 技术栈详细设计

### 2.1 核心框架

#### Flutter 3.x
- **版本**: Flutter 3.16+
- **Dart 版本**: 3.2+
- **选择理由**:
  - 原生支持高刷新率（120fps）
  - 优秀的跨平台性能
  - 丰富的 UI 组件库

### 2.2 状态管理

#### Riverpod 2.x
```dart
// 示例：播放器状态管理
final playerStateProvider = StateNotifierProvider<PlayerNotifier, PlayerState>(
  (ref) => PlayerNotifier(ref.watch(audioPlayerServiceProvider)),
);

class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayerService _audioService;

  PlayerNotifier(this._audioService) : super(PlayerState.initial());

  Future<void> play(Song song) async {
    state = state.copyWith(isLoading: true);
    await _audioService.play(song);
    state = state.copyWith(
      currentSong: song,
      isPlaying: true,
      isLoading: false,
    );
  }
}
```

**选择理由**:
- 编译时安全
- 更好的性能
- 易于测试
- 支持自动依赖管理

### 2.3 音频播放

#### just_audio + audio_service
```dart
dependencies:
  just_audio: ^0.9.36
  audio_service: ^0.18.12
  audio_session: ^0.1.18
```

**功能实现**:
- 多格式支持（MP3, FLAC, WAV, AAC, OGG, APE）
- 后台播放
- 媒体通知
- 锁屏控制

### 2.4 本地存储

#### SQLite + Hive
```dart
# SQLite - 结构化数据
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3

# Hive - 轻量级缓存和设置
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

**使用场景**:
- **SQLite**: 歌曲库、播放列表、播放历史
- **Hive**: 用户设置、缓存数据、临时状态

### 2.5 网络请求

#### Dio + Retrofit
```dart
dependencies:
  dio: ^5.4.0
  retrofit: ^4.0.3
  pretty_dio_logger: ^1.3.1
```

### 2.6 动画库

#### 高性能动画方案
```dart
dependencies:
  # 官方动画包
  animations: ^2.0.8

  # 声明式动画
  flutter_animate: ^4.3.0

  # 矢量动画
  rive: ^0.12.4

  # 动画辅助
  animation_utils: ^1.0.0
```

### 2.7 性能监控

```dart
dependencies:
  # 性能监控
  flutter_performance: ^1.0.0

  # FPS监控
  fps_monitor: ^1.0.0

  # 内存分析
  memory_info: ^1.0.0
```

---

## 3. 数据库设计

### 3.1 数据库架构

使用 **SQLite** 作为主数据库，版本：`3.x`

### 3.2 表结构设计

#### 3.2.1 Songs 表（歌曲信息）

```sql
CREATE TABLE songs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,                  -- 歌曲标题
    artist TEXT,                          -- 艺术家
    album TEXT,                           -- 专辑名
    album_artist TEXT,                    -- 专辑艺术家
    file_path TEXT UNIQUE NOT NULL,       -- 文件路径
    duration INTEGER NOT NULL,            -- 时长（毫秒）
    file_size INTEGER,                    -- 文件大小（字节）
    format TEXT,                          -- 格式（mp3, flac等）
    bitrate INTEGER,                      -- 比特率
    sample_rate INTEGER,                  -- 采样率
    cover_path TEXT,                      -- 封面图片路径
    lyrics_path TEXT,                     -- 歌词文件路径
    year INTEGER,                         -- 发行年份
    genre TEXT,                           -- 流派
    track_number INTEGER,                 -- 音轨号
    disc_number INTEGER,                  -- 碟片号
    play_count INTEGER DEFAULT 0,         -- 播放次数
    is_favorite BOOLEAN DEFAULT 0,        -- 是否收藏
    rating INTEGER DEFAULT 0,             -- 评分（0-5）
    date_added INTEGER NOT NULL,          -- 添加时间（时间戳）
    last_played INTEGER,                  -- 最后播放时间
    created_at INTEGER NOT NULL,          -- 创建时间
    updated_at INTEGER NOT NULL           -- 更新时间
);

-- 索引优化
CREATE INDEX idx_songs_artist ON songs(artist);
CREATE INDEX idx_songs_album ON songs(album);
CREATE INDEX idx_songs_title ON songs(title);
CREATE INDEX idx_songs_favorite ON songs(is_favorite);
CREATE INDEX idx_songs_play_count ON songs(play_count DESC);
```

#### 3.2.2 Playlists 表（播放列表）

```sql
CREATE TABLE playlists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,                   -- 列表名称
    description TEXT,                     -- 描述
    cover_path TEXT,                      -- 封面图片
    song_count INTEGER DEFAULT 0,         -- 歌曲数量
    total_duration INTEGER DEFAULT 0,     -- 总时长（毫秒）
    is_system BOOLEAN DEFAULT 0,          -- 是否系统列表（收藏、最近播放等）
    sort_order INTEGER DEFAULT 0,         -- 排序顺序
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
```

#### 3.2.3 PlaylistSongs 表（播放列表歌曲关联）

```sql
CREATE TABLE playlist_songs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    playlist_id INTEGER NOT NULL,         -- 播放列表ID
    song_id INTEGER NOT NULL,             -- 歌曲ID
    position INTEGER NOT NULL,            -- 位置顺序
    added_at INTEGER NOT NULL,            -- 添加时间
    FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
    UNIQUE(playlist_id, song_id)
);

CREATE INDEX idx_playlist_songs_playlist ON playlist_songs(playlist_id);
CREATE INDEX idx_playlist_songs_position ON playlist_songs(playlist_id, position);
```

#### 3.2.4 PlayHistory 表（播放历史）

```sql
CREATE TABLE play_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    song_id INTEGER NOT NULL,             -- 歌曲ID
    played_at INTEGER NOT NULL,           -- 播放时间
    duration_played INTEGER,              -- 播放时长（毫秒）
    completed BOOLEAN DEFAULT 0,          -- 是否完整播放
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
);

CREATE INDEX idx_play_history_song ON play_history(song_id);
CREATE INDEX idx_play_history_time ON play_history(played_at DESC);
```

#### 3.2.5 Artists 表（艺术家）

```sql
CREATE TABLE artists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,            -- 艺术家名
    cover_path TEXT,                      -- 头像/封面
    bio TEXT,                             -- 简介
    song_count INTEGER DEFAULT 0,         -- 歌曲数量
    album_count INTEGER DEFAULT 0,        -- 专辑数量
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX idx_artists_name ON artists(name);
```

#### 3.2.6 Albums 表（专辑）

```sql
CREATE TABLE albums (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,                  -- 专辑名
    artist_id INTEGER,                    -- 艺术家ID
    artist_name TEXT,                     -- 艺术家名（冗余，方便查询）
    cover_path TEXT,                      -- 封面
    year INTEGER,                         -- 发行年份
    genre TEXT,                           -- 流派
    song_count INTEGER DEFAULT 0,         -- 歌曲数量
    total_duration INTEGER DEFAULT 0,     -- 总时长
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE SET NULL
);

CREATE INDEX idx_albums_title ON albums(title);
CREATE INDEX idx_albums_artist ON albums(artist_id);
```

#### 3.2.7 Settings 表（设置）

```sql
CREATE TABLE settings (
    key TEXT PRIMARY KEY,                 -- 设置键
    value TEXT,                           -- 设置值（JSON格式）
    type TEXT,                            -- 数据类型
    updated_at INTEGER NOT NULL
);
```

#### 3.2.8 DownloadQueue 表（下载队列）

```sql
CREATE TABLE download_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    song_name TEXT NOT NULL,              -- 歌曲名
    artist TEXT,                          -- 艺术家
    album TEXT,                           -- 专辑
    source_url TEXT NOT NULL,             -- 源地址
    quality TEXT,                         -- 音质（standard, high, lossless）
    file_path TEXT,                       -- 保存路径
    file_size INTEGER,                    -- 文件大小
    downloaded_size INTEGER DEFAULT 0,    -- 已下载大小
    status TEXT NOT NULL,                 -- 状态（pending, downloading, paused, completed, failed）
    progress REAL DEFAULT 0.0,            -- 进度（0-1）
    error_message TEXT,                   -- 错误信息
    created_at INTEGER NOT NULL,
    started_at INTEGER,
    completed_at INTEGER
);

CREATE INDEX idx_download_status ON download_queue(status);
```

### 3.3 Hive Box 设计（轻量级存储）

#### 用户设置 Box
```dart
@HiveType(typeId: 0)
class UserSettings {
  @HiveField(0)
  String theme;                    // 主题（light, dark, system）

  @HiveField(1)
  String language;                 // 语言

  @HiveField(2)
  double volume;                   // 音量

  @HiveField(3)
  String playMode;                 // 播放模式

  @HiveField(4)
  bool enableHighRefreshRate;      // 启用高刷新率

  @HiveField(5)
  int targetFrameRate;             // 目标帧率（60, 90, 120）

  @HiveField(6)
  bool enableAnimations;           // 启用动画

  @HiveField(7)
  String animationSpeed;           // 动画速度（slow, normal, fast）

  @HiveField(8)
  List<String> scanPaths;          // 扫描路径

  @HiveField(9)
  String downloadPath;             // 下载路径
}
```

#### 播放器状态 Box
```dart
@HiveType(typeId: 1)
class PlayerStateCache {
  @HiveField(0)
  int? currentSongId;              // 当前播放歌曲ID

  @HiveField(1)
  int position;                    // 播放位置（毫秒）

  @HiveField(2)
  List<int> queueIds;              // 播放队列ID列表

  @HiveField(3)
  int currentIndex;                // 当前索引

  @HiveField(4)
  String playMode;                 // 播放模式
}
```

---

## 4. 核心模块设计

### 4.1 音频播放模块

#### 4.1.1 架构设计

```dart
// 音频播放服务接口
abstract class AudioPlayerService {
  // 播放控制
  Future<void> play(Song song);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seekTo(Duration position);

  // 队列管理
  Future<void> setQueue(List<Song> songs);
  Future<void> addToQueue(Song song);
  Future<void> skipToNext();
  Future<void> skipToPrevious();

  // 音频设置
  Future<void> setVolume(double volume);
  Future<void> setPlaybackSpeed(double speed);

  // 状态流
  Stream<PlayerState> get playerStateStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
}
```

#### 4.1.2 实现示例

```dart
class AudioPlayerServiceImpl implements AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioHandler _audioHandler;

  // 播放队列
  final List<Song> _queue = [];
  int _currentIndex = 0;

  // 播放模式
  PlayMode _playMode = PlayMode.sequence;

  @override
  Future<void> play(Song song) async {
    try {
      // 设置音频源
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.file(song.filePath)),
      );

      // 开始播放
      await _audioPlayer.play();

      // 更新播放历史
      await _updatePlayHistory(song);

      // 更新通知栏
      await _audioHandler.updateNowPlaying(song);

    } catch (e) {
      throw AudioPlayException('播放失败: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;

    switch (_playMode) {
      case PlayMode.sequence:
        _currentIndex = (_currentIndex + 1) % _queue.length;
        break;
      case PlayMode.shuffle:
        _currentIndex = Random().nextInt(_queue.length);
        break;
      case PlayMode.single:
        // 单曲循环，不改变索引
        break;
    }

    await play(_queue[_currentIndex]);
  }

  // 淡入淡出效果
  Future<void> _fadeIn(Duration duration) async {
    const steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;

    for (var i = 0; i <= steps; i++) {
      await _audioPlayer.setVolume(i / steps);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }
}
```

### 4.2 音乐库管理模块

#### 4.2.1 文件扫描器

```dart
class MusicScanner {
  final DatabaseService _db;
  final MetadataExtractor _metadataExtractor;

  // 支持的音频格式
  static const supportedFormats = [
    '.mp3', '.flac', '.wav', '.aac', '.m4a', '.ogg', '.ape'
  ];

  // 扫描目录
  Future<ScanResult> scanDirectory(String path) async {
    final result = ScanResult();

    try {
      final dir = Directory(path);

      await for (var entity in dir.list(recursive: true)) {
        if (entity is File && _isSupportedFormat(entity.path)) {
          try {
            final song = await _extractSongInfo(entity);
            await _db.insertSong(song);
            result.addedCount++;
          } catch (e) {
            result.errors.add('${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      throw ScanException('扫描失败: $e');
    }

    return result;
  }

  // 提取歌曲信息
  Future<Song> _extractSongInfo(File file) async {
    final metadata = await _metadataExtractor.extract(file.path);
    final stat = await file.stat();

    return Song(
      title: metadata.title ?? _getFileNameWithoutExtension(file.path),
      artist: metadata.artist,
      album: metadata.album,
      filePath: file.path,
      duration: metadata.duration,
      fileSize: stat.size,
      format: _getFileExtension(file.path),
      bitrate: metadata.bitrate,
      sampleRate: metadata.sampleRate,
      year: metadata.year,
      genre: metadata.genre,
      trackNumber: metadata.trackNumber,
      dateAdded: DateTime.now(),
    );
  }

  bool _isSupportedFormat(String path) {
    final ext = _getFileExtension(path).toLowerCase();
    return supportedFormats.contains(ext);
  }
}
```

#### 4.2.2 播放列表管理器

```dart
class PlaylistManager {
  final DatabaseService _db;

  // 创建播放列表
  Future<Playlist> createPlaylist(String name, {String? description}) async {
    final playlist = Playlist(
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await _db.insertPlaylist(playlist);
    return playlist.copyWith(id: id);
  }

  // 添加歌曲到播放列表
  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    // 获取当前最大位置
    final maxPosition = await _db.getMaxPositionInPlaylist(playlistId);

    await _db.insertPlaylistSong(
      playlistId: playlistId,
      songId: songId,
      position: maxPosition + 1,
    );

    // 更新播放列表统计
    await _updatePlaylistStats(playlistId);
  }

  // 重新排序
  Future<void> reorderSongs(
    int playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final songs = await _db.getPlaylistSongs(playlistId);

    final song = songs.removeAt(oldIndex);
    songs.insert(newIndex, song);

    // 批量更新位置
    final batch = _db.batch();
    for (var i = 0; i < songs.length; i++) {
      batch.update(
        'playlist_songs',
        {'position': i},
        where: 'playlist_id = ? AND song_id = ?',
        whereArgs: [playlistId, songs[i].id],
      );
    }
    await batch.commit();
  }

  // 导出播放列表（M3U格式）
  Future<void> exportToM3U(int playlistId, String path) async {
    final playlist = await _db.getPlaylist(playlistId);
    final songs = await _db.getPlaylistSongs(playlistId);

    final file = File(path);
    final sink = file.openWrite();

    sink.writeln('#EXTM3U');
    sink.writeln('#PLAYLIST:${playlist.name}');

    for (var song in songs) {
      sink.writeln('#EXTINF:${song.duration.inSeconds},${song.artist} - ${song.title}');
      sink.writeln(song.filePath);
    }

    await sink.close();
  }
}
```

### 4.3 在线音乐模块

#### 4.3.1 音乐搜索服务

```dart
abstract class MusicSearchService {
  Future<List<OnlineSong>> search(String keyword);
  Future<String> getSongUrl(OnlineSong song, AudioQuality quality);
  Future<String?> getLyrics(OnlineSong song);
}

class MultiPlatformSearchService implements MusicSearchService {
  final List<MusicPlatformAPI> _platforms = [
    NeteaseCloudMusicAPI(),
    QQMusicAPI(),
    KugouMusicAPI(),
  ];

  @override
  Future<List<OnlineSong>> search(String keyword) async {
    final results = <OnlineSong>[];

    // 并发搜索多个平台
    final futures = _platforms.map((api) => api.search(keyword));
    final responses = await Future.wait(futures);

    for (var response in responses) {
      results.addAll(response);
    }

    // 去重和排序
    return _deduplicateAndSort(results);
  }

  List<OnlineSong> _deduplicateAndSort(List<OnlineSong> songs) {
    final seen = <String>{};
    final unique = <OnlineSong>[];

    for (var song in songs) {
      final key = '${song.title}_${song.artist}'.toLowerCase();
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(song);
      }
    }

    // 按相关度排序
    unique.sort((a, b) => b.relevance.compareTo(a.relevance));

    return unique;
  }
}
```

#### 4.3.2 下载管理器

```dart
class DownloadManager {
  final Dio _dio;
  final DatabaseService _db;

  // 最大并发下载数
  static const maxConcurrentDownloads = 3;

  // 当前下载任务
  final Map<int, CancelToken> _downloadTasks = {};

  // 添加到下载队列
  Future<int> addToQueue(
    OnlineSong song,
    AudioQuality quality,
  ) async {
    final downloadItem = DownloadItem(
      songName: song.title,
      artist: song.artist,
      album: song.album,
      sourceUrl: await _getMusicUrl(song, quality),
      quality: quality.name,
      status: DownloadStatus.pending,
      createdAt: DateTime.now(),
    );

    return await _db.insertDownloadItem(downloadItem);
  }

  // 开始下载
  Future<void> startDownload(int itemId) async {
    final item = await _db.getDownloadItem(itemId);
    if (item == null) return;

    final cancelToken = CancelToken();
    _downloadTasks[itemId] = cancelToken;

    try {
      await _db.updateDownloadStatus(itemId, DownloadStatus.downloading);

      final savePath = await _generateSavePath(item);

      await _dio.download(
        item.sourceUrl,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final progress = total > 0 ? received / total : 0.0;
          _updateDownloadProgress(itemId, progress, received);
        },
      );

      // 下载完成，添加到本地库
      await _addToLocalLibrary(savePath, item);
      await _db.updateDownloadStatus(itemId, DownloadStatus.completed);

    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        await _db.updateDownloadStatus(itemId, DownloadStatus.paused);
      } else {
        await _db.updateDownloadStatus(
          itemId,
          DownloadStatus.failed,
          errorMessage: e.message,
        );
      }
    } finally {
      _downloadTasks.remove(itemId);
    }
  }

  // 暂停下载
  Future<void> pauseDownload(int itemId) async {
    _downloadTasks[itemId]?.cancel('用户暂停');
  }

  // 断点续传
  Future<void> resumeDownload(int itemId) async {
    // 实现断点续传逻辑
    // 使用 Range 请求头
  }
}
```

### 4.4 歌词模块

#### 4.4.1 歌词解析器

```dart
class LyricsParser {
  // 解析LRC格式歌词
  List<LyricLine> parseLRC(String lrcContent) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (var line in lrcContent.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!.padRight(3, '0'));
        final text = match.group(4)!.trim();

        final timestamp = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );

        lines.add(LyricLine(timestamp: timestamp, text: text));
      }
    }

    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return lines;
  }
}
```

#### 4.4.2 歌词显示控制器

```dart
class LyricsController extends ChangeNotifier {
  List<LyricLine> _lines = [];
  int _currentLineIndex = 0;
  Duration _currentPosition = Duration.zero;

  // 更新播放位置
  void updatePosition(Duration position) {
    _currentPosition = position;

    // 查找当前歌词行
    for (var i = 0; i < _lines.length; i++) {
      if (i == _lines.length - 1 || position < _lines[i + 1].timestamp) {
        if (_currentLineIndex != i) {
          _currentLineIndex = i;
          notifyListeners();
        }
        break;
      }
    }
  }

  // 获取当前行
  LyricLine? get currentLine =>
    _lines.isNotEmpty ? _lines[_currentLineIndex] : null;

  // 获取下一行
  LyricLine? get nextLine =>
    _currentLineIndex < _lines.length - 1
      ? _lines[_currentLineIndex + 1]
      : null;
}
```

---

## 5. UI/UX 设计规范

### 5.1 设计原则

1. **简洁明了**: 界面简洁，避免冗余元素
2. **一致性**: 统一的设计语言和交互模式
3. **响应性**: 即时的视觉反馈
4. **流畅性**: 所有动画保持 120fps
5. **无障碍**: 支持无障碍功能

### 5.2 色彩系统

#### 5.2.1 浅色主题

```dart
class LightThemeColors {
  // 主色
  static const primary = Color(0xFF6200EE);
  static const primaryVariant = Color(0xFF3700B3);
  static const secondary = Color(0xFF03DAC6);
  static const secondaryVariant = Color(0xFF018786);

  // 背景色
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F5F5);
  static const surfaceVariant = Color(0xFFE0E0E0);

  // 文本色
  static const onBackground = Color(0xFF000000);
  static const onSurface = Color(0xFF000000);
  static const onPrimary = Color(0xFFFFFFFF);

  // 功能色
  static const error = Color(0xFFB00020);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);
}
```

#### 5.2.2 深色主题

```dart
class DarkThemeColors {
  static const primary = Color(0xFFBB86FC);
  static const primaryVariant = Color(0xFF3700B3);
  static const secondary = Color(0xFF03DAC6);
  static const secondaryVariant = Color(0xFF03DAC6);

  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const surfaceVariant = Color(0xFF2C2C2C);

  static const onBackground = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFFFFFFFF);
  static const onPrimary = Color(0xFF000000);

  static const error = Color(0xFFCF6679);
  static const success = Color(0xFF81C784);
  static const warning = Color(0xFFFFB74D);
  static const info = Color(0xFF64B5F6);
}
```

### 5.3 字体系统

```dart
class AppTextStyles {
  // 标题
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // 正文
  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // 说明文字
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
}
```

### 5.4 间距系统

```dart
class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
```

### 5.5 圆角系统

```dart
class AppBorderRadius {
  static const small = 4.0;
  static const medium = 8.0;
  static const large = 16.0;
  static const xlarge = 24.0;
  static const circle = 9999.0;
}
```

### 5.6 阴影系统

```dart
class AppShadows {
  static const small = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const medium = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const large = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}
```

---

## 6. 动画系统设计

### 6.1 高刷新率支持策略

#### 6.1.1 刷新率检测

```dart
class RefreshRateDetector {
  static Future<double> detectRefreshRate() async {
    // Android 平台
    if (Platform.isAndroid) {
      final display = await FlutterView.of(context).display;
      return display.refreshRate;
    }

    // Windows 平台
    if (Platform.isWindows) {
      // 通过 Windows API 获取刷新率
      return await _getWindowsRefreshRate();
    }

    // 默认 60Hz
    return 60.0;
  }

  static int getTargetFrameRate(double refreshRate) {
    if (refreshRate >= 120) return 120;
    if (refreshRate >= 90) return 90;
    return 60;
  }
}
```

#### 6.1.2 帧率配置

```dart
class AnimationConfig {
  // 目标帧率
  static int targetFPS = 120;

  // 帧时间（毫秒）
  static double get frameTime => 1000 / targetFPS;

  // 是否启用高刷新率
  static bool highRefreshRateEnabled = true;

  // 根据设备性能自动调整
  static Future<void> autoConfigureFrameRate() async {
    final refreshRate = await RefreshRateDetector.detectRefreshRate();
    final devicePerformance = await _assessDevicePerformance();

    if (devicePerformance == PerformanceLevel.high) {
      targetFPS = refreshRate.toInt();
    } else if (devicePerformance == PerformanceLevel.medium) {
      targetFPS = min(90, refreshRate.toInt());
    } else {
      targetFPS = 60;
    }
  }
}
```

### 6.2 动画时长规范

```dart
class AnimationDurations {
  // 极快动画（微交互）
  static const instant = Duration(milliseconds: 100);

  // 快速动画（按钮反馈）
  static const fast = Duration(milliseconds: 150);

  // 标准动画（页面切换）
  static const standard = Duration(milliseconds: 250);

  // 中等动画（复杂过渡）
  static const medium = Duration(milliseconds: 350);

  // 慢速动画（强调效果）
  static const slow = Duration(milliseconds: 500);
}
```

### 6.3 动画曲线

```dart
class AppCurves {
  // 标准缓动
  static const standard = Curves.easeInOut;

  // 强调进入
  static const emphasized = Cubic(0.4, 0.0, 0.2, 1.0);

  // 快速退出
  static const fastOutSlowIn = Curves.fastOutSlowIn;

  // 线性
  static const linear = Curves.linear;

  // 弹性效果
  static const bounce = Curves.bounceOut;

  // 自定义：120fps 优化曲线
  static const smooth120 = Cubic(0.42, 0.0, 0.58, 1.0);
}
```

### 6.4 页面过渡动画

#### 6.4.1 共享元素过渡

```dart
class HeroTransitionPage extends StatelessWidget {
  final Song song;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'album-cover-${song.id}',
      flightShuttleBuilder: (
        flightContext,
        animation,
        direction,
        fromContext,
        toContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Tween<double>(begin: 8, end: 0)
                    .animate(CurvedAnimation(
                      parent: animation,
                      curve: AppCurves.smooth120,
                    ))
                    .value,
                ),
              ),
              child: child,
            );
          },
          child: Image.file(File(song.coverPath ?? '')),
        );
      },
      child: AlbumCoverWidget(song: song),
    );
  }
}
```

#### 6.4.2 页面切换动画

```dart
class CustomPageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Curve curve;

  CustomPageRoute({
    required this.child,
    this.curve = AppCurves.smooth120,
  });

  @override
  Duration get transitionDuration => AnimationDurations.standard;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 滑动 + 淡入效果
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
```

### 6.5 列表动画

#### 6.5.1 高性能列表

```dart
class SmoothListView extends StatelessWidget {
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // 120fps 优化
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      // 缓存范围
      cacheExtent: 500,
      // 项目构建器
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          key: ValueKey(songs[index].id),
          index: index,
          child: SongTile(song: songs[index]),
        );
      },
    );
  }
}
```

#### 6.5.2 列表项进入动画

```dart
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AnimationDurations.fast,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.smooth120),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.smooth120),
    );

    // 交错动画
    Future.delayed(
      Duration(milliseconds: widget.index * 50),
      () => _controller.forward(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 6.6 播放器控制动画

#### 6.6.1 播放按钮动画

```dart
class AnimatedPlayButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  State<AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<AnimatedPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.fast,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(AnimatedPlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      widget.isPlaying ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: _controller,
        size: 48,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
```

#### 6.6.2 进度条动画

```dart
class SmoothProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final Duration duration;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            final value = details.localPosition.dx / constraints.maxWidth;
            onChanged?.call(value.clamp(0.0, 1.0));
          },
          onHorizontalDragUpdate: (details) {
            final value = details.localPosition.dx / constraints.maxWidth;
            onChanged?.call(value.clamp(0.0, 1.0));
          },
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(constraints.maxWidth, 4),
              painter: ProgressBarPainter(
                progress: progress,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  final double progress;
  final Color color;

  ProgressBarPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // 背景
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset.zero,
      Offset(size.width, 0),
      bgPaint,
    );

    // 进度
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset.zero,
      Offset(size.width * progress, 0),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
```

### 6.7 专辑封面动画

```dart
class AlbumCoverTransition extends StatefulWidget {
  final Song song;

  @override
  State<AlbumCoverTransition> createState() => _AlbumCoverTransitionState();
}

class _AlbumCoverTransitionState extends State<AlbumCoverTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AnimationDurations.medium,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: AppCurves.smooth120),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.smooth120),
    );
  }

  @override
  void didUpdateWidget(AlbumCoverTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.song.id != oldWidget.song.id) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Image.file(
          File(widget.song.coverPath ?? ''),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
```

### 6.8 歌词滚动动画

```dart
class AnimatedLyricsView extends StatefulWidget {
  final List<LyricLine> lyrics;
  final int currentIndex;

  @override
  State<AnimatedLyricsView> createState() => _AnimatedLyricsViewState();
}

class _AnimatedLyricsViewState extends State<AnimatedLyricsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(AnimatedLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _scrollToCurrentLine();
    }
  }

  void _scrollToCurrentLine() {
    if (!_scrollController.hasClients) return;

    const itemHeight = 60.0;
    final targetOffset = widget.currentIndex * itemHeight - 120;

    _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: AnimationDurations.standard,
      curve: AppCurves.smooth120,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.lyrics.length,
      itemBuilder: (context, index) {
        final isActive = index == widget.currentIndex;

        return AnimatedDefaultTextStyle(
          duration: AnimationDurations.fast,
          curve: AppCurves.smooth120,
          style: TextStyle(
            fontSize: isActive ? 20 : 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
            child: Text(
              widget.lyrics[index].text,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
```

---

## 7. 性能优化方案

### 7.1 120FPS 优化策略

#### 7.1.1 渲染优化

```dart
class PerformanceOptimizations {
  // 1. 使用 RepaintBoundary 隔离重绘区域
  static Widget isolateRepaint(Widget child) {
    return RepaintBoundary(child: child);
  }

  // 2. 使用 const 构造函数
  static const example = Text('使用 const 避免重建');

  // 3. 缓存复杂计算结果
  static final _cache = <String, dynamic>{};

  static T getCached<T>(String key, T Function() compute) {
    if (_cache.containsKey(key)) {
      return _cache[key] as T;
    }
    final result = compute();
    _cache[key] = result;
    return result;
  }

  // 4. 避免在 build 方法中创建对象
  // Bad
  Widget badExample() {
    return Container(
      decoration: BoxDecoration(  // 每次都创建新对象
        color: Colors.red,
      ),
    );
  }

  // Good
  static final _decoration = BoxDecoration(color: Colors.red);
  Widget goodExample() {
    return Container(decoration: _decoration);
  }
}
```

#### 7.1.2 列表性能优化

```dart
class OptimizedListView extends StatelessWidget {
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // 1. 使用 builder 构造器（懒加载）
      itemCount: songs.length,

      // 2. 设置合适的缓存范围
      cacheExtent: 500,

      // 3. 添加 item key 提高重排序性能
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey(songs[index].id),
          child: _buildSongTile(songs[index]),
        );
      },

      // 4. 使用高性能物理引擎
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
    );
  }

  Widget _buildSongTile(Song song) {
    // 使用 const 和缓存
    return const SongTile();  // 如果可能的话
  }
}
```

#### 7.1.3 图片加载优化

```dart
class OptimizedImageLoader {
  static Widget loadImage(String path, {double? width, double? height}) {
    return Image.file(
      File(path),
      width: width,
      height: height,
      // 1. 使用缓存
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      // 2. 选择合适的滤镜质量
      filterQuality: FilterQuality.medium,
      // 3. 错误处理
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image);
      },
      // 4. 占位符
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: AnimationDurations.fast,
          curve: AppCurves.smooth120,
          child: child,
        );
      },
    );
  }
}
```

#### 7.1.4 动画性能监控

```dart
class AnimationPerformanceMonitor {
  static final _fpsData = <double>[];
  static Timer? _monitorTimer;

  static void startMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkFrameRate(),
    );
  }

  static void _checkFrameRate() {
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (var timing in timings) {
        final fps = 1000000 / timing.totalSpan.inMicroseconds;
        _fpsData.add(fps);

        // 如果帧率持续低于目标值，降级
        if (_shouldDowngrade()) {
          _downgradAnimations();
        }
      }
    });
  }

  static bool _shouldDowngrade() {
    if (_fpsData.length < 10) return false;

    final recentFps = _fpsData.sublist(_fpsData.length - 10);
    final averageFps = recentFps.reduce((a, b) => a + b) / recentFps.length;

    return averageFps < AnimationConfig.targetFPS * 0.8;
  }

  static void _downgradAnimations() {
    // 降低动画质量
    AnimationConfig.targetFPS = max(60, AnimationConfig.targetFPS - 30);
    print('动画性能降级至 ${AnimationConfig.targetFPS} FPS');
  }
}
```

### 7.2 内存优化

```dart
class MemoryOptimization {
  // 1. 图片缓存管理
  static void configurImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  }

  // 2. 及时释放资源
  static void disposeResources(List<Disposable> resources) {
    for (var resource in resources) {
      resource.dispose();
    }
    resources.clear();
  }

  // 3. 弱引用缓存
  static final _weakCache = <String, WeakReference<Object>>{};

  static T? getWeakCached<T extends Object>(String key) {
    return _weakCache[key]?.target as T?;
  }

  static void setWeakCached<T extends Object>(String key, T value) {
    _weakCache[key] = WeakReference(value);
  }
}
```

### 7.3 启动优化

```dart
class AppInitializer {
  static Future<void> initialize() async {
    // 1. 延迟非关键初始化
    await _criticalInit();

    // 2. 后台初始化非关键服务
    unawaited(_nonCriticalInit());
  }

  static Future<void> _criticalInit() async {
    // 必须的初始化
    await Hive.initFlutter();
    await _initDatabase();
    await _loadUserSettings();
  }

  static Future<void> _nonCriticalInit() async {
    // 可以延迟的初始化
    await Future.delayed(const Duration(seconds: 1));
    await _scanMusicLibrary();
    await _syncCloudData();
  }
}
```

### 7.4 网络优化

```dart
class NetworkOptimization {
  static Dio createOptimizedDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      // 1. 启用 HTTP/2
      headers: {'Connection': 'keep-alive'},
    ));

    // 2. 添加缓存拦截器
    dio.interceptors.add(DioCacheInterceptor(
      options: CacheOptions(
        store: MemCacheStore(),
        maxStale: const Duration(days: 7),
      ),
    ));

    // 3. 添加重试拦截器
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));

    return dio;
  }
}
```

---

## 8. API 设计

### 8.1 RESTful API 规范

#### 8.1.1 音乐搜索 API

```dart
abstract class MusicAPI {
  // 搜索歌曲
  @GET('/search/songs')
  Future<SearchResponse> searchSongs(
    @Query('keyword') String keyword,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  // 获取歌曲详情
  @GET('/songs/{id}')
  Future<SongDetail> getSongDetail(@Path('id') String songId);

  // 获取播放地址
  @GET('/songs/{id}/url')
  Future<SongUrlResponse> getSongUrl(
    @Path('id') String songId,
    @Query('quality') String quality,
  );

  // 获取歌词
  @GET('/songs/{id}/lyrics')
  Future<LyricsResponse> getLyrics(@Path('id') String songId);
}
```

#### 8.1.2 响应格式

```dart
// 统一响应格式
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  bool get isSuccess => code == 200;
}

// 搜索响应
class SearchResponse {
  final List<OnlineSong> songs;
  final int total;
  final int page;
  final int pageSize;

  SearchResponse({
    required this.songs,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      songs: (json['songs'] as List)
          .map((e) => OnlineSong.fromJson(e))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
    );
  }
}
```

### 8.2 本地 API 设计

#### 8.2.1 数据库访问层

```dart
abstract class SongDAO {
  Future<int> insert(Song song);
  Future<List<Song>> getAll();
  Future<Song?> getById(int id);
  Future<int> update(Song song);
  Future<int> delete(int id);
  Future<List<Song>> search(String keyword);
  Future<List<Song>> getByArtist(String artist);
  Future<List<Song>> getByAlbum(String album);
  Future<List<Song>> getFavorites();
  Future<List<Song>> getRecentlyPlayed({int limit = 50});
  Future<List<Song>> getMostPlayed({int limit = 50});
}
```

---

## 9. 跨平台适配方案

### 9.1 平台检测

```dart
class PlatformHelper {
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isWindows => Platform.isWindows;
  static bool get isAndroid => Platform.isAndroid;

  // 平台特定代码执行
  static T platform<T>({
    required T Function() windows,
    required T Function() android,
    T Function()? fallback,
  }) {
    if (Platform.isWindows) return windows();
    if (Platform.isAndroid) return android();
    return fallback?.call() ?? windows();
  }
}
```

### 9.2 响应式布局

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

### 9.3 Windows 平台特性

```dart
class WindowsFeatures {
  // 系统托盘
  static Future<void> initSystemTray() async {
    await SystemTray.init();
    SystemTray.setTooltip('FLMusic');
    SystemTray.setContextMenu([
      MenuItem(label: '播放/暂停', onClicked: _togglePlay),
      MenuItem(label: '下一曲', onClicked: _next),
      MenuItem.separator(),
      MenuItem(label: '退出', onClicked: _exit),
    ]);
  }

  // 全局快捷键
  static Future<void> registerHotkeys() async {
    await HotKey.register(
      HotKey(KeyCode.space, modifiers: [KeyModifier.control]),
      callback: _togglePlay,
    );

    await HotKey.register(
      HotKey(KeyCode.arrowRight, modifiers: [KeyModifier.control]),
      callback: _next,
    );
  }

  // 桌面歌词
  static Future<void> showDesktopLyrics(String lyrics) async {
    await DesktopWindow.create(
      title: 'Lyrics',
      width: 800,
      height: 100,
      alwaysOnTop: true,
      transparent: true,
      child: LyricsOverlay(lyrics: lyrics),
    );
  }
}
```

### 9.4 Android 平台特性

```dart
class AndroidFeatures {
  // 后台播放服务
  static Future<void> startForegroundService() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'music_playback',
        channelName: '音乐播放',
        channelImportance: NotificationChannelImportance.LOW,
      ),
    );
  }

  // 锁屏控制
  static Future<void> setupMediaSession(Song song) async {
    await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelName: 'FLMusic',
        androidShowNotificationBadge: true,
      ),
    );

    await AudioService.setMediaItem(MediaItem(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist,
      album: song.album,
      artUri: Uri.file(song.coverPath ?? ''),
    ));
  }

  // 桌面小部件
  static Future<void> updateWidget(Song? currentSong) async {
    await HomeWidget.saveWidgetData<String>(
      'song_title',
      currentSong?.title ?? 'No song playing',
    );
    await HomeWidget.saveWidgetData<String>(
      'artist',
      currentSong?.artist ?? '',
    );
    await HomeWidget.updateWidget(
      name: 'MusicWidgetProvider',
      iOSName: 'MusicWidget',
    );
  }
}
```

---

## 10. 安全性设计

### 10.1 数据加密

```dart
class EncryptionService {
  static final _encrypter = Encrypter(AES(
    Key.fromSecureRandom(32),
    mode: AESMode.gcm,
  ));

  // 加密敏感数据
  static String encrypt(String plainText) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  // 解密
  static String decrypt(String encryptedText) {
    final parts = encryptedText.split(':');
    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);
    return _encrypter.decrypt(encrypted, iv: iv);
  }
}
```

### 10.2 网络安全

```dart
class NetworkSecurity {
  // HTTPS 证书固定
  static Dio createSecureDio() {
    final dio = Dio();

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
        client.badCertificateCallback = (cert, host, port) {
          // 验证证书
          return _verifyCertificate(cert, host);
        };
        return client;
      };

    return dio;
  }

  static bool _verifyCertificate(X509Certificate cert, String host) {
    // 实现证书验证逻辑
    return true;
  }
}
```

### 10.3 权限管理

```dart
class PermissionManager {
  // 请求存储权限
  static Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // 请求通知权限
  static Future<bool> requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
```

---

## 附录

### A. 性能指标

| 指标 | 目标值 | 测量方法 |
|------|--------|----------|
| 应用启动时间 | < 3秒 | 从点击图标到首屏显示 |
| 帧率 | 120 FPS | FPS监控工具 |
| 内存占用（空闲） | Windows < 200MB, Android < 150MB | 任务管理器 |
| 列表滚动流畅度 | 120 FPS | 无掉帧 |
| 页面切换延迟 | < 250ms | 手动测试 |

### B. 开发工具

- **IDE**: VS Code / Android Studio
- **调试**: Flutter DevTools
- **性能分析**: Flutter Performance
- **代码检查**: dart analyze, flutter analyze
- **格式化**: dart format

### C. 测试策略

- **单元测试**: 核心业务逻辑
- **Widget 测试**: UI 组件
- **集成测试**: 端到端流程
- **性能测试**: FPS、内存、启动时间
- **兼容性测试**: 不同设备和系统版本

---

## 更新日志

- **2026-01-20**: 初始版本设计文档创建
  - 完成系统架构设计
  - 完成数据库设计
  - 完成核心模块设计
  - 完成 120fps 动画系统设计
  - 完成性能优化方案
  - 完成跨平台适配方案
