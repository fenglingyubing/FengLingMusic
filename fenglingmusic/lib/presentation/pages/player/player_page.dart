import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/lyrics_view.dart';

/// Full-screen music player with "Vinyl Lounge" aesthetic
///
/// Design Philosophy: Editorial Poetry meets analog warmth
/// - Rotating vinyl-style album art with depth
/// - Refined typography and generous spacing
/// - Layered blur effects for atmospheric depth
/// - 120fps smooth animations throughout
/// - Tactile, satisfying interactions
class PlayerPage extends ConsumerStatefulWidget {
  final String? albumCoverUrl;
  final String heroTag;
  final String songTitle;
  final String artistName;
  final String? albumName;

  const PlayerPage({
    Key? key,
    this.albumCoverUrl,
    this.heroTag = 'album_cover',
    required this.songTitle,
    required this.artistName,
    this.albumName,
  }) : super(key: key);

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage>
    with TickerProviderStateMixin {
  late AnimationController _vinylRotationController;
  late AnimationController _pageEntryController;
  late AnimationController _controlsController;

  bool _showLyrics = false;
  bool _showQueue = false;
  double _currentPosition = 0.3; // TODO: Connect to actual audio position
  final bool _isPlaying = true; // TODO: Connect to actual play state

  @override
  void initState() {
    super.initState();

    // Vinyl rotation animation (continuous when playing)
    _vinylRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Page entry staggered animation
    _pageEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // Controls hover/press animations
    _controlsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _vinylRotationController.dispose();
    _pageEntryController.dispose();
    _controlsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Background: Blurred album art with atmospheric gradient
          _buildAtmosphericBackground(),

          // Main content with staggered entry animations
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Album artwork section with vinyl aesthetic
                Expanded(
                  flex: 5,
                  child: _buildVinylSection(size),
                ),

                const SizedBox(height: 32),

                // Song info section
                _buildSongInfoSection(theme),

                const SizedBox(height: 24),

                // Lyrics toggle and view
                if (_showLyrics) ...[
                  Expanded(
                    flex: 4,
                    child: _buildLyricsSection(),
                  ),
                ] else ...[
                  // Progress bar with tonearm aesthetic
                  _buildProgressSection(theme, size),

                  const SizedBox(height: 32),

                  // Playback controls
                  _buildPlaybackControls(theme),

                  const SizedBox(height: 16),

                  // Secondary controls (shuffle, repeat, etc.)
                  _buildSecondaryControls(theme),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Queue drawer (slides from bottom)
          if (_showQueue) _buildQueueDrawer(context, size),
        ],
      ),
    );
  }

  // ==================== UI SECTIONS ====================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          foregroundColor: Colors.white.withOpacity(0.9),
        ),
      ),
      actions: [
        // Lyrics toggle
        IconButton(
          icon: Icon(_showLyrics ? Icons.lyrics_outlined : Icons.lyrics),
          onPressed: () => setState(() => _showLyrics = !_showLyrics),
          style: IconButton.styleFrom(
            foregroundColor: Colors.white.withOpacity(0.9),
          ),
        ),

        // Queue toggle
        IconButton(
          icon: const Icon(Icons.queue_music_rounded),
          onPressed: () => setState(() => _showQueue = !_showQueue),
          style: IconButton.styleFrom(
            foregroundColor: Colors.white.withOpacity(0.9),
          ),
        ),

        // More options
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: _showOptionsMenu,
          style: IconButton.styleFrom(
            foregroundColor: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildAtmosphericBackground() {
    return Stack(
      children: [
        // Blurred album art background
        if (widget.albumCoverUrl != null)
          Positioned.fill(
            child: Image.network(
              widget.albumCoverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade900,
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Heavy blur layer
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),

        // Atmospheric gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.95),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVinylSection(Size size) {
    final artSize = size.width * 0.75;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _pageEntryController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _pageEntryController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: artSize + 40,
                height: artSize + 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),

              // Vinyl record base (rotates with music)
              RotationTransition(
                turns: _vinylRotationController,
                child: Container(
                  width: artSize,
                  height: artSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.grey.shade900,
                        Colors.black,
                      ],
                      stops: const [0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Vinyl grooves effect
                      ...List.generate(8, (i) {
                        final radius = 0.4 + (i * 0.05);
                        return Container(
                          width: artSize * radius,
                          height: artSize * radius,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.03),
                              width: 1,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Album cover (Hero animation, static - doesn't rotate)
              Hero(
                tag: widget.heroTag,
                child: Container(
                  width: artSize * 0.65,
                  height: artSize * 0.65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.albumCoverUrl != null
                        ? Image.network(
                            widget.albumCoverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholderArt(),
                          )
                        : _buildPlaceholderArt(),
                  ),
                ),
              ),

              // Center label
              Container(
                width: artSize * 0.15,
                height: artSize * 0.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black87,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderArt() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade800,
            Colors.grey.shade900,
          ],
        ),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        size: 64,
        color: Colors.white38,
      ),
    );
  }

  Widget _buildSongInfoSection(ThemeData theme) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _pageEntryController,
          curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            // Song title (Serif font for editorial feel)
            Text(
              widget.songTitle,
              style: const TextStyle(
                fontFamily: 'Serif',
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Artist name
            Text(
              widget.artistName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Album name (if provided)
            if (widget.albumName != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.albumName!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLyricsSection() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _pageEntryController,
          curve: Curves.easeInOut,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withOpacity(0.3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: const LyricsView(
              accentColor: Colors.white,
              showTranslation: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(ThemeData theme, Size size) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _pageEntryController,
          curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Custom progress bar with vinyl tonearm aesthetic
            SizedBox(
              height: 24,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track background
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),

                  // Progress fill
                  FractionallySizedBox(
                    widthFactor: _currentPosition,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Tonearm handle (draggable)
                  Positioned(
                    left: size.width * 0.85 * _currentPosition - 12,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _currentPosition = (_currentPosition + details.delta.dx / (size.width * 0.85))
                              .clamp(0.0, 1.0);
                        });
                        // TODO: Seek audio position
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Time labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(Duration(seconds: (180 * _currentPosition).round())),
                  style: TextStyle(
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                Text(
                  _formatDuration(const Duration(seconds: 180)), // TODO: Get actual duration
                  style: TextStyle(
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(ThemeData theme) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _pageEntryController,
          curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous track
          _buildControlButton(
            icon: Icons.skip_previous_rounded,
            size: 40,
            onPressed: () {
              // TODO: Previous track
            },
          ),

          const SizedBox(width: 24),

          // Play/Pause (large center button)
          _buildControlButton(
            icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 64,
            isPrimary: true,
            onPressed: () {
              // TODO: Toggle play/pause
              if (_isPlaying) {
                _vinylRotationController.stop();
              } else {
                _vinylRotationController.repeat();
              }
            },
          ),

          const SizedBox(width: 24),

          // Next track
          _buildControlButton(
            icon: Icons.skip_next_rounded,
            size: 40,
            onPressed: () {
              // TODO: Next track
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    final buttonSize = size * 1.5;

    return GestureDetector(
      onTapDown: (_) => _controlsController.forward(),
      onTapUp: (_) {
        _controlsController.reverse();
        onPressed();
      },
      onTapCancel: () => _controlsController.reverse(),
      child: AnimatedBuilder(
        animation: _controlsController,
        builder: (context, child) {
          final scale = 1.0 - (_controlsController.value * 0.1);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPrimary
                    ? Colors.white
                    : Colors.white.withOpacity(0.15),
                boxShadow: isPrimary
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: size,
                color: isPrimary ? Colors.black87 : Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSecondaryControls(ThemeData theme) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _pageEntryController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Shuffle
            IconButton(
              icon: const Icon(Icons.shuffle_rounded),
              onPressed: () {
                // TODO: Toggle shuffle
              },
              color: Colors.white.withOpacity(0.7),
            ),

            // Favorite
            IconButton(
              icon: const Icon(Icons.favorite_border_rounded),
              onPressed: () {
                // TODO: Toggle favorite
              },
              color: Colors.white.withOpacity(0.7),
            ),

            // Repeat
            IconButton(
              icon: const Icon(Icons.repeat_rounded),
              onPressed: () {
                // TODO: Toggle repeat mode
              },
              color: Colors.white.withOpacity(0.7),
            ),

            // Volume
            IconButton(
              icon: const Icon(Icons.volume_up_rounded),
              onPressed: () {
                // TODO: Show volume slider
              },
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueDrawer(BuildContext context, Size size) {
    return GestureDetector(
      onTap: () => setState(() => _showQueue = false),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                color: Colors.grey.shade900,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Column(
                    children: [
                      // Drawer handle
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),

                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '播放队列',
                              style: TextStyle(
                                fontFamily: 'Serif',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Clear queue
                              },
                              child: Text(
                                '清除全部',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1, color: Colors.white12),

                      // Queue list
                      Expanded(
                        child: _buildQueueList(scrollController),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQueueList(ScrollController scrollController) {
    // TODO: Replace with actual queue data from provider
    final demoQueue = List.generate(
      15,
      (i) => {
        'title': '歌曲标题 ${i + 1}',
        'artist': '艺术家',
        'duration': '3:${(20 + i * 5).toString().padLeft(2, '0')}',
        'isPlaying': i == 2,
      },
    );

    return ReorderableListView.builder(
      scrollController: scrollController,
      itemCount: demoQueue.length,
      onReorder: (oldIndex, newIndex) {
        // TODO: Reorder queue
      },
      itemBuilder: (context, index) {
        final item = demoQueue[index];
        final isPlaying = item['isPlaying'] as bool;

        return Dismissible(
          key: ValueKey('queue_$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: Colors.red.shade900,
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) {
            // TODO: Remove from queue
          },
          child: Container(
            decoration: BoxDecoration(
              color: isPlaying
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    isPlaying ? Icons.equalizer_rounded : Icons.music_note_rounded,
                    color: isPlaying ? Colors.white : Colors.white54,
                    size: 24,
                  ),
                ),
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(
                  color: isPlaying ? Colors.white : Colors.white.withOpacity(0.9),
                  fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item['artist'] as String,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['duration'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.drag_handle_rounded,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),
              onTap: () {
                // TODO: Jump to song in queue
              },
            ),
          ),
        );
      },
    );
  }

  // ==================== HELPER METHODS ====================

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          color: Colors.grey.shade900,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 24),
                _buildMenuItem(Icons.playlist_add, '添加到播放列表'),
                _buildMenuItem(Icons.share_rounded, '分享'),
                _buildMenuItem(Icons.info_outline_rounded, '歌曲信息'),
                _buildMenuItem(Icons.equalizer_rounded, '均衡器'),
                _buildMenuItem(Icons.timer_outlined, '睡眠定时'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(0.9)),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
        // TODO: Handle menu action
      },
    );
  }
}
