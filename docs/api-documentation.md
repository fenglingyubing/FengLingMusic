# 风铃音乐 API 文档

## 版本信息
- **版本**: v1.0.0
- **更新日期**: 2026-01-21

---

## 目录
1. [架构概览](#1-架构概览)
2. [核心服务 API](#2-核心服务-api)
3. [数据模型](#3-数据模型)
4. [状态管理](#4-状态管理)
5. [平台特定 API](#5-平台特定-api)
6. [扩展指南](#6-扩展指南)

---

## 1. 架构概览

### 1.1 分层架构

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│  - Pages, Widgets, Controllers      │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│      Application Layer              │
│  - Riverpod Providers, Use Cases    │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│       Domain Layer                  │
│  - Entities, Repositories(I)        │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│      Infrastructure Layer           │
│  - Services, Repositories(Impl)     │
│  - Data Sources, Network            │
└─────────────────────────────────────┘
```

### 1.2 主要模块

- **Audio**: 音频播放服务
- **Storage**: 本地存储和音乐扫描
- **Network**: 网络请求和在线服务
- **Lyrics**: 歌词解析和显示
- **Playlist**: 播放列表管理
- **Platform**: 平台特定功能（Windows/Android）

---

## 2. 核心服务 API

### 2.1 音频播放服务 (AudioPlayerService)

#### 接口定义
```dart
abstract class AudioPlayerService {
  // 播放控制
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);

  // 队列管理
  Future<void> setPlaylist(List<Song> songs, {int initialIndex = 0});
  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> skipToIndex(int index);

  // 音量和设置
  Future<void> setVolume(double volume);
  Future<void> setPlaybackMode(PlaybackMode mode);

  // 状态流
  Stream<PlayerState> get playerStateStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<Song?> get currentSongStream;
  Stream<List<Song>> get playlistStream;
}
```

#### 使用示例
```dart
// 获取服务实例
final audioService = ref.watch(audioPlayerServiceProvider);

// 播放歌曲
await audioService.setPlaylist([song1, song2, song3]);
await audioService.play();

// 监听播放状态
audioService.playerStateStream.listen((state) {
  if (state == PlayerState.playing) {
    print('正在播放');
  }
});

// 跳转到指定位置
await audioService.seek(Duration(seconds: 30));

// 设置播放模式
await audioService.setPlaybackMode(PlaybackMode.shuffle);
```

#### 播放模式
```dart
enum PlaybackMode {
  sequential,  // 顺序播放
  loop,        // 列表循环
  shuffle,     // 随机播放
  repeatOne,   // 单曲循环
}
```

#### 播放状态
```dart
enum PlayerState {
  idle,      // 空闲
  loading,   // 加载中
  playing,   // 播放中
  paused,    // 暂停
  stopped,   // 停止
  error,     // 错误
}
```

---

### 2.2 音乐扫描服务 (MusicScanner)

#### 接口定义
```dart
class MusicScanner {
  /// 扫描指定路径
  Future<ScanResult> scanDirectory(
    String path, {
    bool recursive = true,
    void Function(ScanProgress)? onProgress,
  });

  /// 扫描多个路径
  Future<List<ScanResult>> scanDirectories(List<String> paths);

  /// 取消扫描
  void cancelScan();
}
```

#### 使用示例
```dart
final scanner = MusicScanner(songRepository: songRepo);

// 扫描音乐文件夹
final result = await scanner.scanDirectory(
  '/path/to/music',
  recursive: true,
  onProgress: (progress) {
    print('扫描进度: ${progress.percentage}%');
    print('已找到: ${progress.foundCount} 首歌曲');
  },
);

print('扫描完成: ${result.totalSongs} 首歌曲');
print('新增: ${result.addedSongs} 首');
print('更新: ${result.updatedSongs} 首');
```

#### 扫描进度
```dart
class ScanProgress {
  final int scannedFiles;
  final int totalFiles;
  final int foundCount;
  final String currentFile;

  double get percentage => totalFiles > 0
    ? (scannedFiles / totalFiles) * 100
    : 0;
}
```

---

### 2.3 歌词服务 (LyricsService)

#### 接口定义
```dart
class LyricsService {
  /// 获取歌词（优先本地，然后在线）
  Future<Lyrics?> getLyrics(Song song);

  /// 从在线获取歌词
  Future<Lyrics?> fetchOnlineLyrics(String title, String artist);

  /// 从本地文件读取歌词
  Future<Lyrics?> loadLocalLyrics(String songPath);

  /// 保存歌词到本地
  Future<void> saveLyrics(Song song, Lyrics lyrics);
}
```

#### 使用示例
```dart
final lyricsService = ref.watch(lyricsServiceProvider);

// 获取歌词
final lyrics = await lyricsService.getLyrics(song);

if (lyrics != null) {
  // 根据播放位置获取当前歌词行
  final currentLine = lyrics.getLineAt(position);
  print('当前歌词: ${currentLine?.text}');

  // 获取所有歌词行
  for (final line in lyrics.lines) {
    print('[${line.timestamp}] ${line.text}');
    if (line.translation != null) {
      print('  翻译: ${line.translation}');
    }
  }
}
```

#### 歌词模型
```dart
class Lyrics {
  final List<LyricLine> lines;
  final String? title;
  final String? artist;
  final String? album;

  /// 根据时间戳获取歌词行
  LyricLine? getLineAt(Duration position);

  /// 获取指定索引的歌词行
  LyricLine? getLineByIndex(int index);
}

class LyricLine {
  final Duration timestamp;
  final String text;
  final String? translation;
}
```

---

### 2.4 播放列表管理 (PlaylistManager)

#### 接口定义
```dart
class PlaylistManager {
  /// 创建播放列表
  Future<Playlist> createPlaylist(String name, {String? description});

  /// 删除播放列表
  Future<void> deletePlaylist(String playlistId);

  /// 添加歌曲到播放列表
  Future<void> addSongsToPlaylist(String playlistId, List<String> songIds);

  /// 从播放列表移除歌曲
  Future<void> removeSongsFromPlaylist(String playlistId, List<String> songIds);

  /// 重新排序播放列表歌曲
  Future<void> reorderPlaylistSongs(String playlistId, int oldIndex, int newIndex);

  /// 导出播放列表为 M3U
  Future<File> exportToM3U(String playlistId, String outputPath);

  /// 从 M3U 导入播放列表
  Future<Playlist> importFromM3U(String m3uPath);
}
```

#### 使用示例
```dart
final playlistManager = ref.watch(playlistManagerProvider);

// 创建播放列表
final playlist = await playlistManager.createPlaylist(
  'My Favorites',
  description: '我最喜欢的歌曲',
);

// 添加歌曲
await playlistManager.addSongsToPlaylist(
  playlist.id,
  [song1.id, song2.id, song3.id],
);

// 导出为 M3U
final file = await playlistManager.exportToM3U(
  playlist.id,
  '/path/to/export/playlist.m3u',
);

// 从 M3U 导入
final importedPlaylist = await playlistManager.importFromM3U(
  '/path/to/playlist.m3u',
);
```

---

### 2.5 在线搜索服务 (MultiPlatformSearchService)

#### 接口定义
```dart
class MultiPlatformSearchService {
  /// 搜索在线音乐
  Future<SearchResult> search(
    String keyword, {
    MusicPlatform? platform,
    int page = 1,
    int limit = 20,
  });

  /// 获取歌曲播放地址
  Future<String?> getPlayUrl(OnlineSong song, {AudioQuality quality});

  /// 获取歌词
  Future<Lyrics?> getLyrics(OnlineSong song);
}
```

#### 使用示例
```dart
final searchService = ref.watch(multiPlatformSearchServiceProvider);

// 搜索音乐
final result = await searchService.search(
  '告白气球',
  platform: MusicPlatform.netease,
  limit: 30,
);

print('找到 ${result.total} 首歌曲');
for (final song in result.songs) {
  print('${song.title} - ${song.artist}');
}

// 获取播放地址
final playUrl = await searchService.getPlayUrl(
  result.songs.first,
  quality: AudioQuality.high,
);

// 播放在线歌曲
if (playUrl != null) {
  await audioService.setPlaylist([song]);
  await audioService.play();
}
```

#### 音乐平台
```dart
enum MusicPlatform {
  netease,   // 网易云音乐
  qq,        // QQ音乐
  kugou,     // 酷狗音乐
  all,       // 所有平台
}
```

#### 音质选项
```dart
enum AudioQuality {
  standard,  // 标准 128kbps
  high,      // 高品质 320kbps
  lossless,  // 无损 FLAC
}
```

---

### 2.6 下载管理器 (DownloadManager)

#### 接口定义
```dart
class DownloadManager {
  /// 添加下载任务
  Future<DownloadTask> addDownload(
    OnlineSong song, {
    AudioQuality quality = AudioQuality.high,
  });

  /// 暂停下载
  Future<void> pauseDownload(String taskId);

  /// 恢复下载
  Future<void> resumeDownload(String taskId);

  /// 取消下载
  Future<void> cancelDownload(String taskId);

  /// 获取所有下载任务
  Future<List<DownloadTask>> getAllDownloads();

  /// 下载任务状态流
  Stream<DownloadTask> watchTask(String taskId);
}
```

#### 使用示例
```dart
final downloadManager = ref.watch(downloadManagerProvider);

// 添加下载
final task = await downloadManager.addDownload(
  onlineSong,
  quality: AudioQuality.lossless,
);

// 监听下载进度
downloadManager.watchTask(task.id).listen((updatedTask) {
  print('进度: ${updatedTask.progress}%');
  print('速度: ${updatedTask.speed} KB/s');
  print('状态: ${updatedTask.status}');
});

// 暂停/恢复
await downloadManager.pauseDownload(task.id);
await downloadManager.resumeDownload(task.id);
```

#### 下载任务状态
```dart
class DownloadTask {
  final String id;
  final OnlineSong song;
  final DownloadStatus status;
  final double progress;  // 0-100
  final int downloadedBytes;
  final int totalBytes;
  final double speed;  // KB/s
  final String? error;
}

enum DownloadStatus {
  pending,     // 等待中
  downloading, // 下载中
  paused,      // 已暂停
  completed,   // 已完成
  failed,      // 失败
  cancelled,   // 已取消
}
```

---

## 3. 数据模型

### 3.1 Song（歌曲）

```dart
@freezed
class Song with _$Song {
  const factory Song({
    required String id,
    required String title,
    required String artist,
    required String album,
    required String path,
    required Duration duration,
    String? albumArt,
    int? trackNumber,
    int? year,
    String? genre,
    int? bitrate,
    String? format,
    DateTime? addedDate,
    int? playCount,
    bool? isFavorite,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
}
```

### 3.2 Playlist（播放列表）

```dart
@freezed
class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String name,
    String? description,
    String? coverArt,
    required DateTime createdAt,
    DateTime? updatedAt,
    required List<String> songIds,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json)
    => _$PlaylistFromJson(json);
}
```

### 3.3 OnlineSong（在线歌曲）

```dart
@freezed
class OnlineSong with _$OnlineSong {
  const factory OnlineSong({
    required String id,
    required String title,
    required String artist,
    required String album,
    String? albumArt,
    required Duration duration,
    required MusicPlatform platform,
    Map<AudioQuality, String>? playUrls,
    bool? hasLyrics,
  }) = _OnlineSong;

  factory OnlineSong.fromJson(Map<String, dynamic> json)
    => _$OnlineSongFromJson(json);
}
```

---

## 4. 状态管理

### 4.1 Riverpod Providers

#### 音频播放器 Provider
```dart
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerServiceImpl();
});

final currentSongProvider = StreamProvider<Song?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.currentSongStream;
});

final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.playerStateStream;
});

