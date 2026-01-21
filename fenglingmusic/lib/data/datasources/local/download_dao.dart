import 'package:sqflite/sqflite.dart';
import '../../models/download_item_model.dart';
import 'database_helper.dart';

/// Data Access Object for Download Items
/// Handles all database operations related to downloads
///
/// TASK-091 到 TASK-094: 下载队列管理数据层
class DownloadDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a download item
  Future<int> insert(DownloadItemModel item) async {
    final Database db = await _dbHelper.database;
    return await db.insert(
      'download_queue',
      item.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update a download item
  Future<int> update(DownloadItemModel item) async {
    final Database db = await _dbHelper.database;
    return await db.update(
      'download_queue',
      item.toDatabase(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Delete a download item
  Future<int> delete(int id) async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'download_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get a download item by ID
  Future<DownloadItemModel?> findById(int id) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'download_queue',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return DownloadItemModel.fromDatabase(results.first);
  }

  /// Get all download items
  Future<List<DownloadItemModel>> findAll({
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'download_queue',
      orderBy: 'date_added DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => DownloadItemModel.fromDatabase(map)).toList();
  }

  /// Get download items by status
  Future<List<DownloadItemModel>> findByStatus(DownloadStatus status) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'download_queue',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'date_added DESC',
    );

    return results.map((map) => DownloadItemModel.fromDatabase(map)).toList();
  }

  /// Get downloading items (active downloads)
  Future<List<DownloadItemModel>> findActiveDownloads() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'download_queue',
      where: 'status IN (?, ?)',
      whereArgs: [
        DownloadStatus.downloading.name,
        DownloadStatus.pending.name,
      ],
      orderBy: 'date_added ASC',
    );

    return results.map((map) => DownloadItemModel.fromDatabase(map)).toList();
  }

  /// Get completed downloads
  Future<List<DownloadItemModel>> findCompleted({
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'download_queue',
      where: 'status = ?',
      whereArgs: [DownloadStatus.completed.name],
      orderBy: 'date_completed DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => DownloadItemModel.fromDatabase(map)).toList();
  }

  /// Get failed downloads
  Future<List<DownloadItemModel>> findFailed() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'download_queue',
      where: 'status = ?',
      whereArgs: [DownloadStatus.failed.name],
      orderBy: 'date_added DESC',
    );

    return results.map((map) => DownloadItemModel.fromDatabase(map)).toList();
  }

  /// Update download progress
  Future<int> updateProgress(int id, int downloadedSize) async {
    final Database db = await _dbHelper.database;
    return await db.update(
      'download_queue',
      {
        'downloaded_size': downloadedSize,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update download status
  Future<int> updateStatus(int id, DownloadStatus status, {String? errorMessage}) async {
    final Database db = await _dbHelper.database;
    final Map<String, dynamic> updates = {
      'status': status.name,
    };

    if (status == DownloadStatus.downloading && errorMessage == null) {
      updates['date_started'] = DateTime.now().millisecondsSinceEpoch;
    } else if (status == DownloadStatus.completed) {
      updates['date_completed'] = DateTime.now().millisecondsSinceEpoch;
    } else if (status == DownloadStatus.failed && errorMessage != null) {
      updates['error_message'] = errorMessage;
    }

    return await db.update(
      'download_queue',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear completed downloads
  Future<int> clearCompleted() async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'download_queue',
      where: 'status = ?',
      whereArgs: [DownloadStatus.completed.name],
    );
  }

  /// Clear failed downloads
  Future<int> clearFailed() async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'download_queue',
      where: 'status = ?',
      whereArgs: [DownloadStatus.failed.name],
    );
  }

  /// Clear all downloads
  Future<int> clearAll() async {
    final Database db = await _dbHelper.database;
    return await db.delete('download_queue');
  }

  /// Get download count by status
  Future<int> countByStatus(DownloadStatus status) async {
    final Database db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM download_queue WHERE status = ?',
      [status.name],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total download count
  Future<int> count() async {
    final Database db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM download_queue');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get download statistics
  Future<Map<String, int>> getStatistics() async {
    final total = await count();
    final pending = await countByStatus(DownloadStatus.pending);
    final downloading = await countByStatus(DownloadStatus.downloading);
    final paused = await countByStatus(DownloadStatus.paused);
    final completed = await countByStatus(DownloadStatus.completed);
    final failed = await countByStatus(DownloadStatus.failed);
    final cancelled = await countByStatus(DownloadStatus.cancelled);

    return {
      'total': total,
      'pending': pending,
      'downloading': downloading,
      'paused': paused,
      'completed': completed,
      'failed': failed,
      'cancelled': cancelled,
    };
  }
}
