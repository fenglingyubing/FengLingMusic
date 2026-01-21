import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../../../data/models/song_model.dart';
import '../../widgets/song_tile.dart';
import '../../providers/folder_provider.dart';

/// Folder browser page with file manager aesthetic
/// Features: Breadcrumb navigation, folder/file icons, hierarchical browsing
class FolderBrowserPage extends ConsumerStatefulWidget {
  final String? initialPath;

  const FolderBrowserPage({
    super.key,
    this.initialPath,
  });

  @override
  ConsumerState<FolderBrowserPage> createState() => _FolderBrowserPageState();
}

class _FolderBrowserPageState extends ConsumerState<FolderBrowserPage> {
  late String _currentPath;
  final List<String> _pathHistory = [];

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath ?? '/';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final folderContentsAsync = ref.watch(folderContentsProvider(_currentPath));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar with breadcrumb
          _buildAppBar(context, colorScheme),

          // Breadcrumb navigation
          _buildBreadcrumbs(context, colorScheme),

          // Folder contents
          folderContentsAsync.when(
            data: (contents) {
              if (contents.folders.isEmpty && contents.songs.isEmpty) {
                return _buildEmptyState(colorScheme);
              }

              return _buildFolderContents(context, contents, colorScheme);
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, _) => _buildErrorState(error, colorScheme),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      title: const Text(
        '文件夹',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        // Play all button
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            // TODO: Play all songs in current folder
          },
          tooltip: '播放全部',
        ),
        // Sort button
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () => _showSortOptions(context),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbs(BuildContext context, ColorScheme colorScheme) {
    final pathParts = _currentPath.split('/').where((p) => p.isNotEmpty).toList();

    return SliverToBoxAdapter(
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // Root
            _buildBreadcrumbItem(
              context,
              colorScheme,
              '根目录',
              '/',
              isLast: pathParts.isEmpty,
            ),

            // Path parts
            for (int i = 0; i < pathParts.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
              _buildBreadcrumbItem(
                context,
                colorScheme,
                pathParts[i],
                '/' + pathParts.sublist(0, i + 1).join('/'),
                isLast: i == pathParts.length - 1,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    ColorScheme colorScheme,
    String label,
    String path, {
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: isLast
          ? null
          : () {
              setState(() {
                _currentPath = path;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isLast
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
            color: isLast
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderContents(
    BuildContext context,
    FolderContents contents,
    ColorScheme colorScheme,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final totalFolders = contents.folders.length;

          // Folders first
          if (index < totalFolders) {
            final folder = contents.folders[index];
            return _buildFolderItem(context, folder, colorScheme);
          }

          // Then songs
          final songIndex = index - totalFolders;
          if (songIndex < contents.songs.length) {
            final song = contents.songs[songIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SongTile(
                song: song,
                showAlbumArt: true,
                onTap: () {
                  // TODO: Play song
                },
              ),
            );
          }

          return null;
        },
        childCount: contents.folders.length + contents.songs.length,
      ),
    );
  }

  Widget _buildFolderItem(
    BuildContext context,
    FolderInfo folder,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _currentPath = folder.path;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Folder icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder,
                    color: colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Folder info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${folder.songCount} 首歌曲',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '该文件夹为空',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, ColorScheme colorScheme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '加载文件夹失败',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.refresh(folderContentsProvider(_currentPath));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '排序方式',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('名称（A-Z）'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement sorting
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('修改日期'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement sorting
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
