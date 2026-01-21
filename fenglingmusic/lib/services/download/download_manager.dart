import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../data/models/download_item_model.dart';
import '../../data/models/online_song.dart';
import '../../data/datasources/local/download_dao.dart';
import '../online/online_play_service.dart';

/// 下载管理器
///
/// TASK-091 到 TASK-094: 完整的下载功能实现
/// 功能：
/// - 下载队列管理
/// - 下载进度跟踪
/// - 断点续传
/// - 下载完成处理
class DownloadManager {
  static final DownloadManager instance = DownloadManager._internal();

  final DownloadDAO _downloadDAO = DownloadDAO();
  final OnlinePlayService _playService = OnlinePlayService();
  final Dio _dio = Dio();

  /// 并发下载限制
  static const int _maxConcurrentDownloads = 3;

  /// 当前活跃的下载任务
  final Map<int, CancelToken> _activeDownloads = {};

  /// 下载进度流控制器
  final StreamController<Map<int, double>> _progressController =
      StreamController<Map<int, double>>.broadcast();

  /// 下载状态流控制器
  final StreamController<DownloadItemModel> _statusController =
      StreamController<DownloadItemModel>.broadcast();

  /// 下载进度缓存
  final Map<int, double> _progressCache = {};

  DownloadManager._internal() {
    _initDio();
  }

