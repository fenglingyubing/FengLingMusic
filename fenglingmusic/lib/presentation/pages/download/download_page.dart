import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../data/models/download_item_model.dart';
import '../../../services/download/download_manager.dart';
import '../../widgets/download_item_tile.dart';

/// 下载页面
///
/// TASK-095 & TASK-096: 下载页面UI和控制
///
/// 设计风格：现代音乐应用 + Glassmorphism
/// - 流畅的120fps动画
/// - 波形进度动画
/// - 优雅的状态切换
/// - 手势交互
class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with SingleTickerProviderStateMixin {
  final DownloadManager _downloadManager = DownloadManager.instance;

  List<DownloadItemModel> _downloads = [];
  Map<int, double> _progressMap = {};
  Map<String, int> _statistics = {};

  late TabController _tabController;
  StreamSubscription<Map<int, double>>? _progressSubscription;
  StreamSubscription<DownloadItemModel>? _statusSubscription;

  // 筛选状态
  DownloadStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadDownloads();
    _loadStatistics();
    _subscribeToStreams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _progressSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  /// 订阅下载流
  void _subscribeToStreams() {
    _progressSubscription = _downloadManager.progressStream.listen((progressMap) {
      if (mounted) {
        setState(() {
          _progressMap = progressMap;
        });
      }
    });

    _statusSubscription = _downloadManager.statusStream.listen((item) {
      if (mounted) {
        _loadDownloads();
        _loadStatistics();
      }
    });
  }

  /// 加载下载列表
  Future<void> _loadDownloads() async {
    final downloads = await _downloadManager.getAllDownloads();
    if (mounted) {
      setState(() {
        _downloads = downloads;
      });
    }
  }

  /// 加载统计信息
  Future<void> _loadStatistics() async {
    final stats = await _downloadManager.getStatistics();
    if (mounted) {
      setState(() {
        _statistics = stats;
      });
    }
  }

  /// Tab切换
  void _onTabChanged() {
    final tabIndex = _tabController.index;
    setState(() {
      switch (tabIndex) {
        case 0:
          _filterStatus = null; // 全部
          break;
        case 1:
          _filterStatus = DownloadStatus.downloading; // 下载中
          break;
        case 2:
          _filterStatus = DownloadStatus.completed; // 已完成
          break;
        case 3:
          _filterStatus = DownloadStatus.failed; // 失败
          break;
      }
    });
  }

  /// 获取筛选后的下载列表
  List<DownloadItemModel> get _filteredDownloads {
    if (_filterStatus == null) {
      return _downloads;
    }
    return _downloads.where((item) => item.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar with tabs
          _buildAppBar(theme),

          // Statistics card
          _buildStatisticsCard(theme),

          // Action buttons
          _buildActionButtons(theme),

          // Download list
          _buildDownloadList(theme),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  /// 构建AppBar
  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      expandedHeight: 180,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.surface,
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '下载管理',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${_downloads.length} 个任务',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: [
              _buildTab('全部', _statistics['total'] ?? 0),
              _buildTab('下载中', (_statistics['downloading'] ?? 0) + (_statistics['pending'] ?? 0)),
              _buildTab('已完成', _statistics['completed'] ?? 0),
              _buildTab('失败', _statistics['failed'] ?? 0),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  /// 构建Tab
  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatisticsCard(ThemeData theme) {
    final downloading = (_statistics['downloading'] ?? 0);
    final pending = (_statistics['pending'] ?? 0);
    final activeCount = downloading + pending;

    if (activeCount == 0) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.5),
              theme.colorScheme.primaryContainer.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_download,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '正在下载',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$activeCount 个任务进行中',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2, end: 0),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(ThemeData theme) {
    final hasActive = (_statistics['downloading'] ?? 0) + (_statistics['pending'] ?? 0) > 0;
    final hasCompleted = (_statistics['completed'] ?? 0) > 0;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (hasActive) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _downloadManager.pauseAll();
                    _loadDownloads();
                    _loadStatistics();
                  },
                  icon: const Icon(Icons.pause_rounded),
                  label: const Text('全部暂停'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (hasCompleted)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _downloadManager.clearCompleted();
                    _loadDownloads();
                    _loadStatistics();
                  },
                  icon: const Icon(Icons.clear_all_rounded),
                  label: const Text('清除已完成'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  /// 构建下载列表
  Widget _buildDownloadList(ThemeData theme) {
    final filteredItems = _filteredDownloads;

    if (filteredItems.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(theme),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = filteredItems[index];
          final progress = item.id != null ? _progressMap[item.id!] ?? item.progress : item.progress;

          return DownloadItemTile(
            item: item,
            progress: progress,
            onPause: () => _downloadManager.pauseDownload(item.id!),
            onResume: () => _downloadManager.resumeDownload(item.id!),
            onCancel: () => _downloadManager.cancelDownload(item.id!),
            onRetry: () => _downloadManager.retryDownload(item.id!),
          )
              .animate(delay: (50 * index).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
        },
        childCount: filteredItems.length,
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(ThemeData theme) {
    String message;
    IconData icon;

    switch (_filterStatus) {
      case DownloadStatus.downloading:
        message = '暂无下载任务';
        icon = Icons.download_rounded;
        break;
      case DownloadStatus.completed:
        message = '还没有完成的下载';
        icon = Icons.check_circle_outline;
        break;
      case DownloadStatus.failed:
        message = '没有失败的下载';
        icon = Icons.error_outline;
        break;
      default:
        message = '还没有下载任务\n去在线搜索添加下载吧';
        icon = Icons.cloud_download;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(delay: 200.ms);
  }
}
