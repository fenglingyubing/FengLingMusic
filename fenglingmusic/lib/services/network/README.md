# 网络服务模块 (Network Service)

## 概述

网络服务模块提供了完整的 HTTP 请求功能，基于 Dio 实现，包含日志记录、缓存、重试等功能。

## 功能特性

### 1. Dio 客户端 (DioClient)

统一的 HTTP 客户端配置和管理。

#### 特性
- 单例模式
- 超时配置（连接、发送、接收）
- 统一错误处理
- 支持所有 HTTP 方法（GET、POST、PUT、DELETE、PATCH）
- 文件下载支持

#### 使用示例

```dart
import 'package:fenglingmusic/services/network/network.dart';

// 获取实例
final client = DioClient();

// GET 请求
final response = await client.get(
  'https://api.example.com/songs',
  queryParameters: {'page': 1, 'limit': 20},
);

// POST 请求
final response = await client.post(
  'https://api.example.com/songs',
  data: {'title': 'Song Title', 'artist': 'Artist Name'},
);

// 下载文件
await client.download(
  'https://api.example.com/songs/123/download',
  '/path/to/save/song.mp3',
  onReceiveProgress: (received, total) {
    print('Progress: ${(received / total * 100).toStringAsFixed(0)}%');
  },
);
```

### 2. 日志拦截器 (LoggingInterceptor)

记录所有 HTTP 请求和响应的详细信息。

#### 特性
- 仅在 Debug 模式下生效
- 记录请求/响应时间
- 记录请求头、查询参数、请求体
- 记录响应头、响应体
- 详细的错误日志
- 可配置日志级别

#### 配置

```dart
// 简化版日志（仅记录基本信息）
final loggingInterceptor = LoggingInterceptor.simple();

// 详细版日志（记录所有信息）
final loggingInterceptor = LoggingInterceptor.verbose();

// 自定义配置
final loggingInterceptor = LoggingInterceptor(
  logHeaders: true,
  logRequestBody: true,
  logResponseBody: true,
  maxLogLength: 1000,
);

// 添加到 DioClient
client.addInterceptor(loggingInterceptor);
```

#### 日志格式示例

```
┌──────────────────────────────────────────────────────────
│ 📤 REQUEST
├──────────────────────────────────────────────────────────
│ 🔗 GET https://api.example.com/songs?page=1
│ ⏰ 2026-01-21T10:30:45.123
├──────────────────────────────────────────────────────────
│ 📋 Headers:
│   Accept: application/json
│   User-Agent: FengLingMusic/1.0.0
└──────────────────────────────────────────────────────────

┌──────────────────────────────────────────────────────────
│ 📥 RESPONSE
├──────────────────────────────────────────────────────────
│ 🔗 GET https://api.example.com/songs?page=1
│ ⏰ 2026-01-21T10:30:45.456
│ ⏱️  Duration: 333ms
│ 📊 Status: 200 OK
└──────────────────────────────────────────────────────────
```

### 3. 缓存拦截器 (CacheInterceptor)

实现 HTTP 缓存策略，减少网络请求。

#### 特性
- 仅缓存 GET 请求
- 多种缓存策略
- 可配置缓存有效期
- LRU 缓存淘汰
- 缓存统计信息

#### 缓存策略

| 策略 | 说明 |
|------|------|
| `noCache` | 不使用缓存 |
| `cacheFirst` | 优先使用缓存，缓存不存在或过期时请求网络 |
| `networkFirst` | 优先请求网络，失败时使用缓存（即使过期） |
| `cacheOnly` | 仅使用缓存，不请求网络 |
| `networkOnly` | 仅请求网络，不使用缓存 |

#### 使用示例

```dart
// 配置缓存拦截器
final cacheInterceptor = CacheInterceptor(
  defaultMaxAge: 300, // 默认缓存5分钟
  maxCacheSize: 100, // 最多缓存100个条目
  defaultStrategy: CacheStrategy.cacheFirst,
);

// 使用默认策略的请求
final response = await client.get('https://api.example.com/songs');

// 自定义缓存策略
final response = await client.dio.get(
  'https://api.example.com/songs',
  options: Options().withCacheStrategy(CacheStrategy.networkFirst),
);

// 自定义缓存有效期（秒）
final response = await client.dio.get(
  'https://api.example.com/songs',
  options: Options()
    .withCacheStrategy(CacheStrategy.cacheFirst)
    .withCacheMaxAge(600), // 缓存10分钟
);

// 清除所有缓存
client.cacheInterceptor.clearAll();

// 清除特定 URL 的缓存
client.cacheInterceptor.clearByUrl('https://api.example.com/songs');

// 获取缓存统计
final stats = client.cacheInterceptor.getCacheStats();
print('Total: ${stats['total']}, Valid: ${stats['valid']}, Expired: ${stats['expired']}');
```

