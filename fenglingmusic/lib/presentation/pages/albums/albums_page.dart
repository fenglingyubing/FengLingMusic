import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/album_model.dart';
import '../../widgets/album_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../providers/album_provider.dart';

/// Albums page with vinyl record store aesthetic
/// Features: Grid layout emphasizing album artwork, fluid animations
class AlbumsPage extends ConsumerStatefulWidget {
  const AlbumsPage({super.key});

  @override
  ConsumerState<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends ConsumerState<AlbumsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final albumsAsync = ref.watch(albumsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Dramatic header
          _buildDramaticHeader(context, colorScheme),

          // Search bar
          if (_isSearching) _buildSearchBar(context, colorScheme),

          // Content
          albumsAsync.when(
            data: (albums) {
              final filteredAlbums = _filterAlbums(albums);

              if (filteredAlbums.isEmpty) {
                return _buildEmptyState(context, colorScheme);
              }

              return _buildAlbumsGrid(context, filteredAlbums, colorScheme);
            },
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(context, error, colorScheme),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildDramaticHeader(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.biggest.height;
          final currentHeight = constraints.biggest.height;
          final minHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
          final delta = maxHeight - minHeight;
          final ratio = ((currentHeight - minHeight) / delta).clamp(0.0, 1.0);

          return Stack(
            children: [
              // Gradient background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        colorScheme.tertiaryContainer.withOpacity(0.3),
                        colorScheme.surface,
                      ],
                    ),
                  ),
                ),
              ),

              // Content with parallax
              Positioned(
                left: 20,
                right: 20,
                bottom: 20 + (40 * ratio),
                child: Opacity(
                  opacity: ratio,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'ALBUMS',
                        style: TextStyle(
                          fontSize: 48 + (12 * ratio),
                          fontWeight: FontWeight.w900,
                          height: 0.9,
                          letterSpacing: -2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Consumer(
                        builder: (context, ref, _) {
                          final albumsAsync = ref.watch(albumsProvider);
                          return albumsAsync.when(
                            data: (albums) => Text(
                              '${albums.length} albums in your collection',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Collapsed title
              Positioned(
                left: 20,
                bottom: 16,
                child: Opacity(
                  opacity: 1 - ratio,
                  child: Text(
                    'Albums',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // Action buttons
              Positioned(
                right: 8,
                bottom: 8,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isSearching ? Icons.close : Icons.search,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) {
                            _searchQuery = '';
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.sort,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () => _showSortOptions(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: TextField(
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search albums...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumsGrid(
    BuildContext context,
    List<AlbumModel> albums,
    ColorScheme colorScheme,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final album = albums[index];

            // Staggered animation delay
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 800)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: AlbumCard(
                album: album,
                onTap: () => _navigateToAlbumDetail(album),
              ),
            );
          },
          childCount: albums.length,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ShimmerLoading(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 12,
          ),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.album,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching ? 'No albums found' : 'No albums yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSearching
                  ? 'Try a different search term'
                  : 'Scan your music library to get started',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    Object error,
    ColorScheme colorScheme,
  ) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load albums',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.refresh(albumsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<AlbumModel> _filterAlbums(List<AlbumModel> albums) {
    if (_searchQuery.isEmpty) return albums;

    return albums.where((album) {
      final query = _searchQuery.toLowerCase();
      return album.title.toLowerCase().contains(query) ||
          (album.artist?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _navigateToAlbumDetail(AlbumModel album) {
    Navigator.of(context).pushNamed(
      '/album-detail',
      arguments: album,
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Sort by',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              _buildSortOption(context, 'Title (A-Z)', Icons.sort_by_alpha),
              _buildSortOption(context, 'Artist', Icons.person),
              _buildSortOption(context, 'Year', Icons.calendar_today),
              _buildSortOption(context, 'Recently added', Icons.access_time),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        // TODO: Implement sorting
      },
    );
  }
}
