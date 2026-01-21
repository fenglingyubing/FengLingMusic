import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// TASK-127: Android高刷新率屏幕优化
///
/// 功能包括：
/// - 检测屏幕刷新率
/// - 自动适配90/120/144Hz
/// - 动态调整动画帧率
class AndroidRefreshRateOptimizer {
  static const MethodChannel _channel =
      MethodChannel('com.fenglingmusic/refresh_rate');

  /// 当前检测到的刷新率
  double? _currentRefreshRate;

  /// 目标刷新率（用户设置）
  double? _targetRefreshRate;

  /// 刷新率变化流控制器
  final StreamController<double> _refreshRateController =
      StreamController<double>.broadcast();

  /// 刷新率变化流
  Stream<double> get refreshRateStream => _refreshRateController.stream;

  /// 获取当前刷新率
  double? get currentRefreshRate => _currentRefreshRate;

  /// 初始化刷新率检测
  Future<void> initialize() async {
    try {
      // 从Flutter引擎获取刷新率
      final display = ui.PlatformDispatcher.instance.displays.first;
      _currentRefreshRate = display.refreshRate;

      debugPrint('Flutter detected refresh rate: ${_currentRefreshRate}Hz');

      // 如果可能，从Android系统获取更准确的刷新率
      try {
        final systemRefreshRate = await _channel.invokeMethod<double>('getRefreshRate');
        if (systemRefreshRate != null && systemRefreshRate > 0) {
          _currentRefreshRate = systemRefreshRate;
          debugPrint('Android system refresh rate: ${_currentRefreshRate}Hz');
        }
      } catch (e) {
        debugPrint('Failed to get system refresh rate: $e');
      }

      _refreshRateController.add(_currentRefreshRate ?? 60.0);

      // 监听刷新率变化（某些设备支持动态刷新率）
      ui.PlatformDispatcher.instance.onMetricsChanged = _onMetricsChanged;
    } catch (e) {
      debugPrint('Error initializing refresh rate optimizer: $e');
      _currentRefreshRate = 60.0; // 默认60Hz
      _refreshRateController.add(60.0);
    }
  }

  /// 设置目标刷新率
  ///
  /// 尝试将屏幕刷新率设置为指定值
  /// 注意：不是所有设备都支持动态调整刷新率
  Future<bool> setTargetRefreshRate(double targetRate) async {
    try {
      _targetRefreshRate = targetRate;

      // 尝试通过Android API设置刷新率
      final result = await _channel.invokeMethod<bool>(
        'setPreferredRefreshRate',
        {'refreshRate': targetRate},
      );

      if (result == true) {
        debugPrint('Successfully set refresh rate to ${targetRate}Hz');
        _currentRefreshRate = targetRate;
        _refreshRateController.add(targetRate);
        return true;
      } else {
        debugPrint('Failed to set refresh rate to ${targetRate}Hz');
        return false;
      }
    } catch (e) {
      debugPrint('Error setting target refresh rate: $e');
      return false;
    }
  }

  /// 获取设备支持的刷新率列表
  Future<List<double>> getSupportedRefreshRates() async {
    try {
      final result = await _channel.invokeMethod<List>('getSupportedRefreshRates');
      if (result != null) {
        return result.map((rate) => (rate as num).toDouble()).toList();
      }
    } catch (e) {
      debugPrint('Error getting supported refresh rates: $e');
    }

    // 默认返回常见刷新率
    return [60.0, 90.0, 120.0];
  }

  /// 启用高性能模式（最高刷新率）
  Future<void> enableHighPerformanceMode() async {
    try {
      final supportedRates = await getSupportedRefreshRates();
      if (supportedRates.isNotEmpty) {
        final maxRate = supportedRates.reduce((a, b) => a > b ? a : b);
        await setTargetRefreshRate(maxRate);
      }
    } catch (e) {
      debugPrint('Error enabling high performance mode: $e');
    }
  }

  /// 启用省电模式（降低刷新率）
  Future<void> enablePowerSavingMode() async {
    try {
      await setTargetRefreshRate(60.0);
    } catch (e) {
      debugPrint('Error enabling power saving mode: $e');
    }
  }

  /// 自动模式（跟随系统设置）
  Future<void> enableAutoMode() async {
    try {
      _targetRefreshRate = null;
      await _channel.invokeMethod('resetRefreshRate');
      debugPrint('Reset to system default refresh rate');
    } catch (e) {
      debugPrint('Error enabling auto mode: $e');
    }
  }

  /// 获取建议的动画duration乘数
  ///
  /// 用于调整动画速度以适配不同刷新率
  /// 例如：60Hz返回1.0，120Hz返回0.5
  double getAnimationDurationMultiplier() {
    if (_currentRefreshRate == null) return 1.0;

    // 基准60Hz
    const baseRefreshRate = 60.0;
    return baseRefreshRate / _currentRefreshRate!;
  }

  /// 是否支持高刷新率（>60Hz）
  bool get supportsHighRefreshRate {
    return _currentRefreshRate != null && _currentRefreshRate! > 60.0;
  }

  /// 是否为120Hz或更高
  bool get is120HzOrHigher {
    return _currentRefreshRate != null && _currentRefreshRate! >= 120.0;
  }

  /// 获取刷新率级别
  ///
  /// 返回：
  /// - 'standard': 60Hz
  /// - 'high': 90Hz
  /// - 'ultra': 120Hz+
  String getRefreshRateLevel() {
    if (_currentRefreshRate == null || _currentRefreshRate! <= 60.0) {
      return 'standard';
    } else if (_currentRefreshRate! < 120.0) {
      return 'high';
    } else {
      return 'ultra';
    }
  }

  /// 监听屏幕参数变化
  void _onMetricsChanged() {
    final display = ui.PlatformDispatcher.instance.displays.first;
    final newRefreshRate = display.refreshRate;

    if (newRefreshRate != _currentRefreshRate) {
      debugPrint('Refresh rate changed: ${_currentRefreshRate}Hz -> ${newRefreshRate}Hz');
      _currentRefreshRate = newRefreshRate;
      _refreshRateController.add(newRefreshRate);
    }
  }

  /// 清理资源
  Future<void> dispose() async {
    await _refreshRateController.close();
    ui.PlatformDispatcher.instance.onMetricsChanged = null;
  }
}
