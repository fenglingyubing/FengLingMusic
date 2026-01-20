import 'package:flutter/material.dart';
import '../animations/list_animations.dart';
import '../animations/player_animations.dart';
import '../animations/micro_interactions.dart';
import '../../core/animation/refresh_rate_detector.dart';

/// Demo page showcasing all advanced animations
/// Use this page to test and verify 120fps performance
class AnimationDemoPage extends StatefulWidget {
  const AnimationDemoPage({super.key});

  @override
  State<AnimationDemoPage> createState() => _AnimationDemoPageState();
}

class _AnimationDemoPageState extends State<AnimationDemoPage> {
  bool _isPlaying = false;
  bool _isFavorite = false;
  int _currentSongIndex = 0;
  final List<String> _songs = ['Song 1', 'Song 2', 'Song 3'];

  @override
  void initState() {
    super.initState();
    // Start FPS monitoring for performance testing
    RefreshRateDetector.instance.startMonitoring();
  }

  @override
  void dispose() {
    RefreshRateDetector.instance.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Demo - 120fps'),
        actions: [
          // FPS Display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: StreamBuilder<double>(
                stream: RefreshRateDetector.instance.refreshRateStream,
                builder: (context, snapshot) {
                  final fps = RefreshRateDetector.instance.currentFps;
                  final refreshRate = RefreshRateDetector.instance.refreshRate;
                  return Text(
                    'FPS: ${fps.toStringAsFixed(0)} / $refreshRate Hz',
                    style: TextStyle(
                      fontSize: 12,
                      color: fps >= refreshRate * 0.9
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Player Animations
          _buildSection(
            'Player Animations',
            [
              const Text('Play/Pause Button'),
              const SizedBox(height: 16),
              Center(
                child: PlayerAnimations.playPauseButton(
                  isPlaying: _isPlaying,
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              const Text('Rotating Album Cover'),
              const SizedBox(height: 16),
              Center(
                child: PlayerAnimations.rotatingAlbum(
                  isPlaying: _isPlaying,
                  size: 200,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.album,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Song Transition'),
              const SizedBox(height: 16),
              Center(
                child: PlayerAnimations.songTransition(
                  songId: _currentSongIndex.toString(),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            _songs[_currentSongIndex],
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Artist Name',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentSongIndex =
                          (_currentSongIndex + 1) % _songs.length;
                    });
                  },
                  child: const Text('Next Song'),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Pulsing Equalizer'),
              const SizedBox(height: 16),
              Center(
                child: PulsingEqualizer(
                  isPlaying: _isPlaying,
                  size: 48,
                  barCount: 4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Section 2: Micro-interactions
          _buildSection(
            'Micro-interactions',
            [
              const Text('Enhanced Favorite Button'),
              const SizedBox(height: 16),
              Center(
                child: MicroInteractions.favoriteButton(
                  isFavorite: _isFavorite,
                  onToggle: () => setState(() => _isFavorite = !_isFavorite),
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              const Text('Ripple Button'),
              const SizedBox(height: 16),
              Center(
                child: MicroInteractions.rippleButton(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tap Me!',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Bouncing Button'),
              const SizedBox(height: 16),
              Center(
                child: MicroInteractions.bouncingButton(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.star,
                      color: theme.colorScheme.onSecondaryContainer,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Long Press Button'),
              const SizedBox(height: 16),
              Center(
                child: LongPressButton(
                  onLongPress: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Long press completed!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Hold Me',
                      style: TextStyle(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Section 3: List Animations
          _buildSection(
            'List Animations',
            [
              const Text('Staggered Entry'),
              const SizedBox(height: 16),
              ...List.generate(
                5,
                (index) => ListAnimations.staggeredEntry(
                  index: index,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text('${index + 1}'),
                      ),
                      title: Text('List Item ${index + 1}'),
                      subtitle: const Text('With staggered animation'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Performance Info
          _buildSection(
            'Performance Info',
            [
              StreamBuilder<double>(
                stream: RefreshRateDetector.instance.refreshRateStream,
                builder: (context, snapshot) {
                  final detector = RefreshRateDetector.instance;
                  final avgFps = detector.averageFps;
                  final refreshRate = detector.refreshRate;
                  final isAcceptable = detector.isPerformanceAcceptable();

                  return Card(
                    color: isAcceptable
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Performance Metrics',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isAcceptable
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onErrorContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMetric(
                            'Refresh Rate',
                            '${refreshRate.toStringAsFixed(0)} Hz',
                            theme,
                            isAcceptable,
                          ),
                          _buildMetric(
                            'Average FPS',
                            avgFps.toStringAsFixed(1),
                            theme,
                            isAcceptable,
                          ),
                          _buildMetric(
                            'Target FPS',
                            detector.getTargetFps().toStringAsFixed(0),
                            theme,
                            isAcceptable,
                          ),
                          _buildMetric(
                            'Performance',
                            isAcceptable ? 'Excellent' : 'Degraded',
                            theme,
                            isAcceptable,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    String label,
    String value,
    ThemeData theme,
    bool isGood,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isGood
                  ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7)
                  : theme.colorScheme.onErrorContainer.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isGood
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
