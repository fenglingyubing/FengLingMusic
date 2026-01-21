import 'dart:async';
import 'package:flutter/services.dart';
import 'audio_player_service.dart';

/// TASK-125 & TASK-126: 耳机线控和自动暂停功能
///
/// 功能包括：
/// - 耳机按钮响应（播放/暂停、切歌）
/// - 拔耳机自动暂停
/// - 来电自动暂停（通过系统音频焦点管理）
class HeadphoneEventListener {
  final AudioPlayerService _audioService;
  StreamSubscription? _headphoneSubscription;
  bool _wasPlayingBeforeUnplug = false;

  static const MethodChannel _channel = MethodChannel('com.fenglingmusic/headphone');

  HeadphoneEventListener(this._audioService);

  /// 初始化耳机事件监听
  Future<void> initialize() async {
    try {
      // 设置方法调用处理器
      _channel.setMethodCallHandler(_handleMethodCall);

      // 请求监听耳机事件
      await _channel.invokeMethod('startListening');

      print('Headphone event listener initialized');
    } catch (e) {
      print('Error initializing headphone listener: $e');
    }
  }

  /// 处理原生平台的方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onHeadphonePlugged':
        await _onHeadphonePlugged();
        break;

      case 'onHeadphoneUnplugged':
        await _onHeadphoneUnplugged();
        break;

      case 'onHeadphoneButtonPressed':
        final clickCount = call.arguments as int? ?? 1;
        await _onHeadphoneButtonPressed(clickCount);
        break;

      case 'onAudioFocusLost':
        await _onAudioFocusLost();
        break;

      case 'onAudioFocusGained':
        await _onAudioFocusGained();
        break;

      default:
        print('Unknown method: ${call.method}');
    }
  }

  /// 耳机插入事件
  Future<void> _onHeadphonePlugged() async {
    print('Headphone plugged');
    // 可以在这里添加自动恢复播放的逻辑
    // 但通常不建议自动播放，以免打扰用户
  }

  /// 耳机拔出事件 - 自动暂停
  Future<void> _onHeadphoneUnplugged() async {
    print('Headphone unplugged - pausing playback');

    if (_audioService.isPlaying) {
      _wasPlayingBeforeUnplug = true;
      await _audioService.pause();
    }
  }

  /// 耳机按钮按下事件
  ///
  /// [clickCount] 按钮点击次数
  /// - 1次点击: 播放/暂停
  /// - 2次点击: 下一曲
  /// - 3次点击: 上一曲
  Future<void> _onHeadphoneButtonPressed(int clickCount) async {
    print('Headphone button pressed: $clickCount times');

    switch (clickCount) {
      case 1:
        // 单击: 播放/暂停
        if (_audioService.isPlaying) {
          await _audioService.pause();
        } else {
          await _audioService.resume();
        }
        break;

      case 2:
        // 双击: 下一曲
        await _audioService.skipToNext();
        break;

      case 3:
        // 三击: 上一曲
        await _audioService.skipToPrevious();
        break;

      default:
        print('Unsupported click count: $clickCount');
    }
  }

  /// 音频焦点丢失 - 来电或其他应用播放音频时暂停
  Future<void> _onAudioFocusLost() async {
    print('Audio focus lost - pausing playback');

    if (_audioService.isPlaying) {
      _wasPlayingBeforeUnplug = true;
      await _audioService.pause();
    }
  }

  /// 音频焦点恢复 - 来电结束后可以恢复播放
  Future<void> _onAudioFocusGained() async {
    print('Audio focus gained');

    // 注意：通常不建议自动恢复播放，除非用户明确设置了这个选项
    // 这里只是记录状态，实际恢复播放需要用户手动操作
    // 如果需要自动恢复，可以添加用户设置选项
    // if (_wasPlayingBeforeUnplug) {
    //   await _audioService.resume();
    //   _wasPlayingBeforeUnplug = false;
    // }
  }

  /// 清理资源
  Future<void> dispose() async {
    await _headphoneSubscription?.cancel();
    try {
      await _channel.invokeMethod('stopListening');
    } catch (e) {
      print('Error stopping headphone listener: $e');
    }
  }
}
