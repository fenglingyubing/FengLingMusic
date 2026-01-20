/// Advanced Animations System for FengLing Music
///
/// This module provides high-performance, 120fps animations with Neo-Vinyl aesthetics
///
/// ## Components
///
/// ### List Animations
/// - Staggered entry animations with fade + slide
/// - Smooth delete animations with slide-out effect
/// - Drag-to-reorder with elevation and scale feedback
/// - Optimized for large lists with RepaintBoundary
///
/// ### Player Animations
/// - Morphing play/pause button with AnimatedIcon
/// - Rotating vinyl album cover (20s rotation cycle)
/// - Song transition animations with crossfade
/// - Animated progress bar with reset detection
/// - Pulsing equalizer visualization
///
/// ### Micro-interactions
/// - Ripple buttons with scale feedback and haptics
/// - Bouncing buttons with elastic curves
/// - Enhanced favorite button with particle effects
/// - Long-press buttons with circular progress
/// - All with haptic feedback support
///
/// ## Usage Examples
///
/// ### List Animations
/// ```dart
/// // Staggered entry
/// ListAnimations.staggeredEntry(
///   index: index,
///   child: YourWidget(),
/// );
///
/// // Drag-to-reorder
/// SmoothReorderableListView(
///   children: items,
///   onReorder: (oldIndex, newIndex) { ... },
/// );
/// ```
///
/// ### Player Animations
/// ```dart
/// // Play/Pause button
/// PlayerAnimations.playPauseButton(
///   isPlaying: isPlaying,
///   onTap: () { ... },
///   size: 64,
/// );
///
/// // Rotating album
/// PlayerAnimations.rotatingAlbum(
///   isPlaying: isPlaying,
///   size: 200,
///   child: Image(...),
/// );
///
/// // Song transition
/// PlayerAnimations.songTransition(
///   songId: currentSongId,
///   child: SongInfoWidget(),
/// );
/// ```
///
/// ### Micro-interactions
/// ```dart
/// // Favorite button with particles
/// MicroInteractions.favoriteButton(
///   isFavorite: isFavorite,
///   onToggle: () { ... },
///   size: 48,
/// );
///
/// // Ripple button
/// MicroInteractions.rippleButton(
///   onTap: () { ... },
///   child: YourButton(),
/// );
///
/// // Bouncing button
/// MicroInteractions.bouncingButton(
///   onTap: () { ... },
///   child: Icon(Icons.star),
/// );
/// ```
///
/// ## Performance
///
/// All animations are optimized for 120fps:
/// - Uses RefreshRateDetector to adapt to device capabilities
/// - Efficient use of RepaintBoundary
/// - Hardware-accelerated transforms
/// - Minimal rebuilds with AnimatedBuilder
/// - Pre-computed animation curves
///
/// ## Testing
///
/// Use AnimationDemoPage to test all animations:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => AnimationDemoPage()),
/// );
/// ```
///
/// The demo page includes:
/// - Real-time FPS monitoring
/// - All animation examples
/// - Performance metrics
/// - Visual feedback for testing

library animations;

export 'list_animations.dart';
export 'player_animations.dart';
export 'micro_interactions.dart';
export 'page_transitions.dart';
