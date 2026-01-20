import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/album_model.dart';
import '../../../data/models/song_model.dart';
import '../../providers/album_provider.dart';
import '../../widgets/song_tile.dart';

/// Album detail page with immersive vinyl record aesthetic
/// Features: Large album artwork, blurred background, track list
class AlbumDetailPage extends ConsumerWidget {
  final AlbumModel album;

  const AlbumDetailPage({
    super.key,
    required this.album,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final songsAsync = ref.watch(albumSongsProvider(album.id ?? 0));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Blurred background
          _buildBlurredBackground(colorScheme),

          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Album header
              SliverAppBar(
                expandedHeight: 450,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildAlbumHeader(context, colorScheme),
                ),
              ),

              // Action buttons
              SliverToBoxAdapter(
                child: _buildActionButtons(context, colorScheme),
              ),

              // Songs list
              songsAsync.when(
                data: (songs) {
                  if (songs.isEmpty) {
                    return _buildEmptyState(colorScheme);
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songs[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: index == 0 ? 8 : 0,
                          ),
                          child: SongTile(
                            song: song,
                            trackNumber: index + 1,
                            onTap: () {
                              // TODO: Play song
                            },
                          ),
                        );
                      },
                      childCount: songs.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'Error: $error',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // Back button
          Positioned(
            top: mediaQuery.padding.top + 8,
            left: 8,
            child: _buildGlassButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // More button
          Positioned(
            top: mediaQuery.padding.top + 8,
            right: 8,
            child: _buildGlassButton(
              icon: Icons.more_vert,
              onPressed: () {
                // TODO: Show more options
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredBackground(ColorScheme colorScheme) {
    if (album.coverPath != null && album.coverPath!.isNotEmpty) {
      final file = File(album.coverPath!);
      if (file.existsSync()) {
        return Positioned.fill(
          child: Stack(
            children: [
              Image.file(
                file,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  color: colorScheme.surface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      }
    }

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.tertiaryContainer,
              colorScheme.surface,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Album artwork - vinyl style with shadow
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildAlbumCover(colorScheme),
            ),
          ),
          const SizedBox(height: 24),

          // Album info
          Column(
            children: [
              // Album title
              Text(
                album.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 8,
                      color: Colors.black38,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Artist and year
              Text(
                album.displayArtist +
                    (album.year != null ? ' • ${album.year}' : ''),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Song count and duration
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.audiotrack,
                    size: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${album.songCount} songs',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  if (album.totalDuration > 0) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(album.totalDuration),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumCover(ColorScheme colorScheme) {
    if (album.coverPath != null && album.coverPath!.isNotEmpty) {
      final file = File(album.coverPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(colorScheme);
          },
        );
      }
    }

    return _buildPlaceholder(colorScheme);
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    final hue = (album.title.hashCode % 360).toDouble();
    final color = HSLColor.fromAHSL(1.0, hue, 0.5, 0.4).toColor();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.6)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.album,
          size: 120,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                // TODO: Play all songs
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Shuffle
              },
              icon: const Icon(Icons.shuffle),
              label: const Text('Shuffle'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No songs in this album',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }
}
