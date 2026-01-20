import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 平台筛选芯片组件
///
/// 设计：风铃般的轻盈感，点击时有"叮"的视觉反馈
class PlatformFilterChip extends StatefulWidget {
  final String label;
  final String platform;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const PlatformFilterChip({
    super.key,
    required this.label,
    required this.platform,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<PlatformFilterChip> createState() => _PlatformFilterChipState();
}

class _PlatformFilterChipState extends State<PlatformFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - (_controller.value * 0.1);
          final rotation = _controller.value * 0.05;

          return Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation,
              child: child,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.color.withOpacity(0.15)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? widget.color.withOpacity(0.5)
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? widget.color
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: widget.isSelected
                      ? widget.color
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(
          target: widget.isSelected ? 1 : 0,
        )
        .shimmer(
          duration: 1200.ms,
          color: widget.color.withOpacity(0.2),
        );
  }
}
