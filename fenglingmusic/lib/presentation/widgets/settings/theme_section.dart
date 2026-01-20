import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/user_settings.dart';
import '../../providers/settings_provider.dart';
import 'settings_card.dart';
import 'color_picker_dialog.dart';

/// Theme settings section
class ThemeSection extends ConsumerWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(userSettingsProvider);
    final notifier = ref.read(userSettingsProvider.notifier);

    return SettingsCard(
      title: '主题',
      icon: Icons.palette_outlined,
      children: [
        // Theme mode selector
        _buildThemeModeSelector(context, settings, notifier),

        const SizedBox(height: 16),

        // Custom theme color
        _buildCustomThemeToggle(context, theme, settings, notifier),

        if (settings.useCustomTheme) ...[
          const SizedBox(height: 16),
          _buildColorPreview(context, theme, settings, notifier),
        ],
      ],
    );
  }

  Widget _buildThemeModeSelector(
    BuildContext context,
    UserSettings settings,
    UserSettingsNotifier notifier,
  ) {
    return Row(
      children: AppThemeMode.values.map((mode) {
        final isSelected = settings.themeMode == mode;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _ThemeModeButton(
              mode: mode,
              isSelected: isSelected,
              onTap: () => notifier.updateThemeMode(mode),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomThemeToggle(
    BuildContext context,
    ThemeData theme,
    UserSettings settings,
    UserSettingsNotifier notifier,
  ) {
    return InkWell(
      onTap: () {
        notifier.updateCustomThemeColor(
          Color(settings.customPrimaryColor),
          !settings.useCustomTheme,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(
              Icons.color_lens_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '自定义主题色',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Switch(
              value: settings.useCustomTheme,
              onChanged: (value) {
                notifier.updateCustomThemeColor(
                  Color(settings.customPrimaryColor),
                  value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview(
    BuildContext context,
    ThemeData theme,
    UserSettings settings,
    UserSettingsNotifier notifier,
  ) {
    final color = Color(settings.customPrimaryColor);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ColorPickerDialog(
            initialColor: color,
            onColorSelected: (newColor) {
              notifier.updateCustomThemeColor(newColor, true);
            },
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '主题色',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }
}

/// Theme mode button
class _ThemeModeButton extends StatelessWidget {
  final AppThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeButton({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mode.icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 8),
              Text(
                mode.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
