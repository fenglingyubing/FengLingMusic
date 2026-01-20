import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/online_song.dart';
import '../../services/online/multi_platform_search_service.dart';

/// 在线搜索状态
class OnlineSearchState {
  final List<OnlineSong> songs;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String query;
  final List<String> selectedPlatforms;
  final int currentPage;
  final bool hasMore;

  const OnlineSearchState({
    this.songs = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.query = '',
    this.selectedPlatforms = const ['netease', 'qq', 'kugou'],
    this.currentPage = 1,
    this.hasMore = true,
  });

  OnlineSearchState copyWith({
    List<OnlineSong>? songs,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? query,
    List<String>? selectedPlatforms,
    int? currentPage,
    bool? hasMore,
  }) {
    return OnlineSearchState(
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      query: query ?? this.query,
      selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// 在线搜索Provider
class OnlineSearchNotifier extends StateNotifier<OnlineSearchState> {
  final MultiPlatformSearchService _searchService;

  OnlineSearchNotifier(this._searchService) : super(const OnlineSearchState());

  /// 搜索歌曲
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const OnlineSearchState();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      query: query,
      currentPage: 1,
      songs: [],
    );

    try {
      final results = await _searchService.searchSongs(
        keyword: query,
        platforms: state.selectedPlatforms,
        limit: 20,
        page: 1,
      );

      state = state.copyWith(
        songs: results,
        isLoading: false,
        hasMore: results.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '搜索失败: $e',
      );
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.query.isEmpty) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final results = await _searchService.searchSongs(
        keyword: state.query,
        platforms: state.selectedPlatforms,
        limit: 20,
        page: nextPage,
      );

      state = state.copyWith(
        songs: [...state.songs, ...results],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: results.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: '加载更多失败: $e',
      );
    }
  }

  /// 切换平台选择
  void togglePlatform(String platform) {
    final platforms = List<String>.from(state.selectedPlatforms);

    if (platforms.contains(platform)) {
      if (platforms.length > 1) {
        platforms.remove(platform);
      }
    } else {
      platforms.add(platform);
    }

    state = state.copyWith(selectedPlatforms: platforms);

    // 重新搜索
    if (state.query.isNotEmpty) {
      search(state.query);
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 重试
  Future<void> retry() async {
    if (state.query.isNotEmpty) {
      await search(state.query);
    }
  }
}

/// Provider实例
final onlineSearchProvider =
    StateNotifierProvider<OnlineSearchNotifier, OnlineSearchState>(
  (ref) => OnlineSearchNotifier(MultiPlatformSearchService()),
);
