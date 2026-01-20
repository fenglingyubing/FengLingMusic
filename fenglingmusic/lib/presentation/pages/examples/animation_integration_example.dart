import 'package:flutter/material.dart';
import '../../animations/list_animations.dart';
import '../../animations/player_animations.dart';
import '../../animations/micro_interactions.dart';
import '../../../data/models/song_model.dart';

/// Example: Enhanced Song List with Advanced Animations
/// Shows integration of Task 4.12 animations in a real list
class EnhancedSongList extends StatefulWidget {
  final List<SongModel> songs;
  final Function(SongModel) onSongTap;
  final Function(SongModel) onFavoriteToggle;

  const EnhancedSongList({
    super.key,
    required this.songs,
    required this.onSongTap,
    required this.onFavoriteToggle,
  });

  @override
  State<EnhancedSongList> createState() => _EnhancedSongListState();
}

class _EnhancedSongListState extends State<EnhancedSongList> {
  final Set<int> _favoriteSongs = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.songs.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final song = widget.songs[index];

        // Wrap each item with staggered entry animation
        return ListAnimations.staggeredEntry(
          index: index,
          maxItems: 20, // Limit stagger to first 20 items
          child: _buildSongTile(song, index),
        );
      },
    );
  }

  Widget _buildSongTile(SongModel song, int index) {
    final isFavorite = song.id != null && _favoriteSongs.contains(song.id!);

    return MicroInteractions.rippleButton(
      onTap: () => widget.onSongTap(song),
      borderRadius: BorderRadius.circular(12),
      hapticFeedback: HapticFeedbackType.light,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Album art
            _buildAlbumArt(song),
            const SizedBox(width: 12),

            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist ?? 'Unknown Artist',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Duration
            Text(
              _formatDuration(song.duration),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
              ),
            ),

            const SizedBox(width: 8),

            // Favorite button with enhanced animation
            MicroInteractions.favoriteButton(
              isFavorite: isFavorite,
              onToggle: () {
                if (song.id != null) {
                  setState(() {
                    if (isFavorite) {
                      _favoriteSongs.remove(song.id!);
                    } else {
                      _favoriteSongs.add(song.id!);
                    }
                  });
                  widget.onFavoriteToggle(song);
                }
              },
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt(SongModel song) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: song.coverPath != null
            ? Image.network(
                song.coverPath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.music_note,
      size: 24,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds.remainder(60);
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

/// Example: Player Page with Advanced Animations
class EnhancedPlayerPage extends StatefulWidget {
  final SongModel currentSong;
  final bool isPlaying;
  final Function() onPlayPause;
  final Function() onNext;
  final Function() onPrevious;

  const EnhancedPlayerPage({
    super.key,
    required this.currentSong,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<EnhancedPlayerPage> createState() => _EnhancedPlayerPageState();
}

class _EnhancedPlayerPageState extends State<EnhancedPlayerPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  MicroInteractions.bouncingButton(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.keyboard_arrow_down, size: 32),
                  ),
                  const Spacer(),
                  Text(
                    'Now Playing',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  SizedBox(width: 32), // Balance the layout
                ],
              ),
            ),

            const Spacer(),

            // Album cover with rotation
            PlayerAnimations.rotatingAlbum(
              isPlaying: widget.isPlaying,
              size: MediaQuery.of(context).size.width * 0.7,
              child: widget.currentSong.coverPath != null
                  ? Image.network(
                      widget.currentSong.coverPath!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.album,
                        size: 80,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
            ),

            const Spacer(),

            // Song info with transition
            PlayerAnimations.songTransition(
              songId: widget.currentSong.id?.toString() ?? '0',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      widget.currentSong.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.currentSong.artist ?? 'Unknown Artist',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MicroInteractions.bouncingButton(
                  onTap: widget.onPrevious,
                  child: Icon(Icons.skip_previous, size: 40),
                ),
                const SizedBox(width: 40),

                // Play/Pause with animation
                PlayerAnimations.playPauseButton(
                  isPlaying: widget.isPlaying,
                  onTap: widget.onPlayPause,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(width: 40),
                MicroInteractions.bouncingButton(
                  onTap: widget.onNext,
                  child: Icon(Icons.skip_next, size: 40),
                ),
              ],
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
