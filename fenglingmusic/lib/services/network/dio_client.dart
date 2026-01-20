import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'cache_interceptor.dart';
import 'logging_interceptor.dart';
import 'retry_interceptor.dart';

/// Dio HTTP 客户端配置类
///
/// 提供统一的网络请求配置和管理
class DioClient {
  static DioClient? _instance;
  late final Dio _dio;
  late final CacheInterceptor _cacheInterceptor;
  late final RetryInterceptor _retryInterceptor;

  /// 单例模式获取实例
  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  /// 私有构造函数
  DioClient._internal() {
    _dio = Dio(_getBaseOptions());
    _initializeInterceptors();
  }

  /// 获取 Dio 实例
  Dio get dio => _dio;

  /// 获取缓存拦截器实例（用于缓存管理）
  CacheInterceptor get cacheInterceptor => _cacheInterceptor;

  /// 基础配置
  BaseOptions _getBaseOptions() {
    return BaseOptions(
      // 连接超时时间
      connectTimeout: const Duration(seconds: 15),
      // 接收超时时间
      receiveTimeout: const Duration(seconds: 30),
      // 发送超时时间
      sendTimeout: const Duration(seconds: 30),
      // 响应类型
      responseType: ResponseType.json,
      // 请求内容类型
      contentType: Headers.jsonContentType,
      // 通用请求头
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'FengLingMusic/1.0.0',
      },
    );
  }

  /// 初始化拦截器
  void _initializeInterceptors() {
    // 1. 日志拦截器（Debug 模式）
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor.verbose());
    }

    // 2. 缓存拦截器
    _cacheInterceptor = CacheInterceptor(
      defaultMaxAge: 300, // 5分钟
      maxCacheSize: 100,
      defaultStrategy: CacheStrategy.cacheFirst,
    );
    _dio.interceptors.add(_cacheInterceptor);

    // 3. 重试拦截器（必须在最后，这样才能重试整个请求链）
    _retryInterceptor = RetryInterceptor(
      dio: _dio,
      config: RetryConfig.defaults(),
    );
    _dio.interceptors.add(_retryInterceptor);
  }

  /// 添加拦截器
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// 移除拦截器
  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }

  /// GET 请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH 请求
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 下载文件
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 错误处理
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('连接超时，请检查网络');
      case DioExceptionType.sendTimeout:
        return Exception('请求发送超时');
      case DioExceptionType.receiveTimeout:
        return Exception('响应超时');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return Exception('请求参数错误');
          case 401:
            return Exception('未授权，请重新登录');
          case 403:
            return Exception('拒绝访问');
          case 404:
            return Exception('请求的资源不存在');
          case 500:
            return Exception('服务器内部错误');
          case 502:
            return Exception('网关错误');
          case 503:
            return Exception('服务不可用');
          default:
            return Exception('请求失败: $statusCode');
        }
      case DioExceptionType.cancel:
        return Exception('请求已取消');
      case DioExceptionType.badCertificate:
        return Exception('证书验证失败');
      case DioExceptionType.connectionError:
        return Exception('网络连接失败，请检查网络');
      case DioExceptionType.unknown:
        return Exception('网络请求失败: ${error.message}');
    }
  }

  /// 清理资源
  void dispose() {
    _dio.close();
  }
}
