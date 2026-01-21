import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/download_item_model.dart';
import '../widgets/quality_selector.dart';

/// 下载项卡片组件
///
/// 设计风格：流畅动画 + Glassmorphism
/// - 波形进度动画
/// - 状态徽章
/// - 滑动手势
class DownloadItemTile extends StatefulWidget {
  final DownloadItemModel item;
  final double progress;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const DownloadItemTile({
    super.key,
    required this.item,
    required this.progress,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onRetry,
  });

  @override
  State<DownloadItemTile> createState() => _DownloadItemTileState();
}

class _DownloadItemTileState extends State<DownloadItemTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.item.status == DownloadStatus.downloading) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(DownloadItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.status == DownloadStatus.downloading) {
      if (!_waveController.isAnimating) {
        _waveController.repeat();
      }
    } else {
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // 主要内容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 状态图标
                  _buildStatusIcon(theme),
                  const SizedBox(width: 16),

                  // 歌曲信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (widget.item.artist != null) ...[
                              Flexible(
                                child: Text(
                                  widget.item.artist!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            if (widget.item.quality != null) ...[
                              const SizedBox(width: 8),
                              _buildQualityBadge(theme),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildProgressInfo(theme),
                      ],
                    ),
                  ),

                  // 操作按钮
                  _buildActionButton(theme),
                ],
              ),
            ),

            // 进度条
            _buildProgressBar(theme),
          ],
        ),
      ),
    );
  }

  /// 构建状态图标
  Widget _buildStatusIcon(ThemeData theme) {
    Color color;
    IconData icon;

    switch (widget.item.status) {
      case DownloadStatus.pending:
        color = Colors.grey;
        icon = Icons.schedule;
        break;
      case DownloadStatus.downloading:
        color = theme.colorScheme.primary;
        icon = Icons.download_rounded;
        break;
      case DownloadStatus.paused:
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      case DownloadStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case DownloadStatus.failed:
        color = Colors.red;
        icon = Icons.error;
        break;
      case DownloadStatus.cancelled:
        color = Colors.grey;
        icon = Icons.cancel;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }

  /// 构建音质徽章
  Widget _buildQualityBadge(ThemeData theme) {
    final quality = QualityOptions.fromId(widget.item.quality ?? 'standard');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: quality.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: quality.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            quality.icon,
            size: 12,
            color: quality.color,
          ),
          const SizedBox(width: 4),
          Text(
            quality.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: quality.color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建进度信息
  Widget _buildProgressInfo(ThemeData theme) {
    String text;

    switch (widget.item.status) {
      case DownloadStatus.pending:
        text = '等待下载...';
        break;
      case DownloadStatus.downloading:
        final percentage = (widget.progress * 100).toStringAsFixed(1);
        text = '$percentage% · ${_formatSize(widget.item.downloadedSize)} / ${_formatSize(widget.item.fileSize ?? 0)}';
        break;
      case DownloadStatus.paused:
        text = '已暂停 · ${_formatSize(widget.item.downloadedSize)} / ${_formatSize(widget.item.fileSize ?? 0)}';
        break;
      case DownloadStatus.completed:
        text = '下载完成 · ${_formatSize(widget.item.fileSize ?? 0)}';
        break;
      case DownloadStatus.failed:
        text = '下载失败 · ${widget.item.errorMessage ?? "未知错误"}';
        break;
      case DownloadStatus.cancelled:
        text = '已取消';
        break;
    }

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 格式化文件大小
  String _formatSize(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// 构建操作按钮
  Widget _buildActionButton(ThemeData theme) {
    switch (widget.item.status) {
      case DownloadStatus.downloading:
        return IconButton(
          onPressed: widget.onPause,
          icon: const Icon(Icons.pause_rounded),
          color: theme.colorScheme.primary,
          tooltip: '暂停',
        );

      case DownloadStatus.paused:
      case DownloadStatus.pending:
        return IconButton(
          onPressed: widget.onResume,
          icon: const Icon(Icons.play_arrow_rounded),
          color: theme.colorScheme.primary,
          tooltip: '继续',
        );

      case DownloadStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh_rounded),
              color: theme.colorScheme.primary,
              tooltip: '重试',
            ),
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close_rounded),
              color: theme.colorScheme.error,
              tooltip: '删除',
            ),
          ],
        );

      case DownloadStatus.completed:
      case DownloadStatus.cancelled:
        return IconButton(
          onPressed: widget.onCancel,
          icon: const Icon(Icons.delete_outline_rounded),
          color: theme.colorScheme.error,
          tooltip: '删除',
        );
    }
  }

  /// 构建进度条（波形动画）
  Widget _buildProgressBar(ThemeData theme) {
    if (widget.item.status != DownloadStatus.downloading &&
        widget.item.status != DownloadStatus.paused &&
        widget.item.status != DownloadStatus.pending) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 4),
          painter: _WaveProgressPainter(
            progress: widget.progress,
            wavePhase: _waveController.value,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            isAnimating: widget.item.status == DownloadStatus.downloading,
          ),
        );
      },
    );
  }
}

/// 波形进度条画笔
class _WaveProgressPainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final Color color;
  final Color backgroundColor;
  final bool isAnimating;

  _WaveProgressPainter({
    required this.progress,
    required this.wavePhase,
    required this.color,
    required this.backgroundColor,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 背景
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 进度
    final progressWidth = size.width * progress;

    if (isAnimating) {
      // 波形进度（下载中）
      final path = Path();
      path.moveTo(0, 0);

      const waveHeight = 2.0;
      const waveLength = 20.0;

      for (double x = 0; x <= progressWidth; x += 1) {
        final y = math.sin((x / waveLength + wavePhase) * 2 * math.pi) *
                waveHeight +
            size.height / 2;
        path.lineTo(x, y);
      }

      path.lineTo(progressWidth, size.height);
      path.lineTo(0, size.height);
      path.close();

      final wavePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, wavePaint);
    } else {
      // 静态进度（暂停）
      final progressPaint = Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, progressWidth, size.height),
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.isAnimating != isAnimating;
  }
}
