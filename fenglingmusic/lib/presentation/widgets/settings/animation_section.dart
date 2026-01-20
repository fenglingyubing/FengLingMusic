import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import 'settings_card.dart';

/// Animation settings section
class AnimationSection extends ConsumerWidget {
  const AnimationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(userSettingsProvider);
    final notifier = ref.read(userSettingsProvider.notifier);

    return SettingsCard(
      title: '动画',
      icon: Icons.animation_outlined,
      children: [
        // High refresh rate toggle
        _SettingToggle(
          label: '启用高刷新率',
          subtitle: '在支持的设备上启用120fps动画',
          value: settings.enableHighRefreshRate,
          onChanged: (_) => notifier.toggleHighRefreshRate(),
        ),

        if (settings.enableHighRefreshRate) ...[
          const SizedBox(height: 16),

          // Target frame rate selector
          _buildFrameRateSelector(theme, settings, notifier),

          const SizedBox(height: 16),

          // Animation speed slider
          _AnimationSpeedSlider(
            value: settings.animationSpeed,
            onChanged: (value) => notifier.updateAnimationSpeed(value),
          ),
        ],
      ],
    );
  }

  Widget _buildFrameRateSelector(
    ThemeData theme,
    settings,
    UserSettingsNotifier notifier,
  ) {
    const frameRates = [60, 90, 120];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '目标帧率',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: frameRates.map((fps) {
            final isSelected = settings.targetFrameRate == fps;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _FrameRateButton(
                  fps: fps,
                  isSelected: isSelected,
                  onTap: () => notifier.updateTargetFrameRate(fps),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _FrameRateButton extends StatelessWidget {
  final int fps;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrameRateButton({
    required this.fps,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.5)
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Text(
              '$fps',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'FPS',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimationSpeedSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _AnimationSpeedSlider({
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
              '动画速度',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '慢',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              Text(
                '快',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
