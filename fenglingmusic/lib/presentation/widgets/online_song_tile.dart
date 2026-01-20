import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/online_song.dart';

/// 在线歌曲列表项组件
///
/// 设计：浮动卡片，悬停时上升，带有优雅的阴影和细腻的动画
class OnlineSongTile extends StatefulWidget {
  final OnlineSong song;
  final int index;

  const OnlineSongTile({
    super.key,
    required this.song,
    required this.index,
  });

  @override
  State<OnlineSongTile> createState() => _OnlineSongTileState();
}

class _OnlineSongTileState extends State<OnlineSongTile> {
  bool _isHovered = false;

  /// 格式化时长
  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 获取平台颜色
  Color _getPlatformColor() {
    switch (widget.song.platform) {
      case 'netease':
        return const Color(0xFFD43C33);
      case 'qq':
        return const Color(0xFF31C27C);
      case 'kugou':
        return const Color(0xFF2C9EF8);
      default:
        return Colors.grey;
    }
  }

  /// 获取平台名称
  String _getPlatformName() {
    switch (widget.song.platform) {
      case 'netease':
        return '网易云';
      case 'qq':
        return 'QQ音乐';
      case 'kugou':
        return '酷狗';
      default:
        return '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platformColor = _getPlatformColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0, 0.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? platformColor.withOpacity(0.3)
                  : theme.colorScheme.outline.withOpacity(0.1),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? platformColor.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 20 : 8,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // TODO: 播放或显示歌曲详情
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('播放: ${widget.song.title}'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // 封面图片
                    _buildCoverImage(theme, platformColor),
                    const SizedBox(width: 16),

                    // 歌曲信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题和平台标签
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.song.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPlatformBadge(theme, platformColor),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // 艺术家
                          Text(
                            widget.song.artist,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // 专辑和时长
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.song.album.isNotEmpty
                                      ? widget.song.album
                                      : '未知专辑',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(widget.song.duration),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 操作按钮
                    _buildActionButtons(theme, platformColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: widget.index * 50),
          duration: 400.ms,
        )
        .slideX(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: widget.index * 50),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// 构建封面图片
  Widget _buildCoverImage(ThemeData theme, Color platformColor) {
    return Hero(
      tag: 'song_cover_${widget.song.id}_${widget.song.platform}',
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              platformColor.withOpacity(0.3),
              platformColor.withOpacity(0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: platformColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.song.coverUrl != null
              ? Image.network(
                  widget.song.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderCover(theme);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildPlaceholderCover(theme);
                  },
                )
              : _buildPlaceholderCover(theme),
        ),
      ),
    );
  }

  /// 构建占位封面
  Widget _buildPlaceholderCover(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.music_note_rounded,
        size: 32,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }

  /// 构建平台标签
  Widget _buildPlatformBadge(ThemeData theme, Color platformColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: platformColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: platformColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getPlatformName(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: platformColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(ThemeData theme, Color platformColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 下载按钮
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('下载: ${widget.song.title}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.download_rounded),
          iconSize: 20,
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        // 更多按钮
        IconButton(
          onPressed: () {
            _showMoreOptions(context);
          },
          icon: const Icon(Icons.more_vert_rounded),
          iconSize: 20,
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 显示更多选项
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.play_arrow_rounded),
                title: const Text('播放'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded),
                title: const Text('添加到播放列表'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('下载'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded),
                title: const Text('分享'),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
