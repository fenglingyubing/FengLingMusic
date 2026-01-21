import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/lyrics_provider.dart';
import '../../widgets/lyrics_view.dart';

/// Lyrics Page
///
/// 全屏歌词页面，提供沉浸式歌词阅读体验
/// 包含：
/// - 专辑封面背景模糊效果
/// - 完整歌词显示
/// - 歌曲信息展示
/// - 歌词操作功能
class LyricsPage extends ConsumerStatefulWidget {
  final String? albumCoverUrl;
  final String? songTitle;
  final String? artistName;

  const LyricsPage({
    super.key,
    this.albumCoverUrl,
    this.songTitle,
    this.artistName,
  });

  @override
  ConsumerState<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends ConsumerState<LyricsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );

    _backgroundController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TODO: Uncomment when lyricsControllerProvider is configured
    // final lyricsState = ref.watch(lyricsControllerProvider);
    const lyricsState = LyricsState();  // Placeholder

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(theme),
      body: Stack(
        children: [
          // Background with album cover blur
          _buildBackground(theme),

          // Lyrics content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Song info header
                _buildSongInfo(theme),

                // Lyrics view
                Expanded(
                  child: LyricsView(
                    accentColor: theme.colorScheme.primary,
                    showTranslation: _showTranslation,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(theme, lyricsState),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // Translation toggle
        IconButton(
          icon: Icon(
            _showTranslation
                ? Icons.translate
                : Icons.translate_outlined,
            color: theme.colorScheme.onSurface,
          ),
          tooltip: '切换翻译',
          onPressed: () {
            setState(() {
              _showTranslation = !_showTranslation;
            });
          },
        ),

        // Refresh lyrics
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: theme.colorScheme.onSurface,
          ),
          tooltip: '重新加载歌词',
          onPressed: () {
            // TODO: Uncomment when provider is ready
            // ref.read(lyricsControllerProvider.notifier).reloadLyrics();
          },
        ),

        // More options
        PopupMenuButton(
          icon: Icon(
            Icons.more_vert,
            color: theme.colorScheme.onSurface,
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_cache',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('清除歌词缓存'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'search_online',
              child: ListTile(
                leading: Icon(Icons.search),
                title: Text('在线搜索歌词'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'desktop_lyrics',
              child: ListTile(
                leading: Icon(Icons.picture_in_picture_alt),
                title: Text('桌面歌词（Windows）'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(value as String),
        ),
      ],
    );
  }

  Widget _buildBackground(ThemeData theme) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _backgroundAnimation.value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: widget.albumCoverUrl != null
            ? Stack(
                children: [
                  // Album cover background (blurred)
                  Positioned.fill(
                    child: Image.network(
                      widget.albumCoverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(),
                    ),
                  ),

                  // Heavy blur
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        color: theme.colorScheme.surface.withOpacity(0.7),
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.surface.withOpacity(0.3),
                            theme.colorScheme.surface.withOpacity(0.8),
                            theme.colorScheme.surface,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildSongInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Song title
          if (widget.songTitle != null)
            Text(
              widget.songTitle!,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          // Artist name
          if (widget.artistName != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.artistName!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),
          Divider(
            color: theme.colorScheme.outline.withOpacity(0.2),
            thickness: 1,
            indent: 40,
            endIndent: 40,
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActions(ThemeData theme, LyricsState lyricsState) {
    if (!lyricsState.hasLyrics) return null;

    return FloatingActionButton.extended(
      onPressed: () {
        // TODO: Open lyrics settings or share
        _showLyricsBottomSheet(theme);
      },
      icon: const Icon(Icons.tune),
      label: const Text('自定义'),
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
    );
  }

  void _handleMenuAction(String action) {
    // TODO: Uncomment when lyricsControllerProvider is configured
    // final notifier = ref.read(lyricsControllerProvider.notifier);

    switch (action) {
      case 'clear_cache':
        // TODO: Implement when provider is ready
        // notifier.clearCache().then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('歌词缓存已清除')),
        );
        // });
        break;

      case 'search_online':
        // TODO: Implement when provider is ready
        // notifier.reloadLyrics();
        break;

      case 'desktop_lyrics':
        // TODO: Show desktop lyrics window (Windows only)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('桌面歌词 - 敬请期待')),
        );
        break;
    }
  }

  void _showLyricsBottomSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '歌词设置',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: const Text('字号'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement font size selector
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('配色主题'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement color picker
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.animation),
                    title: const Text('动画速度'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement animation speed selector
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
