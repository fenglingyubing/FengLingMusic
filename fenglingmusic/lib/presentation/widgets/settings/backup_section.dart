import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/storage/backup_service.dart';
import 'settings_card.dart';

/// 备份与恢复设置分区
class BackupSection extends StatefulWidget {
  const BackupSection({super.key});

  @override
  State<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<BackupSection> {
  final _backupService = BackupService.instance;
  bool _isProcessing = false;
  String _currentOperation = '';
  double _progress = 0.0;
  List<File> _backupFiles = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    try {
      final backups = await _backupService.listBackups();
      setState(() {
        _backupFiles = backups;
      });
    } catch (e) {
      if (mounted) {
        _showError('加载备份列表失败: $e');
      }
    }
  }

  Future<void> _createBackup() async {
    setState(() {
      _isProcessing = true;
      _currentOperation = '准备创建备份...';
      _progress = 0.0;
    });

    try {
      final backupPath = await _backupService.createBackup(
        onProgress: (message, progress) {
          if (mounted) {
            setState(() {
              _currentOperation = message;
              _progress = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showSuccess('备份创建成功！\n保存位置: $backupPath');
        await _loadBackups();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showError('创建备份失败: $e');
      }
    }
  }

  Future<void> _restoreBackup(String backupPath) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复备份'),
        content: const Text(
          '恢复备份将会合并备份数据到当前数据。\n\n'
          '合并策略：如果数据冲突，将使用备份中的数据。\n\n'
          '是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('恢复'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
      _currentOperation = '准备恢复备份...';
      _progress = 0.0;
    });

    try {
      await _backupService.restoreBackup(
        backupPath,
        mergeStrategy: 'merge',
        onProgress: (message, progress) {
          if (mounted) {
            setState(() {
              _currentOperation = message;
              _progress = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showSuccess('备份恢复成功！\n应用将重新启动以应用更改。');
        // TODO: 重启应用
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showError('恢复备份失败: $e');
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['flmbackup'],
      );

      if (result != null && result.files.single.path != null) {
        final backupPath = result.files.single.path!;
        await _restoreBackup(backupPath);
      }
    } catch (e) {
      _showError('导入备份失败: $e');
    }
  }

  Future<void> _deleteBackup(File backupFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除备份文件吗？\n\n${_getFileName(backupFile)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _backupService.deleteBackup(backupFile.path);
        await _loadBackups();
        if (mounted) {
          _showSuccess('备份已删除');
        }
      } catch (e) {
        _showError('删除备份失败: $e');
      }
    }
  }

  Future<void> _showBackupInfo(File backupFile) async {
    try {
      final info = await _backupService.getBackupInfo(backupFile.path);
      final size = await _backupService.getBackupSize(backupFile.path);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('备份信息'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow('文件名', _getFileName(backupFile)),
                _InfoRow('创建时间', _formatDate(info['created_at'])),
                _InfoRow('应用版本', info['app_version'] ?? '未知'),
                _InfoRow('平台', info['platform'] ?? '未知'),
                _InfoRow('文件大小', _formatBytes(size)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _restoreBackup(backupFile.path);
                },
                child: const Text('恢复此备份'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showError('读取备份信息失败: $e');
    }
  }

  String _getFileName(File file) {
    return file.path.split(Platform.pathSeparator).last;
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '未知';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    } catch (e) {
      return '未知';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: '数据备份与恢复',
      icon: Icons.backup_outlined,
      children: [
        // 操作按钮
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _isProcessing ? null : _createBackup,
                icon: const Icon(Icons.backup),
                label: const Text('创建备份'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _importBackup,
                icon: const Icon(Icons.restore),
                label: const Text('导入备份'),
              ),
            ),
          ],
        ),

        // 进度指示器
        if (_isProcessing) ...[
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentOperation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 4),
              Text(
                '${(_progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ],
          ),
        ],

        // 备份列表
        if (_backupFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            '现有备份 (${_backupFiles.length})',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          ..._backupFiles.map((file) => _BackupTile(
                file: file,
                onRestore: () => _restoreBackup(file.path),
                onDelete: () => _deleteBackup(file),
                onInfo: () => _showBackupInfo(file),
              )),
        ],

        // 说明文字
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          '备份包含：',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '• 所有本地歌曲数据\n'
          '• 播放列表和收藏\n'
          '• 播放历史记录\n'
          '• 应用设置和偏好',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      ],
    );
  }
}

class _BackupTile extends StatelessWidget {
  final File file;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final VoidCallback onInfo;

  const _BackupTile({
    required this.file,
    required this.onRestore,
    required this.onDelete,
    required this.onInfo,
  });

  String _getFileName() {
    return file.path.split(Platform.pathSeparator).last;
  }

  String _getModifiedDate() {
    final stat = file.statSync();
    return DateFormat('yyyy-MM-dd HH:mm').format(stat.modified);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.folder_zip),
        title: Text(
          _getFileName(),
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          _getModifiedDate(),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: onInfo,
              tooltip: '查看详情',
            ),
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: onRestore,
              tooltip: '恢复',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: '删除',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
