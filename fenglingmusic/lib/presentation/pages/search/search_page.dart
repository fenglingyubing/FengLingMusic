import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/song_model.dart';
import '../../../services/search/local_search_service.dart';
import '../../../services/search/search_history_service.dart';
import '../../widgets/song_tile.dart';
import 'dart:async';

/// Search page with "Flow Wave" aesthetic
/// Features breathing glow search bar, wave animations, and flowing history tags
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LocalSearchService _searchService = LocalSearchService();
  final SearchHistoryService _historyService = SearchHistoryService();

  SearchResults? _results;
  List<String> _searchHistory = [];
  bool _isSearching = false;
  bool _showHistory = true;
  Timer? _debounceTimer;

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _initServices();
    _searchFocusNode.addListener(_onFocusChange);

    // Glow animation controller for search bar
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initServices() async {
    await _historyService.init();
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getRecentSearches();
    setState(() {
      _searchHistory = history;
    });
  }

  void _onFocusChange() {
    setState(() {
      _showHistory = _searchFocusNode.hasFocus && _searchController.text.isEmpty;
    });
  }

  void _onSearchChanged(String query) {
    // Debounce search
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });

    setState(() {
      _showHistory = query.isEmpty;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _searchService.search(query);

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  Future<void> _onHistoryTap(String query) async {
    _searchController.text = query;
    _searchFocusNode.unfocus();
    await _performSearch(query);
    await _historyService.addQuery(query);
    await _loadHistory();
  }

  Future<void> _onSearchSubmitted(String query) async {
    if (query.trim().isEmpty) return;

    _searchFocusNode.unfocus();
    await _historyService.addQuery(query);
    await _loadHistory();
  }

  Future<void> _clearHistory() async {
    await _historyService.clearHistory();
    await _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header with search bar
            _buildHeader(theme, isDark),

            // Content area
            Expanded(
              child: _showHistory
                  ? _buildHistorySection(theme, isDark)
                  : _buildResultsSection(theme, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1F35),
                  const Color(0xFF0F1420),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF0F1F5),
                ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
                color: isDark ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 8),
              Text(
                'Search',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar with breathing glow effect
          _buildSearchBar(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isDark
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF818CF8))
                    .withOpacity(0.2 * _glowController.value),
                blurRadius: 20 + (10 * _glowController.value),
                spreadRadius: 2 * _glowController.value,
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      color: isDark ? Colors.white54 : Colors.black45,
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF1E2435)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistorySection(ThemeData theme, bool isDark) {
    if (_searchHistory.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: 'No search history',
        subtitle: 'Your recent searches will appear here',
        isDark: isDark,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _clearHistory,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flowing tag cloud
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _searchHistory.asMap().entries.map((entry) {
              final index = entry.key;
              final query = entry.value;

              return _buildHistoryChip(query, index, isDark)
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 50 * index),
                    duration: const Duration(milliseconds: 400),
                  )
                  .slideX(
                    begin: 0.2,
                    delay: Duration(milliseconds: 50 * index),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                  );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChip(String query, int index, bool isDark) {
    return InkWell(
      onTap: () => _onHistoryTap(query),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Color.lerp(
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
                      (index % 3) / 3,
                    )!.withOpacity(0.15),
                    Color.lerp(
                      const Color(0xFF8B5CF6),
                      const Color(0xFF6366F1),
                      (index % 3) / 3,
                    )!.withOpacity(0.25),
                  ]
                : [
                    Color.lerp(
                      const Color(0xFFEEF2FF),
                      const Color(0xFFF5F3FF),
                      (index % 3) / 3,
                    )!,
                    Color.lerp(
                      const Color(0xFFF5F3FF),
                      const Color(0xFFEEF2FF),
                      (index % 3) / 3,
                    )!,
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 16,
              color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
            ),
            const SizedBox(width: 8),
            Text(
              query,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(ThemeData theme, bool isDark) {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(
                  isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Searching...',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: const Duration(seconds: 2)),
      );
    }

    if (_results == null || _results!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        subtitle: 'Try searching for something else',
        isDark: isDark,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Songs
          if (_results!.songs.isNotEmpty) ...[
            _buildSectionHeader('Songs', _results!.songs.length, isDark),
            const SizedBox(height: 12),
            ..._results!.songs.asMap().entries.map((entry) {
              final index = entry.key;
              final song = entry.value;
              return _buildSongItem(song, index, isDark);
            }).toList(),
            const SizedBox(height: 24),
          ],

          // Artists
          if (_results!.artists.isNotEmpty) ...[
            _buildSectionHeader('Artists', _results!.artists.length, isDark),
            const SizedBox(height: 12),
            ..._results!.artists.asMap().entries.map((entry) {
              final index = entry.key;
              final artist = entry.value;
              return _buildArtistItem(artist, index, isDark);
            }).toList(),
            const SizedBox(height: 24),
          ],

          // Albums
          if (_results!.albums.isNotEmpty) ...[
            _buildSectionHeader('Albums', _results!.albums.length, isDark),
            const SizedBox(height: 12),
            ..._results!.albums.asMap().entries.map((entry) {
              final index = entry.key;
              final album = entry.value;
              return _buildAlbumItem(album, index, isDark);
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8),
                isDark ? const Color(0xFF8B5CF6) : const Color(0xFFA78BFA),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF6366F1).withOpacity(0.2)
                : const Color(0xFF818CF8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSongItem(SongModel song, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E2435),
                  const Color(0xFF1A1F35),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F9FA),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: SongTile(
        song: song,
        showAlbumArt: true,
        onTap: () {
          // TODO: Play song
        },
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(
          begin: 0.1,
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildArtistItem(String artist, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isDark
              ? const Color(0xFF6366F1).withOpacity(0.2)
              : const Color(0xFFEEF2FF),
          child: Icon(
            Icons.person_rounded,
            color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
          ),
        ),
        title: Text(
          artist,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isDark ? const Color(0xFF1E2435) : Colors.white,
        onTap: () {
          // TODO: Navigate to artist page
        },
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(
          begin: 0.1,
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildAlbumItem(String album, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF8B5CF6) : const Color(0xFFA78BFA),
                isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.album_rounded,
            color: Colors.white,
          ),
        ),
        title: Text(
          album,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isDark ? const Color(0xFF1E2435) : Colors.white,
        onTap: () {
          // TODO: Navigate to album page
        },
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(
          begin: 0.1,
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF6366F1).withOpacity(0.2),
                        const Color(0xFF8B5CF6).withOpacity(0.2),
                      ]
                    : [
                        const Color(0xFFEEF2FF),
                        const Color(0xFFF5F3FF),
                      ],
              ),
            ),
            child: Icon(
              icon,
              size: 60,
              color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
  }
}
