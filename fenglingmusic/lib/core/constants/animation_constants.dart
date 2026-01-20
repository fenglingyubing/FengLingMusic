/// Animation constants for 120fps smooth animations
class AnimationConstants {
  // Private constructor to prevent instantiation
  AnimationConstants._();

  // Target frame rate
  static const int targetFps = 120;

  // Animation durations (in milliseconds)
  static const int shortDuration = 150;
  static const int mediumDuration = 300;
  static const int longDuration = 500;

  // Animation curves
  static const String defaultCurve = 'easeInOut';
  static const String emphasizedCurve = 'emphasizedAccelerate';
  static const String emphasizedDecelerateCurve = 'emphasizedDecelerate';

  // Page transition duration
  static const int pageTransitionDuration = 300;

  // List item animation
  static const int listItemAnimationDelay = 50; // Stagger delay per item
  static const int listItemAnimationDuration = 200;

  // Player animations
  static const int albumCoverRotationDuration = 20000; // 20 seconds for full rotation
  static const int playPauseAnimationDuration = 200;
  static const int progressBarUpdateInterval = 16; // ~60fps minimum

  // Scroll physics
  static const double scrollSpringConstant = 100.0;
  static const double scrollDampingRatio = 1.1;

  // Refresh rate detection
  static const int defaultRefreshRate = 60;
  static const int highRefreshRate = 90;
  static const int maxRefreshRate = 120;

  // Performance thresholds
  static const double minAcceptableFps = 55.0; // For 60Hz displays
  static const double minAcceptableHighRefreshFps = 110.0; // For 120Hz displays
}
