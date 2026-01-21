import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lyric_line_model.dart';
import '../providers/lyrics_provider.dart';

/// Desktop Lyrics Window
///
/// 桌面歌词悬浮窗（仅Windows平台）
/// 特点：
/// - 始终置顶显示
/// - 透明背景
/// - 可拖动位置
/// - 锁定/解锁模式
/// - 优雅的文字渐变效果
///
/// 注意：需要配合 window_manager 或类似插件使用
class DesktopLyricsWindow extends ConsumerStatefulWidget {
  const DesktopLyricsWindow({super.key});

  @override
  ConsumerState<DesktopLyricsWindow> createState() =>
      _DesktopLyricsWindowState();
}

class _DesktopLyricsWindowState extends ConsumerState<DesktopLyricsWindow> {
  // Window settings
  bool _isLocked = false;
  double _opacity = 1.0;
  double _fontSize = 32.0;
  Color _textColor = Colors.white;
  bool _showShadow = true;

  // Drag state
  Offset _position = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeWindow();
  }

  Future<void> _initializeWindow() async {
    // TODO: Use window_manager to set window properties
    // await windowManager.setAlwaysOnTop(true);
    // await windowManager.setSkipTaskbar(true);
    // await windowManager.setBackgroundColor(Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    // Only available on Windows
    if (!Platform.isWindows) {
      return const Scaffold(
        body: Center(
          child: Text('桌面歌词仅支持 Windows'),
        ),
      );
    }

    // TODO: Uncomment when lyricsControllerProvider is configured
    // final lyricsState = ref.watch(lyricsControllerProvider);
    // const LyricLineModel? currentLine = null;  // Placeholder
    const LyricLineModel? currentLine = null;  // Placeholder

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onPanStart: !_isLocked ? _onPanStart : null,
        onPanUpdate: !_isLocked ? _onPanUpdate : null,
        onPanEnd: !_isLocked ? _onPanEnd : null,
        onDoubleTap: _onDoubleTap,
        child: Stack(
          children: [
            // Main lyrics display
            Center(
              child: _buildLyricsDisplay(currentLine),
            ),

            // Control panel (show on hover when unlocked)
            if (!_isLocked)
              Positioned(
                top: 16,
                right: 16,
                child: _buildControlPanel(),
              ),

            // Lock indicator
            if (_isLocked)
              Positioned(
                bottom: 16,
                left: 16,
                child: _buildLockIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLyricsDisplay(LyricLineModel? line) {
    final String text = line?.text ?? '♪';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _opacity,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.bold,
          color: _textColor,
          letterSpacing: 2.0,
          shadows: _showShadow
              ? [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.8),
                  ),
                  Shadow(
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ]
              : null,
        ),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                _textColor,
                _textColor.withOpacity(0.8),
                _textColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lock button
                _buildControlButton(
                  icon: Icons.lock_outline,
                  tooltip: '锁定位置',
                  onPressed: () => setState(() => _isLocked = true),
                ),

                const SizedBox(height: 8),

                // Font size
                _buildControlButton(
                  icon: Icons.text_fields,
                  tooltip: '调整字号',
                  onPressed: _showFontSizeDialog,
                ),

                const SizedBox(height: 8),

                // Color picker
                _buildControlButton(
                  icon: Icons.palette,
                  tooltip: '更改颜色',
                  onPressed: _showColorPicker,
                ),

                const SizedBox(height: 8),

                // Opacity
                _buildControlButton(
                  icon: Icons.opacity,
                  tooltip: '调整透明度',
                  onPressed: _showOpacityDialog,
                ),

                const SizedBox(height: 8),

                // Close
                _buildControlButton(
                  icon: Icons.close,
                  tooltip: '关闭桌面歌词',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  Widget _buildLockIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              const Text(
                '已锁定',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _isLocked = false),
                child: const Icon(Icons.lock_open, color: Colors.white70, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Drag handlers
  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });

    // TODO: Update window position using window_manager
    // windowManager.setPosition(_position);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
  }

  void _onDoubleTap() {
    // Double-tap to toggle lock
    setState(() => _isLocked = !_isLocked);
  }

  // Settings dialogs
  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => _SettingsDialog(
        title: '字号',
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _fontSize,
                min: 20,
                max: 72,
                divisions: 26,
                label: _fontSize.round().toString(),
                onChanged: (value) {
                  setState(() => _fontSize = value);
                  this.setState(() => _fontSize = value);
                },
              ),
              Text('${_fontSize.round()} 像素'),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    final colors = [
      Colors.white,
      Colors.amber,
      Colors.blue,
      Colors.green,
      Colors.pink,
      Colors.purple,
    ];

    showDialog(
      context: context,
      builder: (context) => _SettingsDialog(
        title: '文字颜色',
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() => _textColor = color);
                Navigator.pop(context);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _textColor == color
                        ? Colors.white
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showOpacityDialog() {
    showDialog(
      context: context,
      builder: (context) => _SettingsDialog(
        title: '透明度',
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _opacity,
                min: 0.3,
                max: 1.0,
                divisions: 14,
                label: (_opacity * 100).round().toString(),
                onChanged: (value) {
                  setState(() => _opacity = value);
                  this.setState(() => _opacity = value);
                },
              ),
              Text('${(_opacity * 100).round()}%'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings dialog helper widget
class _SettingsDialog extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsDialog({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                child,
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('关闭'),
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