### 4. 重试拦截器 (RetryInterceptor)

当请求失败时自动重试。

#### 特性
- 可配置最大重试次数
- 多种重试策略（固定延迟、指数退避、线性增长）
- 仅重试可恢复的错误
- 默认仅重试 GET 请求
- 可配置重试延迟

#### 重试策略

| 策略 | 说明 | 延迟计算 |
|------|------|----------|
| `fixed` | 固定延迟 | baseDelay |
| `exponentialBackoff` | 指数退避 | baseDelay * 2^retryCount + jitter |
| `linear` | 线性增长 | baseDelay * (retryCount + 1) |

#### 配置

```dart
// 默认配置
final retryConfig = RetryConfig.defaults(); // 3次重试，指数退避

// 激进配置（更多重试）
final retryConfig = RetryConfig.aggressive(); // 5次重试

// 保守配置（更少重试）
final retryConfig = RetryConfig.conservative(); // 2次重试

// 禁用重试
final retryConfig = RetryConfig.disabled(); // 0次重试

// 自定义配置
final retryConfig = RetryConfig(
  maxRetries: 3,
  strategy: RetryStrategy.exponentialBackoff,
  baseDelay: 1000, // 基础延迟1秒
  maxDelay: 10000, // 最大延迟10秒
  retryableStatusCodes: {408, 429, 500, 502, 503, 504},
  retryableExceptionTypes: {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  },
);

final retryInterceptor = RetryInterceptor(
  dio: client.dio,
  config: retryConfig,
);
```

#### 使用示例

```dart
// 禁用单个请求的重试
final response = await client.dio.get(
  'https://api.example.com/songs',
  options: Options().withoutRetry(),
);

// 允许对 POST 请求进行重试（默认仅 GET）
final response = await client.dio.post(
  'https://api.example.com/songs',
  data: songData,
  options: Options().withRetryForAnyMethod(),
);

// 自定义单个请求的最大重试次数
final response = await client.dio.get(
  'https://api.example.com/songs',
  options: Options().withMaxRetries(5),
);
```

## 错误处理

DioClient 提供统一的错误处理，将 Dio 异常转换为友好的错误消息：

| 错误类型 | 错误消息 |
|----------|----------|
| 连接超时 | 连接超时，请检查网络 |
| 发送超时 | 请求发送超时 |
| 接收超时 | 响应超时 |
| 400 | 请求参数错误 |
| 401 | 未授权，请重新登录 |
| 403 | 拒绝访问 |
| 404 | 请求的资源不存在 |
| 500 | 服务器内部错误 |
| 502 | 网关错误 |
| 503 | 服务不可用 |

### 错误处理示例

```dart
try {
  final response = await client.get('https://api.example.com/songs');
  // 处理响应
} catch (e) {
  // 显示错误消息
  print('Error: $e');
}
```

## 完整示例

```dart
import 'package:fenglingmusic/services/network/network.dart';

class MusicService {
  final DioClient _client = DioClient();

  Future<List<Song>> searchSongs(String keyword) async {
    try {
      final response = await _client.get(
        'https://api.example.com/search',
        queryParameters: {'keyword': keyword},
      );

      return (response.data as List)
          .map((json) => Song.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('搜索歌曲失败: $e');
    }
  }

  Future<void> downloadSong(String url, String savePath) async {
    try {
      await _client.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          final progress = (received / total * 100).toStringAsFixed(0);
          print('下载进度: $progress%');
        },
      );
    } catch (e) {
      throw Exception('下载歌曲失败: $e');
    }
  }
}
```

## 最佳实践

1. **单例模式**: 使用 `DioClient()` 获取单例实例，避免创建多个实例
2. **缓存策略**: 根据数据更新频率选择合适的缓存策略
3. **重试策略**: 对于重要的请求使用重试，但避免对写操作（POST/PUT/DELETE）进行重试
4. **错误处理**: 始终使用 try-catch 处理网络请求
5. **日志记录**: 在开发阶段启用详细日志，生产环境关闭
6. **超时配置**: 根据网络环境调整超时时间

## 注意事项

1. 日志拦截器仅在 Debug 模式（`kDebugMode`）下生效
2. 缓存拦截器仅缓存 GET 请求
3. 重试拦截器默认仅重试 GET 请求，可通过 `withRetryForAnyMethod()` 启用其他方法
4. 缓存使用内存存储，应用重启后缓存会丢失
5. 拦截器的执行顺序很重要，重试拦截器应该在最后

## 文件结构

```
lib/services/network/
├── dio_client.dart           # Dio 客户端
├── logging_interceptor.dart  # 日志拦截器
├── cache_interceptor.dart    # 缓存拦截器
├── retry_interceptor.dart    # 重试拦截器
├── network.dart              # 导出文件
└── README.md                 # 本文档
```
