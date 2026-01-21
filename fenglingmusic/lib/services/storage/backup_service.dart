import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/hive/hive_helper.dart';

/// 备份进度回调
typedef BackupProgressCallback = void Function(String message, double progress);

/// 恢复备份进度回调
typedef RestoreProgressCallback = void Function(String message, double progress);

/// 数据备份和恢复服务
///
/// 功能：
/// - 导出SQLite数据库
/// - 导出Hive设置
/// - 导出播放列表
/// - 压缩为备份文件
/// - 恢复备份数据
/// - 数据合并和冲突处理
class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  /// 备份文件扩展名
  static const String backupExtension = '.flmbackup';

  /// 备份文件内部结构
  static const String _dbFileName = 'database.db';
  static const String _settingsFileName = 'settings.json';
  static const String _playerStateFileName = 'player_state.json';
  static const String _cacheFileName = 'cache.json';
  static const String _metadataFileName = 'metadata.json';

  /// 创建完整备份
  ///
  /// 返回备份文件路径
  Future<String> createBackup({
    BackupProgressCallback? onProgress,
  }) async {
    try {
      onProgress?.call('准备创建备份...', 0.0);

      // 获取临时目录用于创建备份文件
      final tempDir = await getTemporaryDirectory();
      final backupTempDir = Directory(p.join(tempDir.path, 'backup_temp_${DateTime.now().millisecondsSinceEpoch}'));

      if (await backupTempDir.exists()) {
        await backupTempDir.delete(recursive: true);
      }
      await backupTempDir.create(recursive: true);

      // 1. 导出数据库 (30%)
      onProgress?.call('导出数据库...', 0.1);
      await _exportDatabase(backupTempDir);
      onProgress?.call('数据库导出完成', 0.3);

      // 2. 导出Hive数据 (20%)
      onProgress?.call('导出应用设置...', 0.3);
      await _exportHiveData(backupTempDir);
      onProgress?.call('设置导出完成', 0.5);

      // 3. 创建元数据 (10%)
      onProgress?.call('创建备份元数据...', 0.5);
      await _createMetadata(backupTempDir);
      onProgress?.call('元数据创建完成', 0.6);

      // 4. 压缩备份 (40%)
      onProgress?.call('压缩备份文件...', 0.6);
      final backupFilePath = await _compressBackup(backupTempDir);
      onProgress?.call('备份压缩完成', 1.0);

      // 清理临时文件
      if (await backupTempDir.exists()) {
        await backupTempDir.delete(recursive: true);
      }

      onProgress?.call('备份创建完成！', 1.0);
      return backupFilePath;
    } catch (e) {
      throw Exception('创建备份失败: $e');
    }
  }

  /// 恢复备份
  ///
  /// [backupFilePath] 备份文件路径
  /// [mergeStrategy] 合并策略: 'replace' (替换), 'merge' (合并), 'skip' (跳过冲突)
  Future<void> restoreBackup(
    String backupFilePath, {
    String mergeStrategy = 'merge',
    RestoreProgressCallback? onProgress,
  }) async {
    try {
      onProgress?.call('准备恢复备份...', 0.0);

      // 验证备份文件
      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) {
        throw Exception('备份文件不存在');
      }

      // 获取临时目录用于解压
      final tempDir = await getTemporaryDirectory();
      final restoreTempDir = Directory(p.join(tempDir.path, 'restore_temp_${DateTime.now().millisecondsSinceEpoch}'));

      if (await restoreTempDir.exists()) {
        await restoreTempDir.delete(recursive: true);
      }
      await restoreTempDir.create(recursive: true);

      // 1. 解压备份 (20%)
      onProgress?.call('解压备份文件...', 0.0);
      await _extractBackup(backupFilePath, restoreTempDir);
      onProgress?.call('备份解压完成', 0.2);

      // 2. 验证备份内容 (10%)
      onProgress?.call('验证备份内容...', 0.2);
      await _validateBackup(restoreTempDir);
      onProgress?.call('备份验证通过', 0.3);

      // 3. 恢复数据库 (40%)
      onProgress?.call('恢复数据库...', 0.3);
      await _restoreDatabase(restoreTempDir, mergeStrategy);
      onProgress?.call('数据库恢复完成', 0.7);

      // 4. 恢复Hive数据 (20%)
      onProgress?.call('恢复应用设置...', 0.7);
      await _restoreHiveData(restoreTempDir, mergeStrategy);
      onProgress?.call('设置恢复完成', 0.9);

      // 5. 清理临时文件 (10%)
      onProgress?.call('清理临时文件...', 0.9);
      if (await restoreTempDir.exists()) {
        await restoreTempDir.delete(recursive: true);
      }

      onProgress?.call('备份恢复完成！', 1.0);
    } catch (e) {
      throw Exception('恢复备份失败: $e');
    }
  }

  /// 获取备份信息
  Future<Map<String, dynamic>> getBackupInfo(String backupFilePath) async {
    try {
      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) {
        throw Exception('备份文件不存在');
      }

      // 解压到临时目录读取元数据
      final tempDir = await getTemporaryDirectory();
      final tempExtractDir = Directory(p.join(tempDir.path, 'backup_info_${DateTime.now().millisecondsSinceEpoch}'));

      await _extractBackup(backupFilePath, tempExtractDir);

      final metadataFile = File(p.join(tempExtractDir.path, _metadataFileName));
      if (!await metadataFile.exists()) {
        throw Exception('备份文件损坏：缺少元数据');
      }

      final metadataJson = await metadataFile.readAsString();
      final metadata = json.decode(metadataJson) as Map<String, dynamic>;

      // 清理临时文件
      if (await tempExtractDir.exists()) {
        await tempExtractDir.delete(recursive: true);
      }

      return metadata;
    } catch (e) {
      throw Exception('读取备份信息失败: $e');
    }
  }

  /// 导出SQLite数据库
  Future<void> _exportDatabase(Directory backupDir) async {
    final db = await DatabaseHelper.instance.database;
    final dbPath = db.path;

    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      throw Exception('数据库文件不存在');
    }

    final targetPath = p.join(backupDir.path, _dbFileName);
    await dbFile.copy(targetPath);
  }

  /// 导出Hive数据
  Future<void> _exportHiveData(Directory backupDir) async {
    // 导出settings box
    final settingsBox = HiveHelper.instance.settingsBox;
    final settingsMap = Map<String, dynamic>.from(settingsBox.toMap());
    final settingsFile = File(p.join(backupDir.path, _settingsFileName));
    await settingsFile.writeAsString(json.encode(settingsMap));

    // 导出player_state box
    final playerStateBox = HiveHelper.instance.playerStateBox;
    final playerStateMap = Map<String, dynamic>.from(playerStateBox.toMap());
    final playerStateFile = File(p.join(backupDir.path, _playerStateFileName));
    await playerStateFile.writeAsString(json.encode(playerStateMap));

    // 导出cache box
    final cacheBox = HiveHelper.instance.cacheBox;
    final cacheMap = Map<String, dynamic>.from(cacheBox.toMap());
    final cacheFile = File(p.join(backupDir.path, _cacheFileName));
    await cacheFile.writeAsString(json.encode(cacheMap));
  }

  /// 创建备份元数据
  Future<void> _createMetadata(Directory backupDir) async {
    final metadata = {
      'version': '1.0.0',
      'app_version': '1.0.0', // TODO: 从pubspec.yaml获取
      'created_at': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'files': [
        _dbFileName,
        _settingsFileName,
        _playerStateFileName,
        _cacheFileName,
      ],
    };

    final metadataFile = File(p.join(backupDir.path, _metadataFileName));
    await metadataFile.writeAsString(json.encode(metadata));
  }

  /// 压缩备份文件
  Future<String> _compressBackup(Directory backupDir) async {
    // 获取Documents目录用于保存备份
    final docsDir = await getApplicationDocumentsDirectory();
    final backupsDir = Directory(p.join(docsDir.path, 'Backups'));
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }

    // 生成备份文件名
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupFileName = 'FLMusic_Backup_$timestamp$backupExtension';
    final backupFilePath = p.join(backupsDir.path, backupFileName);

    // 创建zip压缩
    final encoder = ZipFileEncoder();
    encoder.create(backupFilePath);

    // 添加所有文件到zip
    await encoder.addDirectory(backupDir);

    encoder.close();

    return backupFilePath;
  }

  /// 解压备份文件
  Future<void> _extractBackup(String backupFilePath, Directory targetDir) async {
    final bytes = await File(backupFilePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // 解压所有文件
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        final outFile = File(p.join(targetDir.path, filename));
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data);
      } else {
        await Directory(p.join(targetDir.path, filename)).create(recursive: true);
      }
    }
  }

  /// 验证备份内容
  Future<void> _validateBackup(Directory backupDir) async {
    // 检查必要文件是否存在
    final requiredFiles = [
      _metadataFileName,
      _dbFileName,
      _settingsFileName,
    ];

    for (final fileName in requiredFiles) {
      final file = File(p.join(backupDir.path, fileName));
      if (!await file.exists()) {
        throw Exception('备份文件损坏：缺少 $fileName');
      }
    }

    // 验证元数据
    final metadataFile = File(p.join(backupDir.path, _metadataFileName));
    final metadataJson = await metadataFile.readAsString();
    final metadata = json.decode(metadataJson) as Map<String, dynamic>;

    if (!metadata.containsKey('version') || !metadata.containsKey('created_at')) {
      throw Exception('备份元数据格式错误');
    }
  }

  /// 恢复数据库
  Future<void> _restoreDatabase(Directory backupDir, String mergeStrategy) async {
    final backupDbFile = File(p.join(backupDir.path, _dbFileName));

    if (mergeStrategy == 'replace') {
      // 完全替换策略：关闭当前数据库，替换文件
      final db = await DatabaseHelper.instance.database;
      final currentDbPath = db.path;

      await db.close();
      await backupDbFile.copy(currentDbPath);

      // 重新初始化数据库
      await DatabaseHelper.instance.database;
    } else {
      // 合并策略：打开备份数据库，将数据合并到当前数据库
      await _mergeDatabases(backupDbFile, mergeStrategy);
    }
  }

  /// 合并数据库
  Future<void> _mergeDatabases(File backupDbFile, String mergeStrategy) async {
    final currentDb = await DatabaseHelper.instance.database;

    // 打开备份数据库
    final backupDb = await openDatabase(
      backupDbFile.path,
      readOnly: true,
    );

    try {
      // 获取所有表
      final tables = [
        'songs',
        'artists',
        'albums',
        'playlists',
        'playlist_songs',
        'play_history',
        'settings',
        'download_queue',
      ];

      for (final table in tables) {
        // 从备份数据库读取数据
        final backupData = await backupDb.query(table);

        for (final row in backupData) {
          if (mergeStrategy == 'merge') {
            // 合并策略：使用INSERT OR REPLACE
            await currentDb.insert(
              table,
              row,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } else if (mergeStrategy == 'skip') {
            // 跳过策略：使用INSERT OR IGNORE
            await currentDb.insert(
              table,
              row,
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
      }
    } finally {
      await backupDb.close();
    }
  }

  /// 恢复Hive数据
  Future<void> _restoreHiveData(Directory backupDir, String mergeStrategy) async {
    // 恢复settings
    final settingsFile = File(p.join(backupDir.path, _settingsFileName));
    if (await settingsFile.exists()) {
      final settingsJson = await settingsFile.readAsString();
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      await _restoreHiveBox(
        HiveHelper.instance.settingsBox,
        settingsMap,
        mergeStrategy,
      );
    }

    // 恢复player_state
    final playerStateFile = File(p.join(backupDir.path, _playerStateFileName));
    if (await playerStateFile.exists()) {
      final playerStateJson = await playerStateFile.readAsString();
      final playerStateMap = json.decode(playerStateJson) as Map<String, dynamic>;
      await _restoreHiveBox(
        HiveHelper.instance.playerStateBox,
        playerStateMap,
        mergeStrategy,
      );
    }

    // 恢复cache
    final cacheFile = File(p.join(backupDir.path, _cacheFileName));
    if (await cacheFile.exists()) {
      final cacheJson = await cacheFile.readAsString();
      final cacheMap = json.decode(cacheJson) as Map<String, dynamic>;
      await _restoreHiveBox(
        HiveHelper.instance.cacheBox,
        cacheMap,
        mergeStrategy,
      );
    }
  }

  /// 恢复Hive Box
  Future<void> _restoreHiveBox(
    Box<dynamic> box,
    Map<String, dynamic> data,
    String mergeStrategy,
  ) async {
    if (mergeStrategy == 'replace') {
      // 完全替换：清空后重新写入
      await box.clear();
      await box.putAll(data);
    } else {
      // 合并或跳过策略
      for (final entry in data.entries) {
        if (mergeStrategy == 'merge') {
          // 合并：覆盖已存在的
          await box.put(entry.key, entry.value);
        } else if (mergeStrategy == 'skip') {
          // 跳过：只添加不存在的
          if (!box.containsKey(entry.key)) {
            await box.put(entry.key, entry.value);
          }
        }
      }
    }
  }

  /// 获取备份目录
  Future<Directory> getBackupsDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final backupsDir = Directory(p.join(docsDir.path, 'Backups'));
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }
    return backupsDir;
  }

  /// 列出所有备份
  Future<List<File>> listBackups() async {
    final backupsDir = await getBackupsDirectory();
    final backupFiles = <File>[];

    await for (final entity in backupsDir.list()) {
      if (entity is File && entity.path.endsWith(backupExtension)) {
        backupFiles.add(entity);
      }
    }

    // 按修改时间倒序排列
    backupFiles.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      return bStat.modified.compareTo(aStat.modified);
    });

    return backupFiles;
  }

  /// 删除备份
  Future<void> deleteBackup(String backupFilePath) async {
    final file = File(backupFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 获取备份文件大小（字节）
  Future<int> getBackupSize(String backupFilePath) async {
    final file = File(backupFilePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
}
