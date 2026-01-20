import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 缓存策略枚举
enum CacheStrategy {
  /// 不使用缓存
  noCache,

  /// 先从缓存读取，如果缓存不存在或过期则请求网络
  cacheFirst,

  /// 先请求网络，失败时使用缓存（即使过期）
  networkFirst,

  /// 仅使用缓存，不请求网络
  cacheOnly,

  /// 仅请求网络，不使用缓存
  networkOnly,
}

/// 缓存项
class CacheItem {
  /// 响应数据
  final Response response;

  /// 缓存时间
  final DateTime cachedAt;

  /// 缓存有效期（秒）
  final int maxAge;

  CacheItem({
    required this.response,
    required this.cachedAt,
    required this.maxAge,
  });

  /// 是否过期
  bool get isExpired {
    final now = DateTime.now();
    final age = now.difference(cachedAt).inSeconds;
    return age > maxAge;
  }

  /// 剩余有效时间（秒）
  int get remainingAge {
    final now = DateTime.now();
    final age = now.difference(cachedAt).inSeconds;
    return maxAge - age;
  }
}

/// HTTP 缓存拦截器
///
/// 实现 HTTP 缓存策略，减少网络请求，提升应用性能
class CacheInterceptor extends Interceptor {
  /// 缓存存储
  final Map<String, CacheItem> _cache = {};

  /// 默认缓存有效期（秒）
  final int defaultMaxAge;

  /// 最大缓存条目数
  final int maxCacheSize;

  /// 默认缓存策略
  final CacheStrategy defaultStrategy;

