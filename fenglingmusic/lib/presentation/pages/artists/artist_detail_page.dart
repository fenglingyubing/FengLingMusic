import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/artist_model.dart';
import '../../../data/models/album_model.dart';
import '../../../data/models/song_model.dart';
import '../../providers/artist_provider.dart';
import '../../widgets/album_card.dart';
import '../../widgets/song_tile.dart';

/// Artist detail page with immersive hero header
/// Features: Blurred background, parallax scrolling, tabs for songs/albums
class ArtistDetailPage extends ConsumerStatefulWidget {
  final ArtistModel artist;

  const ArtistDetailPage({
    super.key,
    required this.artist,
  });

  @override
  ConsumerState<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends ConsumerState<ArtistDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Blurred background from artist image
          _buildBlurredBackground(colorScheme),

          // Main content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero header with artist info
              _buildHeroHeader(context, colorScheme, mediaQuery),

              // Action buttons
              _buildActionButtons(context, colorScheme),

              // Tab bar
              _buildTabBar(context, colorScheme),

              // Tab content
              _buildTabContent(context, colorScheme),

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
            child: _buildBackButton(colorScheme),
          ),

          // More button
          Positioned(
            top: mediaQuery.padding.top + 8,
            right: 8,
            child: _buildMoreButton(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredBackground(ColorScheme colorScheme) {
    if (widget.artist.coverPath != null && widget.artist.coverPath!.isNotEmpty) {
      final file = File(widget.artist.coverPath!);
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
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  color: colorScheme.surface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }
    }

    // Fallback gradient background
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    ColorScheme colorScheme,
    MediaQueryData mediaQuery,
  ) {
    final headerHeight = 400.0;
    final minHeaderHeight = 120.0 + mediaQuery.padding.top;
    final delta = headerHeight - minHeaderHeight;

    // Calculate parallax and fade based on scroll
    final parallaxOffset = (_scrollOffset * 0.5).clamp(0.0, delta);
    final opacity = (1.0 - (_scrollOffset / delta)).clamp(0.0, 1.0);
    final scale = (1.0 - (_scrollOffset / (delta * 2))).clamp(0.8, 1.0);

    return SliverAppBar(
      expandedHeight: headerHeight,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Artist image with parallax
            Positioned(
              top: -parallaxOffset,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: opacity,
                child: _buildArtistImage(scale),
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      colorScheme.surface.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),

            // Artist info
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Opacity(
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Artist name
                    Text(
                      widget.artist.name,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -1,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 8,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Stats
                    Wrap(
                      spacing: 16,
                      children: [
                        _buildStat(
                          Icons.audiotrack,
                          '${widget.artist.songCount} songs',
                        ),
                        _buildStat(
                          Icons.album,
                          '${widget.artist.albumCount} albums',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistImage(double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(60),
        child: Center(
          child: _buildArtistAvatar(),
        ),
      ),
    );
  }

  Widget _buildArtistAvatar() {
    if (widget.artist.coverPath != null && widget.artist.coverPath!.isNotEmpty) {
      final file = File(widget.artist.coverPath!);
      if (file.existsSync()) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.file(
              file,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    // Placeholder with first letter
    final hue = (widget.artist.name.hashCode % 360).toDouble();
    final color = HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.artist.name.isNotEmpty
              ? widget.artist.name[0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  // TODO: Play all songs
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play All'),
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
                  // TODO: Shuffle play
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
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, ColorScheme colorScheme) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        tabController: _tabController,
        colorScheme: colorScheme,
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, ColorScheme colorScheme) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildSongsTab(context, colorScheme),
          _buildAlbumsTab(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSongsTab(BuildContext context, ColorScheme colorScheme) {
    final songsAsync = ref.watch(artistSongsProvider(widget.artist.id ?? 0));

    return songsAsync.when(
      data: (songs) {
        if (songs.isEmpty) {
          return _buildEmptyState('No songs found', Icons.music_note);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            // TODO: Replace with actual SongTile widget
            return ListTile(
              title: Text('Song ${index + 1}'),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildAlbumsTab(BuildContext context, ColorScheme colorScheme) {
    final albumsAsync = ref.watch(artistAlbumsProvider(widget.artist.id ?? 0));

    return albumsAsync.when(
      data: (albums) {
        if (albums.isEmpty) {
          return _buildEmptyState('No albums found', Icons.album);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            // TODO: Replace with actual AlbumCard widget
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Album ${index + 1}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBackButton(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildMoreButton(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            // TODO: Show more options
          },
        ),
      ),
    );
  }
}

/// Custom delegate for pinned tab bar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final ColorScheme colorScheme;

  _TabBarDelegate({
    required this.tabController,
    required this.colorScheme,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: colorScheme.surface.withOpacity(0.95),
      child: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Songs'),
          Tab(text: 'Albums'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
