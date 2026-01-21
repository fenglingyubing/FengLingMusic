import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lyric_line_model.dart';
import '../providers/lyrics_provider.dart';

/// Lyrics View Widget
///
/// 精致的歌词显示组件，采用 "Editorial Poetry" 设计美学
/// 特点：
/// - 优雅的排版层级
/// - 流畅的120fps滚动动画
/// - 渐变文字高亮效果
/// - 毛玻璃背景融合
class LyricsView extends ConsumerStatefulWidget {
  final Color? accentColor;
  final bool showTranslation;
  final VoidCallback? onTap;

  const LyricsView({
    super.key,
    this.accentColor,
    this.showTranslation = true,
    this.onTap,
  });

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listKey = GlobalKey();

  // Auto-scroll settings
  bool _isUserScrolling = false;
  bool _autoScrollEnabled = true;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation for line transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();

    // Listen to manual scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Detect user manual scroll
    if (_scrollController.position.isScrollingNotifier.value) {
      if (!_isUserScrolling) {
        setState(() {
          _isUserScrolling = true;
          _autoScrollEnabled = false;
        });

        // Re-enable auto-scroll after 3 seconds of inactivity
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _autoScrollEnabled = true;
            });
          }
        });
      }
    }
  }

  /// Auto-scroll to current line
  void _scrollToCurrentLine(int lineIndex, int totalLines) {
    if (!_autoScrollEnabled || _isUserScrolling || !_scrollController.hasClients) {
      return;
    }

    // Calculate scroll position to center the current line
    const double itemHeight = 80.0; // Approximate height per line
    final double targetOffset = (lineIndex * itemHeight) -
        (_scrollController.position.viewportDimension / 2) + (itemHeight / 2);

    final double clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    // Smooth scroll with physics-based animation
    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  /// Handle tap on lyric line - seek to that position
  void _onLineTap(int index) {
    // TODO: Uncomment when lyricsControllerProvider is configured
    // ref.read(lyricsControllerProvider.notifier).seekToLine(index);

    // Enable auto-scroll immediately after seeking
    setState(() {
      _autoScrollEnabled = true;
      _isUserScrolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Uncomment when lyricsControllerProvider is configured
    // final lyricsState = ref.watch(lyricsControllerProvider);
    const lyricsState = LyricsState();  // Placeholder
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Scroll to current line when it changes
    if (lyricsState.hasLyrics && lyricsState.currentLineIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentLine(
          lyricsState.currentLineIndex,
          lyricsState.lyrics.length,
        );
      });
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (widget.accentColor ?? theme.colorScheme.primary)
                .withOpacity(isDark ? 0.03 : 0.02),
            theme.colorScheme.surface.withOpacity(0.95),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: _buildContent(lyricsState, theme, isDark),
    );
  }

  Widget _buildContent(LyricsState state, ThemeData theme, bool isDark) {
    if (state.isLoading) {
      return _buildLoadingState(theme);
    }

    if (state.error != null) {
      return _buildErrorState(state.error!, theme);
    }

    if (!state.hasLyrics) {
      return _buildEmptyState(theme, isDark);
    }

    return _buildLyricsList(state, theme, isDark);
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: widget.accentColor ?? theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading lyrics...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load lyrics',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),
          const SizedBox(height: 32),
          Text(
            '♪',
            style: TextStyle(
              fontSize: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No lyrics available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy the music',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsList(LyricsState state, ThemeData theme, bool isDark) {
    return Stack(
      children: [
        // Main lyrics list
        ListView.builder(
          key: _listKey,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 32),
          itemCount: state.lyrics.length,
          itemBuilder: (context, index) {
            return _buildLyricLine(
              state.lyrics[index],
              index,
              state.currentLineIndex,
              theme,
              isDark,
            );
          },
        ),

        // Auto-scroll indicator (when disabled)
        if (!_autoScrollEnabled && _isUserScrolling)
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildAutoScrollButton(theme),
          ),
      ],
    );
  }

  Widget _buildLyricLine(
    LyricLineModel line,
    int index,
    int currentIndex,
    ThemeData theme,
    bool isDark,
  ) {
    final bool isCurrent = index == currentIndex;
    final bool isPast = index < currentIndex;
    final bool isNear = (index - currentIndex).abs() <= 2;

    // Calculate opacity based on distance from current line
    double opacity = 1.0;
    if (!isCurrent) {
      if (isPast) {
        opacity = isNear ? 0.4 : 0.2;
      } else {
        opacity = isNear ? 0.5 : 0.25;
      }
    }

    // Calculate scale for subtle zoom effect
    final double scale = isCurrent ? 1.0 : (isNear ? 0.96 : 0.92);

    return GestureDetector(
      onTap: () => _onLineTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(scale),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: opacity,
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main lyric text
                _buildMainText(line.text, isCurrent, theme, isDark),

                // Translation (if available and enabled)
                if (widget.showTranslation && line.translation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildTranslationText(
                      line.translation!,
                      isCurrent,
                      theme,
                      isDark,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainText(
    String text,
    bool isCurrent,
    ThemeData theme,
    bool isDark,
  ) {
    final Color textColor = isCurrent
        ? (widget.accentColor ?? theme.colorScheme.primary)
        : theme.colorScheme.onSurface;

    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: isCurrent ? 28 : 24,
        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
        color: textColor,
        height: 1.6,
        letterSpacing: isCurrent ? 0.5 : 0.3,
        // Use a beautiful serif font for lyrics (editorial feel)
        fontFamily: 'Serif', // Falls back to system serif
      ),
    );

    if (!isCurrent) {
      return textWidget;
    }

    // Apply gradient shader only for current line
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        // Gradient effect for current line
        return LinearGradient(
          colors: [
            widget.accentColor ?? theme.colorScheme.primary,
            (widget.accentColor ?? theme.colorScheme.primary)
                .withOpacity(0.7),
            widget.accentColor ?? theme.colorScheme.primary,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: textWidget,
    );
  }

  }

  Widget _buildTranslationText(
    String text,
    bool isCurrent,
    ThemeData theme,
    bool isDark,
  ) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isCurrent ? 16 : 14,
        fontWeight: FontWeight.w300,
        color: theme.colorScheme.onSurface.withOpacity(isCurrent ? 0.7 : 0.5),
        height: 1.5,
        letterSpacing: 0.2,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildAutoScrollButton(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _autoScrollEnabled = true;
          _isUserScrolling = false;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.center_focus_strong,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-scroll',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
