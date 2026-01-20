import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/song_model.dart';
import '../../widgets/favorite_button.dart';
import '../../providers/play_history_provider.dart';

/// Most Played Page - Retro Vinyl Records aesthetic
/// Displays most frequently played songs with play counts
class MostPlayedPage extends ConsumerStatefulWidget {
  const MostPlayedPage({super.key});

  @override
  ConsumerState<MostPlayedPage> createState() => _MostPlayedPageState();
}

class _MostPlayedPageState extends ConsumerState<MostPlayedPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(mostPlayedProvider.notifier).loadMostPlayed());
  }

  @override
  Widget build(BuildContext context) {
    final mostPlayedAsync = ref.watch(mostPlayedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Retro-styled App Bar with trophy and records
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0D0D0D),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'MOST PLAYED',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.5,
                  color: Color(0xFFD4AF37),
                  shadows: [
                    Shadow(
                      color: Color(0xFFD4AF37),
                      blurRadius: 20,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5,
                        colors: [
                          Color(0xFF2A1A0D),
                          Color(0xFF1A0D0D),
                          Color(0xFF0D0D0D),
                        ],
                      ),
                    ),
                  ),
                  // Trophy icon
                  Positioned(
                    top: 50,
                    right: 30,
                    child: Container(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFD4AF37).withOpacity(0.3),
                                  const Color(0xFFD4AF37).withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                          // Trophy
                          Icon(
                            Icons.emoji_events,
                            size: 70,
                            color: const Color(0xFFD4AF37).withOpacity(0.8),
                          ),
                        ],
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(reverse: true),
                        )
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.1, 1.1),
                          duration: 2000.ms,
                          curve: Curves.easeInOut,
                        ),
                  ),
                  // Decorative vinyl records
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: _DecorativeVinylStack(),
                  ),
                ],
              ),
            ),
          ),

          // Content
          mostPlayedAsync.when(
            data: (songsWithCount) {
              if (songsWithCount.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = songsWithCount[index];
                      final song = data['song'] as SongModel;
                      final playCount = data['play_count'] as int;

                      return _MostPlayedTile(
                        song: song,
                        playCount: playCount,
                        rank: index + 1,
                      ).animate().fadeIn(
                            delay: (index * 45).ms,
                            duration: 550.ms,
                          ).slideX(
                            begin: -0.15,
                            end: 0,
                            delay: (index * 45).ms,
                            duration: 550.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                    childCount: songsWithCount.length,
                  ),
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4AF37),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Calculating top tracks...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'DM Sans',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFD4AF37),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load statistics',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 80,
            color: const Color(0xFFD4AF37).withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Statistics Yet',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Play more music to see your top tracks',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative vinyl stack for header
class _DecorativeVinylStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          for (int i = 0; i < 3; i++)
            Positioned(
              left: i * 8.0,
              top: i * 8.0,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1A1A1A).withOpacity(1 - i * 0.3),
                      const Color(0xFF0D0D0D).withOpacity(1 - i * 0.3),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.2 - i * 0.05),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD4AF37).withOpacity(0.3 - i * 0.1),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Most played song tile with rank badge and play count
class _MostPlayedTile extends ConsumerWidget {
  final SongModel song;
  final int playCount;
  final int rank;

  const _MostPlayedTile({
    required this.song,
    required this.playCount,
    required this.rank,
  });

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFFD4AF37).withOpacity(0.5);
    }
  }

  IconData? _getRankIcon() {
    if (rank <= 3) {
      return Icons.emoji_events;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankColor = _getRankColor();
    final rankIcon = _getRankIcon();
    final isTopThree = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isTopThree
              ? [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF1A1A1A),
                ]
              : [
                  const Color(0xFF1A1A1A),
                  const Color(0xFF0D0D0D),
                ],
        ),
        border: Border.all(
          color: isTopThree
              ? rankColor.withOpacity(0.3)
              : const Color(0xFFD4AF37).withOpacity(0.08),
          width: isTopThree ? 1.5 : 1,
        ),
        boxShadow: [
          if (isTopThree)
            BoxShadow(
              color: rankColor.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: rankColor.withOpacity(0.1),
          onTap: () {
            // TODO: Play song
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Rank badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        rankColor.withOpacity(0.4),
                        rankColor.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(
                      color: rankColor,
                      width: 2,
                    ),
                    boxShadow: isTopThree
                        ? [
                            BoxShadow(
                              color: rankColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: rankIcon != null
                        ? Icon(
                            rankIcon,
                            color: rankColor,
                            size: 28,
                          )
                        : Text(
                            '$rank',
                            style: TextStyle(
                              color: rankColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Playfair Display',
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Album art
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2A2A2A),
                        const Color(0xFF1A1A1A),
                      ],
                    ),
                    border: Border.all(
                      color: rankColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.album,
                    color: rankColor.withOpacity(0.5),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16,
                          fontWeight: isTopThree ? FontWeight.w700 : FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        song.displayArtist,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: rankColor.withOpacity(0.8),
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 14,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$playCount ${playCount == 1 ? 'play' : 'plays'}',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Duration
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      song.formattedDuration,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
