import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 音质信息类
class QualityOption {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final int estimatedSizeMB;

  const QualityOption({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.estimatedSizeMB,
  });
}

/// 预定义音质选项
class QualityOptions {
  static const standard = QualityOption(
    id: 'standard',
    label: '标准',
    description: '128k MP3',
    icon: Icons.music_note,
    color: Color(0xFF4CAF50),
    estimatedSizeMB: 4,
  );

  static const higher = QualityOption(
    id: 'higher',
    label: '高品质',
    description: '320k MP3',
    icon: Icons.library_music,
    color: Color(0xFF2196F3),
    estimatedSizeMB: 10,
  );

  static const lossless = QualityOption(
    id: 'lossless',
    label: '无损',
    description: 'FLAC',
    icon: Icons.album,
    color: Color(0xFFFF9800),
    estimatedSizeMB: 30,
  );

  static final List<QualityOption> all = [standard, higher, lossless];

  static QualityOption fromId(String id) {
    return all.firstWhere(
      (option) => option.id == id,
      orElse: () => standard,
    );
  }
}

/// 音质选择器组件
///
/// TASK-097: 实现音质选择器
///
/// 设计风格：Glassmorphism + 渐变卡片
/// - 半透明毛玻璃效果
/// - 流动渐变背景
/// - 优雅的动画过渡
/// - 音质徽章设计
class QualitySelector extends StatefulWidget {
  final String? selectedQuality;
  final Function(String quality) onQualitySelected;
  final int? duration; // 歌曲时长(秒)，用于估算文件大小

  const QualitySelector({
    super.key,
    this.selectedQuality,
    required this.onQualitySelected,
    this.duration,
  });

  @override
  State<QualitySelector> createState() => _QualitySelectorState();

  /// 显示音质选择器（Bottom Sheet）
  static void show({
    required BuildContext context,
    String? selectedQuality,
    required Function(String quality) onQualitySelected,
    int? duration,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QualitySelector(
        selectedQuality: selectedQuality,
        onQualitySelected: onQualitySelected,
        duration: duration,
      ),
    );
  }
}

class _QualitySelectorState extends State<QualitySelector> {
  String _selectedQuality = 'standard';

  @override
  void initState() {
    super.initState();
    _selectedQuality = widget.selectedQuality ?? 'standard';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.55,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Stack(
        children: [
          // 背景装饰
          _buildBackgroundDecoration(theme),

          // 内容
          Column(
            children: [
              // 拖动指示器
              _buildDragIndicator(),

              // 标题
              _buildTitle(theme),

              // 音质选项列表
              Expanded(
                child: _buildQualityOptions(theme),
              ),

              // 底部按钮
              _buildBottomActions(theme, context),
            ],
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 300.ms);
  }

  /// 构建背景装饰
  Widget _buildBackgroundDecoration(ThemeData theme) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Stack(
          children: [
            // 渐变球
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.15),
                      theme.colorScheme.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.secondary.withOpacity(0.15),
                      theme.colorScheme.secondary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建拖动指示器
  Widget _buildDragIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Icon(
            Icons.high_quality_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            '选择音质',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0);
  }

  /// 构建音质选项列表
  Widget _buildQualityOptions(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: QualityOptions.all.length,
      itemBuilder: (context, index) {
        final option = QualityOptions.all[index];
        final isSelected = _selectedQuality == option.id;

        return _buildQualityCard(theme, option, isSelected, index);
      },
    );
  }

  /// 构建音质卡片
  Widget _buildQualityCard(
    ThemeData theme,
    QualityOption option,
    bool isSelected,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedQuality = option.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    option.color.withOpacity(0.15),
                    option.color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? option.color.withOpacity(0.5)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: option.color.withOpacity(isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                option.icon,
                color: option.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // 文字信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildSizeEstimate(theme, option),
                ],
              ),
            ),

            // 选中指示器
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
          ],
        ),
      ),
    )
        .animate(delay: (100 * index).ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
  }

  /// 构建大小估算
  Widget _buildSizeEstimate(ThemeData theme, QualityOption option) {
    final estimatedSize = _calculateEstimatedSize(option);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '约 $estimatedSize MB',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 计算估算文件大小
  int _calculateEstimatedSize(QualityOption option) {
    if (widget.duration != null && widget.duration! > 0) {
      // 根据歌曲时长估算
      final minutes = widget.duration! / 60;
      return (option.estimatedSizeMB * minutes / 4).round();
    }
    return option.estimatedSizeMB;
  }

  /// 构建底部操作按钮
  Widget _buildBottomActions(ThemeData theme, BuildContext context) {
    final selectedOption = QualityOptions.fromId(_selectedQuality);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // 取消按钮
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),

          // 确认按钮
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: () {
                widget.onQualitySelected(_selectedQuality);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: selectedOption.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(selectedOption.icon, size: 20),
                  const SizedBox(width: 8),
                  const Text('开始下载'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