  CacheInterceptor({
    this.defaultMaxAge = 300, // 5分钟
    this.maxCacheSize = 100,
    this.defaultStrategy = CacheStrategy.cacheFirst,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 只缓存 GET 请求
    if (options.method.toUpperCase() != 'GET') {
      handler.next(options);
      return;
    }

    // 获取缓存策略
    final strategy = _getCacheStrategy(options);

    // 如果策略是 networkOnly，直接请求网络
    if (strategy == CacheStrategy.networkOnly ||
        strategy == CacheStrategy.noCache) {
      handler.next(options);
      return;
    }

    // 生成缓存键
    final cacheKey = _generateCacheKey(options);

    // 获取缓存项
    final cachedItem = _cache[cacheKey];

    // 如果策略是 cacheOnly，仅使用缓存
    if (strategy == CacheStrategy.cacheOnly) {
      if (cachedItem != null) {
        if (kDebugMode) {
          debugPrint('📦 Cache HIT (cacheOnly): $cacheKey');
        }
        handler.resolve(cachedItem.response);
      } else {
        if (kDebugMode) {
          debugPrint('❌ Cache MISS (cacheOnly): $cacheKey');
        }
        handler.reject(
          DioException(
            requestOptions: options,
            error: 'No cache available',
            type: DioExceptionType.unknown,
          ),
        );
      }
      return;
    }

    // 如果策略是 cacheFirst，优先使用缓存
    if (strategy == CacheStrategy.cacheFirst) {
      if (cachedItem != null && !cachedItem.isExpired) {
        if (kDebugMode) {
          debugPrint(
            '📦 Cache HIT (cacheFirst): $cacheKey (age: ${cachedItem.remainingAge}s)',
          );
        }
        handler.resolve(cachedItem.response);
        return;
      } else if (cachedItem != null) {
        if (kDebugMode) {
          debugPrint('⏰ Cache EXPIRED (cacheFirst): $cacheKey');
        }
      }
    }

    // 如果策略是 networkFirst 或缓存不存在/过期，继续请求网络
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // 只缓存 GET 请求
    if (response.requestOptions.method.toUpperCase() != 'GET') {
      handler.next(response);
      return;
    }

    // 获取缓存策略
    final strategy = _getCacheStrategy(response.requestOptions);

    // 如果策略是 noCache 或 cacheOnly，不缓存响应
    if (strategy == CacheStrategy.noCache ||
        strategy == CacheStrategy.cacheOnly) {
      handler.next(response);
      return;
    }

    // 只缓存成功的响应
    if (response.statusCode == 200) {
      final cacheKey = _generateCacheKey(response.requestOptions);
      final maxAge = _getMaxAge(response.requestOptions);

      // 检查缓存大小，如果超过限制则清理最旧的缓存
      if (_cache.length >= maxCacheSize) {
        _evictOldestCache();
      }

      _cache[cacheKey] = CacheItem(
        response: response,
        cachedAt: DateTime.now(),
        maxAge: maxAge,
      );

      if (kDebugMode) {
        debugPrint('💾 Cache SAVED: $cacheKey (maxAge: ${maxAge}s)');
      }
    }

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // 只处理 GET 请求的错误
    if (err.requestOptions.method.toUpperCase() != 'GET') {
      handler.next(err);
      return;
    }

    // 获取缓存策略
    final strategy = _getCacheStrategy(err.requestOptions);

    // 如果策略是 networkFirst，且网络请求失败，尝试使用缓存（即使过期）
    if (strategy == CacheStrategy.networkFirst) {
      final cacheKey = _generateCacheKey(err.requestOptions);
      final cachedItem = _cache[cacheKey];

      if (cachedItem != null) {
        if (kDebugMode) {
          debugPrint(
            '🔄 Cache FALLBACK (networkFirst): $cacheKey (expired: ${cachedItem.isExpired})',
          );
        }
        handler.resolve(cachedItem.response);
        return;
      }
    }

    handler.next(err);
  }

  /// 生成缓存键
  String _generateCacheKey(RequestOptions options) {
    final uri = options.uri.toString();
    if (options.queryParameters.isEmpty) {
      return uri;
    }
    // 包含查询参数
    return uri;
  }

  /// 获取缓存策略
  CacheStrategy _getCacheStrategy(RequestOptions options) {
    final strategyName = options.extra['cacheStrategy'] as String?;
    if (strategyName != null) {
      try {
        return CacheStrategy.values.firstWhere(
          (e) => e.name == strategyName,
          orElse: () => defaultStrategy,
        );
      } catch (e) {
        return defaultStrategy;
      }
    }
    return defaultStrategy;
  }

  /// 获取缓存有效期
  int _getMaxAge(RequestOptions options) {
    final maxAge = options.extra['cacheMaxAge'] as int?;
    return maxAge ?? defaultMaxAge;
  }

  /// 清理最旧的缓存项
  void _evictOldestCache() {
    if (_cache.isEmpty) return;

    // 找到最旧的缓存项
    String? oldestKey;
    DateTime? oldestTime;

    _cache.forEach((key, item) {
      if (oldestTime == null || item.cachedAt.isBefore(oldestTime!)) {
        oldestKey = key;
        oldestTime = item.cachedAt;
      }
    });

    if (oldestKey != null) {
      _cache.remove(oldestKey);
      if (kDebugMode) {
        debugPrint('🗑️  Cache EVICTED (oldest): $oldestKey');
      }
    }
  }

  /// 清除所有缓存
  void clearAll() {
    _cache.clear();
    if (kDebugMode) {
      debugPrint('🗑️  Cache CLEARED (all)');
    }
  }

  /// 清除指定 URL 的缓存
  void clearByUrl(String url) {
    _cache.removeWhere((key, _) => key.contains(url));
    if (kDebugMode) {
      debugPrint('🗑️  Cache CLEARED (url): $url');
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    int expired = 0;
    int valid = 0;

    _cache.forEach((_, item) {
      if (item.isExpired) {
        expired++;
      } else {
        valid++;
      }
    });

    return {
      'total': _cache.length,
      'valid': valid,
      'expired': expired,
      'maxSize': maxCacheSize,
    };
  }
}

/// RequestOptions 扩展，用于设置缓存选项
extension CacheOptionsExtension on RequestOptions {
  /// 设置缓存策略
  RequestOptions withCacheStrategy(CacheStrategy strategy) {
    extra['cacheStrategy'] = strategy.name;
    return this;
  }

  /// 设置缓存有效期（秒）
  RequestOptions withCacheMaxAge(int maxAge) {
    extra['cacheMaxAge'] = maxAge;
    return this;
  }
}
