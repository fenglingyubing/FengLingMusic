import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 重试策略枚举
enum RetryStrategy {
  /// 固定延迟
  fixed,

  /// 指数退避
  exponentialBackoff,

  /// 线性增长
  linear,
}

/// 重试配置
class RetryConfig {
  /// 最大重试次数
  final int maxRetries;

  /// 重试策略
  final RetryStrategy strategy;

  /// 基础延迟时间（毫秒）
  final int baseDelay;

  /// 最大延迟时间（毫秒）
  final int maxDelay;

  /// 需要重试的 HTTP 状态码
  final Set<int> retryableStatusCodes;

  /// 需要重试的异常类型
  final Set<DioExceptionType> retryableExceptionTypes;

  const RetryConfig({
    this.maxRetries = 3,
    this.strategy = RetryStrategy.exponentialBackoff,
    this.baseDelay = 1000,
    this.maxDelay = 10000,
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
    this.retryableExceptionTypes = const {
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    },
  });

  /// 创建默认配置
  factory RetryConfig.defaults() {
    return const RetryConfig();
  }

  /// 创建激进重试配置（更多重试次数）
  factory RetryConfig.aggressive() {
    return const RetryConfig(
      maxRetries: 5,
      strategy: RetryStrategy.exponentialBackoff,
      baseDelay: 500,
    );
  }

  /// 创建保守重试配置（更少重试次数）
  factory RetryConfig.conservative() {
    return const RetryConfig(
      maxRetries: 2,
      strategy: RetryStrategy.linear,
      baseDelay: 2000,
    );
  }

  /// 创建禁用重试配置
  factory RetryConfig.disabled() {
    return const RetryConfig(
      maxRetries: 0,
    );
  }
}

/// HTTP 请求重试拦截器
///
/// 当请求失败时自动重试，支持多种重试策略
class RetryInterceptor extends Interceptor {
  /// 重试配置
  final RetryConfig config;

  /// Dio 实例（用于重试请求）
  final Dio dio;

  RetryInterceptor({
    required this.dio,
    RetryConfig? config,
  }) : config = config ?? RetryConfig.defaults();

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 检查是否应该重试
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    // 获取已重试次数
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // 检查是否超过最大重试次数
    if (retryCount >= config.maxRetries) {
      if (kDebugMode) {
        debugPrint(
          '❌ Max retries reached (${config.maxRetries}) for: ${err.requestOptions.uri}',
        );
      }
      handler.next(err);
      return;
    }

    // 计算延迟时间
    final delay = _calculateDelay(retryCount);

    if (kDebugMode) {
      debugPrint(
        '🔄 Retry ${retryCount + 1}/${config.maxRetries} for: ${err.requestOptions.uri} (delay: ${delay}ms)',
      );
    }

    // 等待延迟
    await Future.delayed(Duration(milliseconds: delay));

    // 更新重试计数
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      // 重试请求
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      // 如果重试仍然失败，继续处理错误
      super.onError(e, handler);
    }
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException err) {
    // 禁用重试
    if (config.maxRetries == 0) {
      return false;
    }

    // 检查是否明确禁用了重试
    final disableRetry = err.requestOptions.extra['disableRetry'] as bool? ?? false;
    if (disableRetry) {
      return false;
    }

    // 检查请求方法（默认只重试 GET 请求，除非明确允许）
    final allowRetryForMethod = err.requestOptions.extra['allowRetryForMethod'] as bool? ?? false;
    if (!allowRetryForMethod && err.requestOptions.method.toUpperCase() != 'GET') {
      return false;
    }

    // 检查异常类型
    if (config.retryableExceptionTypes.contains(err.type)) {
      return true;
    }

    // 检查 HTTP 状态码
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      if (statusCode != null && config.retryableStatusCodes.contains(statusCode)) {
        return true;
      }
    }

    return false;
  }

  /// 计算延迟时间
  int _calculateDelay(int retryCount) {
    int delay;

    switch (config.strategy) {
      case RetryStrategy.fixed:
        // 固定延迟
        delay = config.baseDelay;
        break;

      case RetryStrategy.exponentialBackoff:
        // 指数退避：baseDelay * 2^retryCount
        delay = config.baseDelay * pow(2, retryCount).toInt();
        // 添加随机抖动（jitter）避免雷鸣群效应
        final jitter = Random().nextInt(delay ~/ 2);
        delay = delay + jitter;
        break;

      case RetryStrategy.linear:
        // 线性增长：baseDelay * (retryCount + 1)
        delay = config.baseDelay * (retryCount + 1);
        break;
    }

    // 限制最大延迟
    return min(delay, config.maxDelay);
  }
}

/// RequestOptions 扩展，用于设置重试选项
extension RetryOptionsExtension on RequestOptions {
  /// 禁用重试
  RequestOptions withoutRetry() {
    extra['disableRetry'] = true;
    return this;
  }

  /// 允许对任何 HTTP 方法进行重试
  RequestOptions withRetryForAnyMethod() {
    extra['allowRetryForMethod'] = true;
    return this;
  }

  /// 设置自定义最大重试次数（仅对此请求有效）
  RequestOptions withMaxRetries(int maxRetries) {
    extra['maxRetries'] = maxRetries;
    return this;
  }
}
