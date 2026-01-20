import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/settings_provider.dart';
import 'settings_card.dart';

/// Scan paths settings section
class ScanPathsSection extends ConsumerWidget {
  const ScanPathsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(userSettingsProvider);
    final notifier = ref.read(userSettingsProvider.notifier);

    return SettingsCard(
      title: '扫描路径',
      icon: Icons.folder_outlined,
      children: [
        // Add path button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _addPath(context, notifier),
            icon: const Icon(Icons.add),
            label: const Text('添加扫描路径'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        if (settings.scanPaths.isNotEmpty) ...[
          const SizedBox(height: 16),
          // Paths list
          ...settings.scanPaths.map((path) => _PathItem(
                path: path,
                onDelete: () => notifier.removeScanPath(path),
              )),
        ] else ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              '暂无扫描路径',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _addPath(BuildContext context, UserSettingsNotifier notifier) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      await notifier.addScanPath(result);
    }
  }
}

class _PathItem extends StatelessWidget {
  final String path;
  final VoidCallback onDelete;

  const _PathItem({
    required this.path,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              path,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            color: theme.colorScheme.error,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