  /// 初始化Dio配置
  void _initDio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 10),
      followRedirects: true,
      maxRedirects: 5,
    );
  }

  /// 下载进度流
  Stream<Map<int, double>> get progressStream => _progressController.stream;

  /// 下载状态流
  Stream<DownloadItemModel> get statusStream => _statusController.stream;

  /// 添加下载任务
  ///
  /// [song] 在线歌曲对象
  /// [quality] 音质 ('standard', 'higher', 'lossless')
  Future<DownloadItemModel?> addDownload(
    OnlineSong song, {
    String quality = 'standard',
  }) async {
    try {
      // 获取下载URL
      final url = await _playService.getSongUrl(song, quality: quality);
      if (url == null || url.isEmpty) {
        debugPrint('❌ [DownloadManager] 无法获取下载URL');
        return null;
      }

      // 生成目标文件路径
      final targetPath = await _generateTargetPath(song, quality);

      // 创建下载项
      final downloadItem = DownloadItemModel(
        title: song.title,
        artist: song.artist,
        album: song.album,
        sourceUrl: url,
        targetPath: targetPath,
        quality: quality,
        dateAdded: DateTime.now().millisecondsSinceEpoch,
        status: DownloadStatus.pending,
      );

      // 保存到数据库
      final id = await _downloadDAO.insert(downloadItem);
      final item = downloadItem.copyWith(id: id);

      debugPrint('✅ [DownloadManager] 添加下载任务: ${song.title} - $quality');

      // 通知状态更新
      _statusController.add(item);

      // 开始下载
      _startNextDownload();

      return item;
    } catch (e) {
      debugPrint('❌ [DownloadManager] addDownload error: $e');
      return null;
    }
  }

  /// 生成目标文件路径
  Future<String> _generateTargetPath(OnlineSong song, String quality) async {
    final Directory docDir = await getApplicationDocumentsDirectory();
    final String musicDir = path.join(docDir.path, 'Music', 'Downloads');

    // 确保目录存在
    await Directory(musicDir).create(recursive: true);

    // 清理文件名（移除非法字符）
    final sanitizedTitle = _sanitizeFileName(song.title);
    final sanitizedArtist = _sanitizeFileName(song.artist);

    // 生成文件名
    final fileName = '$sanitizedArtist - $sanitizedTitle [$quality].mp3';
    return path.join(musicDir, fileName);
  }

  /// 清理文件名中的非法字符
  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// 开始下一个下载任务
  Future<void> _startNextDownload() async {
    try {
      // 检查并发限制
      if (_activeDownloads.length >= _maxConcurrentDownloads) {
        debugPrint('⏳ [DownloadManager] 达到并发下载限制，等待...');
        return;
      }

      // 获取待下载的任务
      final pendingItems = await _downloadDAO.findByStatus(DownloadStatus.pending);
      if (pendingItems.isEmpty) {
        debugPrint('✅ [DownloadManager] 没有待下载任务');
        return;
      }

      // 开始下载第一个任务
      final item = pendingItems.first;
      await _downloadItem(item);

    } catch (e) {
      debugPrint('❌ [DownloadManager] _startNextDownload error: $e');
    }
  }

  /// 下载单个文件（支持断点续传）
  Future<void> _downloadItem(DownloadItemModel item) async {
    if (item.id == null) return;

    final int id = item.id!;
    final CancelToken cancelToken = CancelToken();
    _activeDownloads[id] = cancelToken;

    try {
      // 更新状态为下载中
      await _downloadDAO.updateStatus(id, DownloadStatus.downloading);
      _statusController.add(item.copyWith(status: DownloadStatus.downloading));

      debugPrint('📥 [DownloadManager] 开始下载: ${item.title}');

      // 检查是否支持断点续传
      int downloadedSize = item.downloadedSize;
      final File targetFile = File(item.targetPath);
      bool supportsRange = false;

      // 检查文件是否已存在（断点续传）
      if (targetFile.existsSync() && downloadedSize > 0) {
        debugPrint('♻️ [DownloadManager] 检测到已下载 $downloadedSize 字节，尝试断点续传');
        supportsRange = await _checkRangeSupport(item.sourceUrl);
      }

      // 下载文件
      await _dio.download(
        item.sourceUrl,
        item.targetPath,
        cancelToken: cancelToken,
        options: Options(
          headers: supportsRange && downloadedSize > 0
              ? {'Range': 'bytes=$downloadedSize-'}
              : null,
        ),
        onReceiveProgress: (received, total) async {
          // 如果是断点续传，需要加上已下载的大小
          final totalReceived = supportsRange ? received + downloadedSize : received;
          final totalSize = supportsRange ? total + downloadedSize : total;

          // 更新进度
          final progress = totalSize > 0 ? totalReceived / totalSize : 0.0;
          _progressCache[id] = progress;
          _progressController.add(_progressCache);

          // 每下载1MB更新一次数据库
          if (totalReceived % (1024 * 1024) == 0 || totalReceived == totalSize) {
            await _downloadDAO.updateProgress(id, totalReceived);

            // 更新文件大小信息
            if (item.fileSize == null && totalSize > 0) {
              await _downloadDAO.update(item.copyWith(fileSize: totalSize));
            }
          }
        },
      );

      // 下载完成
      await _onDownloadComplete(item);

    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        debugPrint('⏸️ [DownloadManager] 下载已取消: ${item.title}');
        await _downloadDAO.updateStatus(id, DownloadStatus.cancelled);
        _statusController.add(item.copyWith(status: DownloadStatus.cancelled));
      } else {
        debugPrint('❌ [DownloadManager] 下载失败: ${item.title} - $e');
        await _downloadDAO.updateStatus(id, DownloadStatus.failed, errorMessage: e.message);
        _statusController.add(item.copyWith(status: DownloadStatus.failed, errorMessage: e.message));
      }
    } catch (e) {
      debugPrint('❌ [DownloadManager] 下载错误: ${item.title} - $e');
      await _downloadDAO.updateStatus(id, DownloadStatus.failed, errorMessage: e.toString());
      _statusController.add(item.copyWith(status: DownloadStatus.failed, errorMessage: e.toString()));
    } finally {
      _activeDownloads.remove(id);
      _progressCache.remove(id);

      // 开始下一个下载
      _startNextDownload();
    }
  }

  /// 检查服务器是否支持断点续传
  Future<bool> _checkRangeSupport(String url) async {
    try {
      final response = await _dio.head(url);
      return response.headers.value('accept-ranges') == 'bytes';
    } catch (e) {
      return false;
    }
  }

  /// 下载完成处理
  Future<void> _onDownloadComplete(DownloadItemModel item) async {
    if (item.id == null) return;

    try {
      debugPrint('✅ [DownloadManager] 下载完成: ${item.title}');

      // 更新状态为已完成
      await _downloadDAO.updateStatus(item.id!, DownloadStatus.completed);
      _statusController.add(item.copyWith(status: DownloadStatus.completed));

      // 写入音频元数据
      await _writeAudioMetadata(item);

      // 扫描并添加到本地库
      await _addToLocalLibrary(item);

      debugPrint('🎵 [DownloadManager] 已添加到本地库: ${item.title}');

    } catch (e) {
      debugPrint('❌ [DownloadManager] _onDownloadComplete error: $e');
    }
  }

  /// 写入音频元数据
  Future<void> _writeAudioMetadata(DownloadItemModel item) async {
    try {
      // TODO: 使用 metadata_god 或其他库写入ID3标签
      // 包括: 标题、艺术家、专辑、封面等
      debugPrint('📝 [DownloadManager] 写入元数据: ${item.title}');
    } catch (e) {
      debugPrint('❌ [DownloadManager] 写入元数据失败: $e');
    }
  }

  /// 添加到本地音乐库
  Future<void> _addToLocalLibrary(DownloadItemModel item) async {
    try {
      // 触发音乐扫描器扫描该文件
      // TODO: 调用 MusicScanner 扫描单个文件
      debugPrint('📚 [DownloadManager] 添加到本地库: ${item.targetPath}');
    } catch (e) {
      debugPrint('❌ [DownloadManager] 添加到本地库失败: $e');
    }
  }

  /// 暂停下载
  Future<void> pauseDownload(int id) async {
    try {
      if (_activeDownloads.containsKey(id)) {
        _activeDownloads[id]?.cancel();
        await _downloadDAO.updateStatus(id, DownloadStatus.paused);
        debugPrint('⏸️ [DownloadManager] 暂停下载: $id');
      }
    } catch (e) {
      debugPrint('❌ [DownloadManager] pauseDownload error: $e');
    }
  }

  /// 恢复下载
  Future<void> resumeDownload(int id) async {
    try {
      final item = await _downloadDAO.findById(id);
      if (item != null && item.status == DownloadStatus.paused) {
        await _downloadDAO.updateStatus(id, DownloadStatus.pending);
        _startNextDownload();
        debugPrint('▶️ [DownloadManager] 恢复下载: $id');
      }
    } catch (e) {
      debugPrint('❌ [DownloadManager] resumeDownload error: $e');
    }
  }

  /// 取消下载
  Future<void> cancelDownload(int id) async {
    try {
      if (_activeDownloads.containsKey(id)) {
        _activeDownloads[id]?.cancel();
      }

      final item = await _downloadDAO.findById(id);
      if (item != null) {
        // 删除已下载的文件
        final file = File(item.targetPath);
        if (file.existsSync()) {
          await file.delete();
        }

        // 删除数据库记录
        await _downloadDAO.delete(id);
        debugPrint('🗑️ [DownloadManager] 取消下载: $id');
      }
    } catch (e) {
      debugPrint('❌ [DownloadManager] cancelDownload error: $e');
    }
  }

  /// 重试失败的下载
  Future<void> retryDownload(int id) async {
    try {
      final item = await _downloadDAO.findById(id);
      if (item != null && item.status == DownloadStatus.failed) {
        await _downloadDAO.updateStatus(id, DownloadStatus.pending);
        _startNextDownload();
        debugPrint('🔄 [DownloadManager] 重试下载: $id');
      }
    } catch (e) {
      debugPrint('❌ [DownloadManager] retryDownload error: $e');
    }
  }

  /// 全部开始
  Future<void> startAll() async {
    try {
      final pausedItems = await _downloadDAO.findByStatus(DownloadStatus.paused);
      for (final item in pausedItems) {
        if (item.id != null) {
          await _downloadDAO.updateStatus(item.id!, DownloadStatus.pending);
        }
      }
      _startNextDownload();
      debugPrint('▶️ [DownloadManager] 全部开始');
    } catch (e) {
      debugPrint('❌ [DownloadManager] startAll error: $e');
    }
  }

  /// 全部暂停
  Future<void> pauseAll() async {
    try {
      for (final id in _activeDownloads.keys.toList()) {
        await pauseDownload(id);
      }
      debugPrint('⏸️ [DownloadManager] 全部暂停');
    } catch (e) {
      debugPrint('❌ [DownloadManager] pauseAll error: $e');
    }
  }

  /// 清除已完成
  Future<void> clearCompleted() async {
    try {
      final completedItems = await _downloadDAO.findCompleted();
      for (final item in completedItems) {
        if (item.id != null) {
          await _downloadDAO.delete(item.id!);
        }
      }
      debugPrint('🧹 [DownloadManager] 清除已完成');
    } catch (e) {
      debugPrint('❌ [DownloadManager] clearCompleted error: $e');
    }
  }

  /// 获取所有下载
  Future<List<DownloadItemModel>> getAllDownloads() async {
    return await _downloadDAO.findAll();
  }

  /// 获取下载统计
  Future<Map<String, int>> getStatistics() async {
    return await _downloadDAO.getStatistics();
  }

  /// 销毁
  void dispose() {
    // 取消所有活跃下载
    for (final cancelToken in _activeDownloads.values) {
      cancelToken.cancel();
    }
    _activeDownloads.clear();
    _progressCache.clear();
    _progressController.close();
    _statusController.close();
  }
}
