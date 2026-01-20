import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../providers/settings_provider.dart';
import 'settings_card.dart';

/// Cache management section
class CacheSection extends ConsumerStatefulWidget {
  const CacheSection({super.key});

  @override
  ConsumerState<CacheSection> createState() => _CacheSectionState();
}

class _CacheSectionState extends ConsumerState<CacheSection> {
  int _currentCacheSize = 0;
  int _currentCoverCacheSize = 0;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

  Future<void> _calculateCacheSize() async {
    setState(() => _isCalculating = true);

    try {
      final cacheDir = await getTemporaryDirectory();
      final coverCacheDir = Directory('${cacheDir.path}/covers');

      _currentCacheSize = await _getDirectorySize(cacheDir);
      _currentCoverCacheSize = await _getDirectorySize(coverCacheDir);
    } catch (e) {
      _currentCacheSize = 0;
      _currentCoverCacheSize = 0;
    }

    setState(() => _isCalculating = false);
  }

  Future<int> _getDirectorySize(Directory dir) async {
    if (!await dir.exists()) return 0;

    int size = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final cacheDir = await getTemporaryDirectory();
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
          await cacheDir.create();
        }
        await _calculateCacheSize();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('缓存已清除')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('清除缓存失败')),
          );
        }
      }
    }
  }

  Future<void> _clearCoverCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除封面缓存'),
        content: const Text('确定要清除所有封面缓存吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final cacheDir = await getTemporaryDirectory();
        final coverCacheDir = Directory('${cacheDir.path}/covers');

        if (await coverCacheDir.exists()) {
          await coverCacheDir.delete(recursive: true);
          await coverCacheDir.create();
        }
        await _calculateCacheSize();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('封面缓存已清除')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('清除封面缓存失败')),
          );
        }
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(userSettingsProvider);
    final notifier = ref.read(userSettingsProvider.notifier);

    return SettingsCard(
      title: '缓存',
      icon: Icons.storage_outlined,
      children: [
        // Cache size info
        _CacheInfo(
          label: '当前缓存大小',
          size: _formatSize(_currentCacheSize),
          maxSize: '${settings.maxCacheSizeMB} MB',
          isCalculating: _isCalculating,
        ),

        const SizedBox(height: 12),

        _CacheInfo(
          label: '封面缓存大小',
          size: _formatSize(_currentCoverCacheSize),
          maxSize: '${settings.maxCoverCacheSizeMB} MB',
          isCalculating: _isCalculating,
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Max cache size slider
        _CacheSizeSlider(
          label: '最大缓存大小',
          value: settings.maxCacheSizeMB.toDouble(),
          onChanged: (value) => notifier.updateMaxCacheSize(value.toInt()),
        ),

        const SizedBox(height: 16),

        // Max cover cache size slider
        _CacheSizeSlider(
          label: '最大封面缓存大小',
          value: settings.maxCoverCacheSizeMB.toDouble(),
          onChanged: (value) => notifier.updateMaxCoverCacheSize(value.toInt()),
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Clear cache buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearCoverCache,
                icon: const Icon(Icons.image_outlined, size: 18),
                label: const Text('清除封面'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _clearCache,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('清除全部'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CacheInfo extends StatelessWidget {
  final String label;
  final String size;
  final String maxSize;
  final bool isCalculating;

  const _CacheInfo({
    required this.label,
    required this.size,
    required this.maxSize,
    required this.isCalculating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isCalculating ? '计算中...' : size,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '上限 $maxSize',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CacheSizeSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _CacheSizeSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${value.toInt()} MB',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 100,
          max: 2000,
          divisions: 19,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