final playlistProvider = StreamProvider<List<Song>>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.playlistStream;
});
```

#### 歌曲库 Provider
```dart
final songRepositoryProvider = Provider<ISongRepository>((ref) {
  return SongRepositoryImpl();
});

final allSongsProvider = FutureProvider<List<Song>>((ref) async {
  final repository = ref.watch(songRepositoryProvider);
  return repository.getAllSongs();
});

final songsByArtistProvider = FutureProvider.family<List<Song>, String>(
  (ref, artist) async {
    final repository = ref.watch(songRepositoryProvider);
    return repository.getSongsByArtist(artist);
  },
);
```

### 4.2 使用 Provider

```dart
class PlayerControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听播放状态
    final playerState = ref.watch(playerStateProvider);
    final currentSong = ref.watch(currentSongProvider);

    return playerState.when(
      data: (state) {
        return IconButton(
          icon: Icon(
            state == PlayerState.playing
              ? Icons.pause
              : Icons.play_arrow,
          ),
          onPressed: () {
            final service = ref.read(audioPlayerServiceProvider);
            if (state == PlayerState.playing) {
              service.pause();
            } else {
              service.play();
            }
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Icon(Icons.error),
    );
  }
}
```

---

## 5. 平台特定 API

### 5.1 Windows 平台服务

#### 系统托盘 (SystemTrayService)
```dart
class SystemTrayService {
  /// 初始化系统托盘
  Future<void> initialize();

  /// 显示托盘图标
  Future<void> show();

  /// 隐藏托盘图标
  Future<void> hide();

  /// 更新托盘菜单
  Future<void> updateMenu(List<MenuItem> items);

  /// 设置托盘提示文本
  Future<void> setTooltip(String tooltip);
}
```

#### 使用示例
```dart
final trayService = SystemTrayService();

await trayService.initialize();
await trayService.updateMenu([
  MenuItem(
    label: '播放/暂停',
    onTap: () => audioService.togglePlayPause(),
  ),
  MenuItem.separator(),
  MenuItem(
    label: '退出',
    onTap: () => exitApp(),
  ),
]);
```

#### 全局快捷键 (HotkeyService)
```dart
class HotkeyService {
  /// 注册全局快捷键
  Future<void> registerHotkey(
    String id,
    HotKey hotkey,
    VoidCallback callback,
  );

  /// 注销快捷键
  Future<void> unregisterHotkey(String id);

  /// 注销所有快捷键
  Future<void> unregisterAll();
}
```

#### 使用示例
```dart
final hotkeyService = HotkeyService();

// 注册播放/暂停快捷键
await hotkeyService.registerHotkey(
  'play_pause',
  HotKey(
    key: LogicalKeyboardKey.space,
    modifiers: [HotKeyModifier.control],
  ),
  () => audioService.togglePlayPause(),
);
```

---

## 6. 扩展指南

### 6.1 添加新的音乐平台

1. 创建平台 API 类：
```dart
class NewMusicPlatformAPI {
  Future<List<OnlineSong>> search(String keyword) async {
    // 实现搜索逻辑
  }

  Future<String?> getPlayUrl(String songId) async {
    // 实现获取播放地址逻辑
  }
}
```

2. 在 `MultiPlatformSearchService` 中集成：
```dart
Future<SearchResult> search(String keyword, {MusicPlatform? platform}) async {
  if (platform == MusicPlatform.newPlatform) {
    final api = NewMusicPlatformAPI();
    final songs = await api.search(keyword);
    return SearchResult(songs: songs, total: songs.length);
  }
  // ...
}
```

### 6.2 自定义播放模式

```dart
class CustomPlaybackMode implements PlaybackMode {
  @override
  Song? getNextSong(List<Song> playlist, int currentIndex) {
    // 实现自定义的下一曲逻辑
    // 例如：智能推荐、心情模式等
  }

  @override
  Song? getPreviousSong(List<Song> playlist, int currentIndex) {
    // 实现上一曲逻辑
  }
}

// 使用自定义模式
audioService.setPlaybackMode(CustomPlaybackMode());
```

### 6.3 添加音频效果

```dart
class AudioEffectService {
  /// 设置均衡器
  Future<void> setEqualizer(EqualizerPreset preset);

  /// 设置音效
  Future<void> setAudioEffect(AudioEffect effect);
}

// 示例：添加均衡器
final effectService = AudioEffectService();
await effectService.setEqualizer(EqualizerPreset.rock);
```

### 6.4 扩展歌词源

```dart
abstract class LyricsProvider {
  Future<Lyrics?> fetchLyrics(String title, String artist);
}

class CustomLyricsProvider implements LyricsProvider {
  @override
  Future<Lyrics?> fetchLyrics(String title, String artist) async {
    // 从自定义源获取歌词
  }
}

// 在 LyricsService 中注册
lyricsService.registerProvider(CustomLyricsProvider());
```

---

## 附录

### A. 错误处理

所有异步 API 都应该进行适当的错误处理：

```dart
try {
  final songs = await songRepository.getAllSongs();
  // 处理歌曲列表
} on DatabaseException catch (e) {
  print('数据库错误: ${e.message}');
} on NetworkException catch (e) {
  print('网络错误: ${e.message}');
} catch (e) {
  print('未知错误: $e');
}
```

### B. 性能优化建议

1. **使用流（Streams）而非轮询**
   ```dart
   // ✅ 推荐
   audioService.positionStream.listen((position) {
     updateUI(position);
   });

   // ❌ 不推荐
   Timer.periodic(Duration(seconds: 1), (_) {
     final position = audioService.getPosition();
     updateUI(position);
   });
   ```

2. **缓存频繁访问的数据**
   ```dart
   final cachedSongs = ref.watch(allSongsProvider);
   ```

3. **批量操作**
   ```dart
   // ✅ 推荐
   await playlistManager.addSongsToPlaylist(playlistId, [song1.id, song2.id]);

   // ❌ 不推荐
   for (final song in songs) {
     await playlistManager.addSongToPlaylist(playlistId, song.id);
   }
   ```

### C. 测试示例

```dart
void main() {
  group('AudioPlayerService', () {
    late AudioPlayerService service;

    setUp(() {
      service = AudioPlayerServiceImpl();
    });

    test('should play song', () async {
      final song = Song(/* ... */);
      await service.setPlaylist([song]);
      await service.play();

      expect(service.playerStateStream, emits(PlayerState.playing));
    });

    tearDown(() {
      service.dispose();
    });
  });
}
```

---

## 更新日志

- **2026-01-21**: 初始版本 API 文档
  - 核心服务 API
  - 数据模型定义
  - Riverpod Provider 使用
  - 平台特定 API
  - 扩展指南

---

**更多信息**:
- [用户手册](./user-manual.md)
- [开发文档](./development.md)
- [设计文档](./design.md)
