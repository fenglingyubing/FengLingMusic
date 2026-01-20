import '../../data/models/song_model.dart';
import '../../data/models/play_mode.dart';

/// 音频播放服务接口
///
/// 定义了音频播放器的所有核心功能，包括：
/// - 基础播放控制（播放、暂停、停止、跳转）
/// - 播放队列管理
/// - 播放状态监听
/// - 音量控制
///
/// 实现类应该使用 just_audio 包提供实际的播放功能
abstract class AudioPlayerService {
  // ========== 基础播放控制 ==========

  /// 播放指定歌曲
  ///
  /// [song] 要播放的歌曲
  /// 返回 Future\<bool\> 表示是否成功开始播放
  Future<bool> play(SongModel song);

  /// 暂停播放
  Future<void> pause();

  /// 恢复播放
  Future<void> resume();

  /// 停止播放
  Future<void> stop();

  /// 跳转到指定位置
  ///
  /// [position] 目标位置（Duration）
  Future<void> seek(Duration position);

  // ========== 音量控制 ==========

  /// 设置音量
  ///
  /// [volume] 音量值，范围 0.0 - 1.0
  Future<void> setVolume(double volume);

  /// 获取当前音量
  ///
  /// 返回当前音量值，范围 0.0 - 1.0
  double getVolume();

  // ========== 播放队列管理 ==========

  /// 设置播放队列
  ///
  /// [songs] 歌曲列表
  /// [startIndex] 开始播放的索引，默认为0
  Future<void> setPlaylist(List<SongModel> songs, {int startIndex = 0});

  /// 添加歌曲到队列末尾
  ///
  /// [song] 要添加的歌曲
  void addToQueue(SongModel song);

  /// 在指定位置插入歌曲
  ///
  /// [index] 插入位置
  /// [song] 要插入的歌曲
  void insertToQueue(int index, SongModel song);

  /// 从队列中移除歌曲
  ///
  /// [index] 要移除的歌曲索引
  void removeFromQueue(int index);

  /// 清空播放队列
  void clearQueue();

  /// 获取当前播放队列
  List<SongModel> getQueue();

  /// 下一曲
  Future<void> skipToNext();

  /// 上一曲
  Future<void> skipToPrevious();

  /// 跳转到指定索引的歌曲
  ///
  /// [index] 目标歌曲索引
  Future<void> skipToIndex(int index);

  // ========== 播放模式 ==========

  /// 设置播放模式
  ///
  /// [mode] 播放模式
  void setPlayMode(PlayMode mode);

  /// 获取当前播放模式
  PlayMode getPlayMode();

  // ========== 状态获取 ==========

  /// 是否正在播放
  bool get isPlaying;

  /// 当前播放的歌曲
  SongModel? get currentSong;

  /// 当前播放位置
  Duration get position;

  /// 当前歌曲总时长
  Duration get duration;

  /// 当前队列索引
  int get currentIndex;

  // ========== 状态流（Stream）==========

  /// 播放状态流
  ///
  /// 发送 true 表示正在播放，false 表示暂停或停止
  Stream<bool> get playingStream;

  /// 当前歌曲流
  ///
  /// 当切换歌曲时发送新的 SongModel 对象
  Stream<SongModel?> get currentSongStream;

  /// 播放位置流
  ///
  /// 定期发送当前播放位置
  Stream<Duration> get positionStream;

  /// 时长流
  ///
  /// 当歌曲时长可用时发送
  Stream<Duration> get durationStream;

  /// 播放队列流
  ///
  /// 当播放队列改变时发送
  Stream<List<SongModel>> get queueStream;

  /// 播放模式流
  ///
  /// 当播放模式改变时发送
  Stream<PlayMode> get playModeStream;

  // ========== 资源管理 ==========

  /// 释放资源
  ///
  /// 在不再使用播放器时调用，释放音频资源
  Future<void> dispose();
}
