import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings/theme_section.dart';
import '../../widgets/settings/scan_paths_section.dart';
import '../../widgets/settings/playback_section.dart';
import '../../widgets/settings/animation_section.dart';
import '../../widgets/settings/cache_section.dart';
import 'dart:ui';

/// Settings page
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar.large(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: FlexibleSpaceBar(
                  title: Text(
                    '设置',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  expandedTitleScale: 1.5,
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Theme Section
                const ThemeSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 0.ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // Scan Paths Section
                const ScanPathsSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // Playback Section
                const PlaybackSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // Animation Section
                const AnimationSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // Cache Section
                const CacheSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),

                // Version Info
                _buildVersionInfo(theme)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.music_note_rounded,
            size: 48,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'FengLing Music',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
