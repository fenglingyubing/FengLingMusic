import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/song_model.dart';
import '../../widgets/favorite_button.dart';
import '../../providers/favorites_provider.dart';

/// Favorites Page - Retro Vinyl Records aesthetic
/// Displays all favorited songs with golden accents and record-inspired design
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // Load favorites when page opens
    Future.microtask(() => ref.read(favoritesProvider.notifier).loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Deep black for vinyl feel
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Retro-styled App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0D0D0D),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'FAVORITES',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: Color(0xFFD4AF37), // Golden
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
                  // Vinyl record texture background
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF0D0D0D),
                          const Color(0xFF000000),
                        ],
                      ),
                    ),
                  ),
                  // Grooves pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: VinylGroovesPainter(),
                    ),
                  ),
                  // Golden glow
                  Positioned(
                    top: 40,
                    right: 20,
                    child: Container(
                      width: 100,
                      height: 100,
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
                  ),
                ],
              ),
            ),
          ),

          // Content
          favoritesAsync.when(
            data: (favorites) {
              if (favorites.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = favorites[index];
                      return _SongTile(
                        song: song,
                        index: index,
                        onToggleFavorite: () async {
                          await ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(song.id!);
                        },
                      ).animate().fadeIn(
                            delay: (index * 50).ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ).slideX(
                            begin: -0.2,
                            end: 0,
                            delay: (index * 50).ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                    childCount: favorites.length,
                  ),
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFFD4AF37),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading your favorites...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'DM Sans',
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
                      'Failed to load favorites',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
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
          // Vinyl record icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 64,
              color: Color(0xFFD4AF37),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .shimmer(
                duration: 2000.ms,
                color: const Color(0xFFD4AF37).withOpacity(0.3),
              ),
          const SizedBox(height: 32),
          Text(
            'No Favorites Yet',
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
            'Songs you love will appear here',
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

/// Song Tile with retro styling
class _SongTile extends StatelessWidget {
  final SongModel song;
  final int index;
  final VoidCallback onToggleFavorite;

  const _SongTile({
    required this.song,
    required this.index,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF0D0D0D),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFD4AF37).withOpacity(0.1),
          onTap: () {
            // TODO: Play song
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Album art placeholder with vinyl style
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2A2A2A),
                        const Color(0xFF1A1A1A),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.album,
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                      size: 32,
                    ),
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
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.displayArtist,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: const Color(0xFFD4AF37).withOpacity(0.7),
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.formattedDuration,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),

                // Favorite button
                FavoriteButton(
                  isFavorite: song.isFavorite,
                  onToggle: onToggleFavorite,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for vinyl grooves effect
class VinylGroovesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0xFFD4AF37).withOpacity(0.03);

    final center = Offset(size.width * 0.8, size.height * 0.3);

    for (int i = 1; i <= 8; i++) {
      canvas.drawCircle(
        center,
        i * 20.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
