import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io';
import '../../data/models/playlist_model.dart';

/// Animated playlist card with Neo-Vinyl aesthetic
/// Features vinyl record-inspired design with smooth animations
class AnimatedPlaylistCard extends StatefulWidget {
  final PlaylistModel playlist;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AnimatedPlaylistCard({
    Key? key,
    required this.playlist,
    required this.index,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<AnimatedPlaylistCard> createState() => _AnimatedPlaylistCardState();
}

class _AnimatedPlaylistCardState extends State<AnimatedPlaylistCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Staggered entry animation
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.0,
        0.6,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.2,
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );

    // Delayed start based on index for staggered effect
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
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
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(_scaleAnimation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: FadeTransition(
          opacity: _slideAnimation,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedScale(
              scale: _isHovered ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: _buildCard(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.5 : 0.3),
              blurRadius: _isHovered ? 24 : 16,
              offset: Offset(0, _isHovered ? 12 : 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background gradient
              _buildBackground(),

              // Cover image or default vinyl design
              _buildCover(),

              // Vinyl texture overlay
              _buildVinylTexture(),

              // Content
              _buildContent(),

              // Delete button
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
      ),
    );
  }

  Widget _buildCover() {
    if (widget.playlist.coverPath != null) {
      final file = File(widget.playlist.coverPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }
    }

    // Default vinyl record design
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.4),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVinylTexture() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.transparent,
            Colors.black.withOpacity(0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Playlist name
            Text(
              widget.playlist.name,
              style: TextStyle(
                fontFamily: 'Archivo Black',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Stats
            Row(
              children: [
                Icon(
                  Icons.music_note,
                  size: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.playlist.songCount} songs',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.playlist.formattedDuration,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: AnimatedOpacity(
        opacity: _isHovered ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onDelete,
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.6),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 20,
                color: const Color(0xFFe94560),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    // Generate colors based on playlist ID for variety
    final hash = widget.playlist.id?.hashCode ?? widget.playlist.name.hashCode;
    final random = math.Random(hash);

    final gradients = [
      [const Color(0xFFe94560), const Color(0xFFff6b9d)], // Pink
      [const Color(0xFF6a4c93), const Color(0xFF9d84b7)], // Purple
      [const Color(0xFF3a86ff), const Color(0xFF8338ec)], // Blue-Purple
      [const Color(0xFFfb5607), const Color(0xFFffbe0b)], // Orange-Yellow
      [const Color(0xFF06ffa5), const Color(0xFF00d9ff)], // Cyan-Green
      [const Color(0xFFf72585), const Color(0xFF7209b7)], // Magenta-Purple
    ];

    return gradients[random.nextInt(gradients.length)];
  }
}
