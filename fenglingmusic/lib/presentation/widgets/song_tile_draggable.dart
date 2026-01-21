import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/song_model.dart';

/// Draggable song tile for playlist detail page
class SongTileDraggable extends StatefulWidget {
  final SongModel song;
  final int index;
  final bool isEditMode;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const SongTileDraggable({
    Key? key,
    required this.song,
    required this.index,
    this.isEditMode = false,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  State<SongTileDraggable> createState() => _SongTileDraggableState();
}

class _SongTileDraggableState extends State<SongTileDraggable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Staggered animation
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(_animation),
      child: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: _isHovered
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovered
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Drag handle (only in edit mode)
                        if (widget.isEditMode) ...[
                          Icon(
                            Icons.drag_handle,
                            color: Colors.white.withOpacity(0.5),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ] else ...[
                          // Track number
                          Container(
                            width: 32,
                            alignment: Alignment.center,
                            child: Text(
                              '${widget.index + 1}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Album art
                        _buildAlbumArt(),
                        const SizedBox(width: 16),

                        // Song info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.song.title,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.song.artist ?? '未知艺术家',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Duration
                        if (!widget.isEditMode) ...[
                          const SizedBox(width: 16),
                          Text(
                            _formatDuration(widget.song.duration),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],

                        // Delete button (edit mode)
                        if (widget.isEditMode && widget.onDelete != null) ...[
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: widget.onDelete,
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: const Color(0xFFe94560),
                            ),
                            tooltip: '从播放列表移除',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    Widget artWidget;

    if (widget.song.coverPath != null) {
      final file = File(widget.song.coverPath!);
      if (file.existsSync()) {
        artWidget = Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        artWidget = _buildDefaultArt();
      }
    } else {
      artWidget = _buildDefaultArt();
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: artWidget,
      ),
    );
  }

  Widget _buildDefaultArt() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFe94560).withOpacity(0.6),
            const Color(0xFFff6b9d).withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note,
          color: Colors.white.withOpacity(0.8),
          size: 24,
        ),
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
