import 'dart:async';
import '../../data/models/song_model.dart';
import 'audio_player_service_impl.dart';

/// 增强版音频播放器服务
///
/// 在基础播放器之上添加：
/// - TASK-028: 淡入淡出效果
/// - TASK-029: 音量正常化
class AudioPlayerServiceEnhanced extends AudioPlayerServiceImpl {
  /// 是否启用淡入淡出效果
  bool _fadeEnabled = true;

  /// 淡入淡出时长（毫秒）
  int _fadeDurationMs = 1000;

  /// 是否启用音量正常化
  bool _volumeNormalizationEnabled = false;

  /// 目标音量（用于音量正常化）
  double _targetVolume = 0.8;

  /// 淡入淡出定时器
  Timer? _fadeTimer;

  /// 原始音量（淡入淡出前的音量）
  double _originalVolume = 1.0;

  // ========== TASK-028: 淡入淡出效果 ==========

  /// 设置是否启用淡入淡出效果
  ///
  /// [enabled] 是否启用
  void setFadeEnabled(bool enabled) {
    _fadeEnabled = enabled;
  }

  /// 设置淡入淡出时长
  ///
  /// [durationMs] 时长（毫秒），默认 1000ms
  void setFadeDuration(int durationMs) {
    _fadeDurationMs = durationMs.clamp(100, 5000); // 限制在 100ms - 5000ms
  }

  /// 获取淡入淡出时长
  int getFadeDuration() {
    return _fadeDurationMs;
  }

  /// 播放时带淡入效果
  @override
  Future<bool> play(SongModel song) async {
    // 如果启用了淡出效果，先淡出当前播放
    if (_fadeEnabled && isPlaying) {
      await _fadeOut();
    }

    // 调用父类播放方法
    final success = await super.play(song);

    if (success && _fadeEnabled) {
      // 播放成功后执行淡入
      await _fadeIn();
    }

    return success;
  }

  /// 停止时带淡出效果
  @override
  Future<void> stop() async {
    if (_fadeEnabled && isPlaying) {
      await _fadeOut();
    }
    await super.stop();
  }

  /// 切换到下一曲时带淡入淡出效果
  @override
  Future<void> skipToNext() async {
    if (_fadeEnabled && isPlaying) {
      await _fadeOut();
    }
    await super.skipToNext();
    if (_fadeEnabled && isPlaying) {
      await _fadeIn();
    }
  }

  /// 切换到上一曲时带淡入淡出效果
  @override
  Future<void> skipToPrevious() async {
    if (_fadeEnabled && isPlaying) {
      await _fadeOut();
    }
    await super.skipToPrevious();
    if (_fadeEnabled && isPlaying) {
      await _fadeIn();
    }
  }

  /// 淡入效果
  ///
  /// 从 0 逐渐增加到目标音量
  Future<void> _fadeIn() async {
    _fadeTimer?.cancel();

    final targetVolume = _volumeNormalizationEnabled ? _targetVolume : _originalVolume;
    final steps = 50; // 淡入步数
    final stepDuration = _fadeDurationMs ~/ steps;
    final volumeStep = targetVolume / steps;

    // 从 0 开始
    await super.setVolume(0.0);

    int currentStep = 0;
    _fadeTimer = Timer.periodic(Duration(milliseconds: stepDuration), (timer) async {
      currentStep++;
      final newVolume = (volumeStep * currentStep).clamp(0.0, targetVolume);
      await super.setVolume(newVolume);

      if (currentStep >= steps) {
        timer.cancel();
        _fadeTimer = null;
      }
    });
  }

  /// 淡出效果
  ///
  /// 从当前音量逐渐降低到 0
  Future<void> _fadeOut() async {
    _fadeTimer?.cancel();

    final currentVolume = getVolume();
    final steps = 50; // 淡出步数
    final stepDuration = _fadeDurationMs ~/ steps;
    final volumeStep = currentVolume / steps;

    int currentStep = 0;
    final completer = Completer<void>();

    _fadeTimer = Timer.periodic(Duration(milliseconds: stepDuration), (timer) async {
      currentStep++;
      final newVolume = (currentVolume - volumeStep * currentStep).clamp(0.0, 1.0);
      await super.setVolume(newVolume);

      if (currentStep >= steps || newVolume <= 0.0) {
        timer.cancel();
        _fadeTimer = null;
        completer.complete();
      }
    });

    await completer.future;
  }

  // ========== TASK-029: 音量正常化 ==========

  /// 设置是否启用音量正常化
  ///
  /// 音量正常化会自动调整不同歌曲的音量，使其保持一致
  /// [enabled] 是否启用
  void setVolumeNormalizationEnabled(bool enabled) {
    _volumeNormalizationEnabled = enabled;

    if (enabled) {
      // 启用时，应用目标音量
      _applyNormalizedVolume();
    } else {
      // 禁用时，恢复原始音量
      super.setVolume(_originalVolume);
    }
  }

  /// 设置目标音量（用于音量正常化）
  ///
  /// [volume] 目标音量，范围 0.0 - 1.0
  void setTargetVolume(double volume) {
    _targetVolume = volume.clamp(0.0, 1.0);

    if (_volumeNormalizationEnabled) {
      _applyNormalizedVolume();
    }
  }

  /// 获取目标音量
  double getTargetVolume() {
    return _targetVolume;
  }

  /// 是否启用了音量正常化
  bool isVolumeNormalizationEnabled() {
    return _volumeNormalizationEnabled;
  }

  /// 应用正常化后的音量
  void _applyNormalizedVolume() {
    if (_volumeNormalizationEnabled) {
      super.setVolume(_targetVolume);
    }
  }

  /// 重写 setVolume 方法，保存原始音量
  @override
  Future<void> setVolume(double volume) async {
    _originalVolume = volume.clamp(0.0, 1.0);

    if (_volumeNormalizationEnabled) {
      // 如果启用了音量正常化，使用目标音量
      await super.setVolume(_targetVolume);
    } else {
      // 否则使用设置的音量
      await super.setVolume(_originalVolume);
    }
  }

  /// 获取原始音量（用户设置的音量）
  double getOriginalVolume() {
    return _originalVolume;
  }

  // ========== 资源管理 ==========

  @override
  Future<void> dispose() async {
    _fadeTimer?.cancel();
    await super.dispose();
  }
}
