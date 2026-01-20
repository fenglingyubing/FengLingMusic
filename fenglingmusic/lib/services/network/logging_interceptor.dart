import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 请求日志拦截器
///
/// 记录所有 HTTP 请求和响应的详细信息，用于调试和问题排查
class LoggingInterceptor extends Interceptor {
  /// 是否打印请求头
  final bool logHeaders;

  /// 是否打印请求体
  final bool logRequestBody;

  /// 是否打印响应体
  final bool logResponseBody;

  /// 最大日志长度（用于截断超长日志）
  final int maxLogLength;

  LoggingInterceptor({
    this.logHeaders = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.maxLogLength = 1000,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(options);
      return;
    }

    final requestTime = DateTime.now();
    options.extra['requestTime'] = requestTime;

    debugPrint('');
    debugPrint('┌──────────────────────────────────────────────────────────');
    debugPrint('│ 📤 REQUEST');
    debugPrint('├──────────────────────────────────────────────────────────');
    debugPrint('│ 🔗 ${options.method} ${options.uri}');
    debugPrint('│ ⏰ ${requestTime.toIso8601String()}');

    if (logHeaders && options.headers.isNotEmpty) {
      debugPrint('├──────────────────────────────────────────────────────────');
      debugPrint('│ 📋 Headers:');
      options.headers.forEach((key, value) {
        debugPrint('│   $key: $value');
      });
    }

    if (options.queryParameters.isNotEmpty) {
      debugPrint('├──────────────────────────────────────────────────────────');
      debugPrint('│ 🔍 Query Parameters:');
      options.queryParameters.forEach((key, value) {
        debugPrint('│   $key: $value');
      });
    }

    if (logRequestBody && options.data != null) {
      debugPrint('├──────────────────────────────────────────────────────────');
      debugPrint('│ 📦 Request Body:');
      final bodyString = options.data.toString();
      if (bodyString.length > maxLogLength) {
        debugPrint('│   ${bodyString.substring(0, maxLogLength)}...[truncated]');
      } else {
        debugPrint('│   $bodyString');
      }
    }

    debugPrint('└──────────────────────────────────────────────────────────');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(response);
      return;
    }

    final requestTime = response.requestOptions.extra['requestTime'] as DateTime?;
    final responseTime = DateTime.now();
    final duration = requestTime != null
        ? responseTime.difference(requestTime).inMilliseconds
        : 0;

    debugPrint('');
    debugPrint('┌──────────────────────────────────────────────────────────');
    debugPrint('│ 📥 RESPONSE');
    debugPrint('├──────────────────────────────────────────────────────────');
    debugPrint('│ 🔗 ${response.requestOptions.method} ${response.requestOptions.uri}');
    debugPrint('│ ⏰ ${responseTime.toIso8601String()}');
    debugPrint('│ ⏱️  Duration: ${duration}ms');
    debugPrint('│ 📊 Status: ${response.statusCode} ${response.statusMessage ?? ''}');

    if (logHeaders && response.headers.map.isNotEmpty) {
      debugPrint('├──────────────────────────────────────────────────────────');
      debugPrint('│ 📋 Headers:');
      response.headers.map.forEach((key, values) {
        debugPrint('│   $key: ${values.join(', ')}');
      });
    }

    if (logResponseBody && response.data != null) {
      debugPrint('├──────────────────────────────────────────────────────────');
      debugPrint('│ 📦 Response Body:');
      final bodyString = response.data.toString();
      if (bodyString.length > maxLogLength) {
        debugPrint('│   ${bodyString.substring(0, maxLogLength)}...[truncated]');
      } else {
        debugPrint('│   $bodyString');
      }
    }

    debugPrint('└──────────────────────────────────────────────────────────');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(err);
      return;
    }

    final requestTime = err.requestOptions.extra['requestTime'] as DateTime?;
    final errorTime = DateTime.now();
    final duration = requestTime != null
        ? errorTime.difference(requestTime).inMilliseconds
        : 0;

    debugPrint('');
    debugPrint('┌──────────────────────────────────────────────────────────');
    debugPrint('│ ❌ ERROR');
    debugPrint('├──────────────────────────────────────────────────────────');
    debugPrint('│ 🔗 ${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('│ ⏰ ${errorTime.toIso8601String()}');
    debugPrint('│ ⏱️  Duration: ${duration}ms');
    debugPrint('│ 🚨 Type: ${err.type.name}');
    debugPrint('│ 💬 Message: ${err.message ?? 'Unknown error'}');

    if (err.response != null) {
      debugPrint('├──────────────────────────────────────────────────────────');
      debugPrint('│ 📊 Status: ${err.response?.statusCode} ${err.response?.statusMessage ?? ''}');

      if (logResponseBody && err.response?.data != null) {
        debugPrint('├──────────────────────────────────────────────────────────');
        debugPrint('│ 📦 Error Response:');
        final bodyString = err.response!.data.toString();
        if (bodyString.length > maxLogLength) {
          debugPrint('│   ${bodyString.substring(0, maxLogLength)}...[truncated]');
        } else {
          debugPrint('│   $bodyString');
        }
      }
    }

    debugPrint('├──────────────────────────────────────────────────────────');
    debugPrint('│ 📚 Stack Trace:');
    final stackLines = err.stackTrace.toString().split('\n').take(5);
    for (final line in stackLines) {
      debugPrint('│   $line');
    }

    debugPrint('└──────────────────────────────────────────────────────────');

    handler.next(err);
  }

  /// 创建简化版拦截器（仅记录基本信息）
  factory LoggingInterceptor.simple() {
    return LoggingInterceptor(
      logHeaders: false,
      logRequestBody: false,
      logResponseBody: false,
    );
  }

  /// 创建详细版拦截器（记录所有信息）
  factory LoggingInterceptor.verbose() {
    return LoggingInterceptor(
      logHeaders: true,
      logRequestBody: true,
      logResponseBody: true,
      maxLogLength: 5000,
    );
  }
}
