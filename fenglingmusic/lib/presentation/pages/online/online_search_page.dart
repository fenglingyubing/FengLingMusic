import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../providers/online_search_provider.dart';
import '../../widgets/online_song_tile.dart';
import '../../widgets/platform_filter_chip.dart';

/// 在线音乐搜索页面
///
/// 设计理念：数字风铃 - 轻盈、飘逸、灵动
class OnlineSearchPage extends ConsumerStatefulWidget {
  const OnlineSearchPage({super.key});

  @override
  ConsumerState<OnlineSearchPage> createState() => _OnlineSearchPageState();
}

class _OnlineSearchPageState extends ConsumerState<OnlineSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// 滚动监听 - 加载更多
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(onlineSearchProvider.notifier).loadMore();
    }
  }

  /// 防抖搜索
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(onlineSearchProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(onlineSearchProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          if (searchState.query.isNotEmpty) {
            await ref.read(onlineSearchProvider.notifier).search(searchState.query);
          }
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 浮动搜索栏
            _buildFloatingSearchBar(theme, searchState),

            // 平台筛选器
            _buildPlatformFilters(theme, searchState),

            // 搜索结果
            if (searchState.isLoading)
              _buildLoadingState()
            else if (searchState.error != null)
              _buildErrorState(theme, searchState)
            else if (searchState.songs.isEmpty && searchState.query.isNotEmpty)
              _buildEmptyState(theme)
            else if (searchState.songs.isEmpty)
              _buildInitialState(theme)
            else
              _buildSearchResults(searchState),

            // 加载更多指示器
            if (searchState.isLoadingMore)
              SliverToBoxAdapter(
                child: _buildLoadingMore(),
              ),

            // 底部间距
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建浮动搜索栏
  Widget _buildFloatingSearchBar(ThemeData theme, OnlineSearchState state) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      expandedHeight: 140,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withOpacity(0.0),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: '搜索在线音乐...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                suffixIcon: state.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(onlineSearchProvider.notifier).search('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
              .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic)
              .shimmer(
                duration: 2000.ms,
                delay: 400.ms,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
        ),
      ),
    );
  }

  /// 构建平台筛选器
  Widget _buildPlatformFilters(ThemeData theme, OnlineSearchState state) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Text(
              '音乐平台',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    PlatformFilterChip(
                      label: '网易云',
                      platform: 'netease',
                      icon: Icons.cloud_outlined,
                      color: const Color(0xFFD43C33),
                      isSelected: state.selectedPlatforms.contains('netease'),
                      onTap: () {
                        ref
                            .read(onlineSearchProvider.notifier)
                            .togglePlatform('netease');
                      },
                    ),
                    const SizedBox(width: 8),
                    PlatformFilterChip(
                      label: 'QQ音乐',
                      platform: 'qq',
                      icon: Icons.music_note_rounded,
                      color: const Color(0xFF31C27C),
                      isSelected: state.selectedPlatforms.contains('qq'),
                      onTap: () {
                        ref
                            .read(onlineSearchProvider.notifier)
                            .togglePlatform('qq');
                      },
                    ),
                    const SizedBox(width: 8),
                    PlatformFilterChip(
                      label: '酷狗',
                      platform: 'kugou',
                      icon: Icons.audiotrack_rounded,
                      color: const Color(0xFF2C9EF8),
                      isSelected: state.selectedPlatforms.contains('kugou'),
                      onTap: () {
                        ref
                            .read(onlineSearchProvider.notifier)
                            .togglePlatform('kugou');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: 200.ms, duration: 400.ms)
          .slideX(begin: -0.1, end: 0),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '搜索中...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1500.ms),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(ThemeData theme, OnlineSearchState state) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut)
                .shake(duration: 500.ms),
            const SizedBox(height: 16),
            Text(
              state.error ?? '未知错误',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(onlineSearchProvider.notifier).retry();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重试'),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off_rounded,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .fadeIn(duration: 1000.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),
            const SizedBox(height: 24),
            Text(
              '没有找到相关歌曲',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '试试其他关键词或平台',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
      ),
    );
  }

  /// 构建初始状态
  Widget _buildInitialState(ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .fadeIn(duration: 1000.ms)
                .rotate(begin: -0.05, end: 0.05, duration: 2000.ms),
            const SizedBox(height: 24),
            Text(
              '搜索在线音乐',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '输入歌曲名、歌手或专辑',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
      ),
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults(OnlineSearchState state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final song = state.songs[index];
            return OnlineSongTile(
              song: song,
              index: index,
            );
          },
          childCount: state.songs.length,
        ),
      ),
    );
  }

  /// 构建加载更多指示器
  Widget _buildLoadingMore() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1500.ms);
  }
}
