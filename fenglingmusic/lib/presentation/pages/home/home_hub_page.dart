import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../albums/albums_page.dart';
import '../artists/artists_page.dart';
import '../download/download_page.dart';
import '../favorites/favorites_page.dart';
import '../folders/folder_browser_page.dart';
import '../history/recently_played_page.dart';
import '../online/online_search_page.dart';
import '../playlist/playlist_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';

class HomeHubPage extends StatelessWidget {
  const HomeHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          const _VinylBackdrop(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: _Header(isDark: isDark),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossAxisCountFor(context),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.25,
                    ),
                    delegate: SliverChildListDelegate.fixed([
                      _HubCard(
                        title: 'PLAYLISTS',
                        subtitle: 'Neo‑Vinyl collections',
                        icon: Icons.queue_music_rounded,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFe94560), Color(0xFFff6b9d)],
                        ),
                        onTap: () => _push(context, const PlaylistPage()),
                      ),
                      _HubCard(
                        title: 'LIBRARY',
                        subtitle: 'Albums · Artists · Folders',
                        icon: Icons.library_music_rounded,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [Color(0xFF1A1A2E), Color(0xFF0F3460)]
                              : const [Color(0xFFEADDFF), Color(0xFFD0BCFF)],
                        ),
                        onTap: () => _showLibrarySheet(context),
                      ),
                      _HubCard(
                        title: 'SEARCH',
                        subtitle: 'Local flow‑wave search',
                        icon: Icons.search_rounded,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [Color(0xFF6366F1), Color(0xFF0B1020)]
                              : const [Color(0xFF818CF8), Color(0xFFF0F1F5)],
                        ),
                        onTap: () => _push(context, const SearchPage()),
                      ),
                      _HubCard(
                        title: 'ONLINE',
                        subtitle: 'Multi‑platform search',
                        icon: Icons.public_rounded,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [Color(0xFF00D2D3), Color(0xFF1A1F35)]
                              : const [Color(0xFF06B6D4), Color(0xFFFFFFFF)],
                        ),
                        onTap: () => _push(context, const OnlineSearchPage()),
                      ),
                      _HubCard(
                        title: 'FAVORITES',
                        subtitle: 'Songs you keep',
                        icon: Icons.favorite_rounded,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [Color(0xFFFF4D6D), Color(0xFF0B1020)]
                              : const [Color(0xFFFF8FAB), Color(0xFFFFF1F5)],
                        ),
                        onTap: () => _push(context, const FavoritesPage()),
                      ),
                      _HubCard(
                        title: 'HISTORY',
                        subtitle: 'Recently played',
                        icon: Icons.history_rounded,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [Color(0xFFFFC857), Color(0xFF1A1A2E)]
                              : const [Color(0xFFFFE08A), Color(0xFFFFFFFF)],
                        ),
                        onTap: () => _push(context, const RecentlyPlayedPage()),
                      ),
                      _HubCard(
                        title: 'DOWNLOADS',
                        subtitle: 'Queue & progress',
                        icon: Icons.download_rounded,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [Color(0xFF22C55E), Color(0xFF0B1020)]
                              : const [Color(0xFF86EFAC), Color(0xFFF0FDF4)],
                        ),
                        onTap: () => _push(context, const DownloadPage()),
                      ),
                      _HubCard(
                        title: 'SETTINGS',
                        subtitle: 'Theme · playback · hotkeys',
                        icon: Icons.tune_rounded,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [Color(0xFF94A3B8), Color(0xFF0B1020)]
                              : const [Color(0xFFE2E8F0), Color(0xFFFFFFFF)],
                        ),
                        onTap: () => _push(context, const SettingsPage()),
                      ),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int _crossAxisCountFor(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1280) return 4;
    if (w >= 900) return 3;
    return 2;
  }

  static Future<void> _push(BuildContext context, Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  static Future<void> _showLibrarySheet(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF0B1020) : Colors.white)
                      .withOpacity(isDark ? 0.72 : 0.9),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(
                      0.10,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'LIBRARY',
                              style: TextStyle(
                                fontFamily: 'Archivo Black',
                                letterSpacing: 4,
                                fontSize: 18,
                                color: (isDark ? Colors.white : Colors.black)
                                    .withOpacity(0.88),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _LibraryAction(
                          title: 'Albums',
                          subtitle: 'Browse by artwork',
                          icon: Icons.album_rounded,
                          onTap: () async {
                            Navigator.of(ctx).pop();
                            await _push(context, const AlbumsPage());
                          },
                        ),
                        _LibraryAction(
                          title: 'Artists',
                          subtitle: 'People behind the sound',
                          icon: Icons.person_rounded,
                          onTap: () async {
                            Navigator.of(ctx).pop();
                            await _push(context, const ArtistsPage());
                          },
                        ),
                        _LibraryAction(
                          title: 'Folders',
                          subtitle: 'Browse your disk',
                          icon: Icons.folder_rounded,
                          onTap: () async {
                            Navigator.of(ctx).pop();
                            await _push(context, const FolderBrowserPage());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;

  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FENGLING',
                    style: TextStyle(
                      fontFamily: 'Archivo Black',
                      fontSize: wide ? 20 : 16,
                      letterSpacing: 8,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(
                        0.65,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MUSIC',
                    style: TextStyle(
                      fontFamily: 'Archivo Black',
                      fontSize: wide ? 56 : 44,
                      height: 0.95,
                      letterSpacing: 2,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Neo‑Vinyl player hub — jump into playlists, search, and your library.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.4,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(
                        0.72,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (wide) ...[
              const SizedBox(width: 16),
              _StatusPill(isDark: isDark),
            ],
          ],
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isDark;

  const _StatusPill({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: (isDark ? const Color(0xFF0B1020) : Colors.white).withOpacity(
          isDark ? 0.75 : 0.85,
        ),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFe94560), Color(0xFFff6b9d)],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'READY',
            style: TextStyle(
              fontFamily: 'Archivo Black',
              fontSize: 12,
              letterSpacing: 2,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CustomPaint(
                  painter: _GrooveOverlayPainter(opacity: isDark ? 0.10 : 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(isDark ? 0.14 : 0.22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Archivo Black',
                      fontSize: 18,
                      letterSpacing: 3,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      height: 1.2,
                      color: Colors.white.withOpacity(0.86),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _LibraryAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFe94560), Color(0xFFff6b9d)],
                    ),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.7,
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

class _VinylBackdrop extends StatefulWidget {
  const _VinylBackdrop();

  @override
  State<_VinylBackdrop> createState() => _VinylBackdropState();
}

class _VinylBackdropState extends State<_VinylBackdrop> {
  late final int _seed;

  @override
  void initState() {
    super.initState();
    _seed = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF050814),
                        Color(0xFF0B1020),
                        Color(0xFF1A1A2E),
                      ]
                    : const [
                        Color(0xFFFFFBFE),
                        Color(0xFFF3EEF9),
                        Color(0xFFE9F0FF),
                      ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _VinylGroovesPainter(isDark: isDark, seed: _seed),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.7, -0.6),
                  radius: 1.2,
                  colors: [
                    const Color(0xFFff6b9d).withOpacity(isDark ? 0.16 : 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VinylGroovesPainter extends CustomPainter {
  final bool isDark;
  final int seed;

  _VinylGroovesPainter({required this.isDark, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.20, size.height * 0.18);
    final maxRadius = math.max(size.width, size.height) * 1.1;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final ringCount = 46;
    for (var i = 0; i < ringCount; i++) {
      final t = i / (ringCount - 1);
      final radius = lerpDouble(18, maxRadius, t)!;
      final wobble =
          (math.sin((t * 18) + (seed % 97)) * 0.9) +
          (math.sin((t * 42) + (seed % 131)) * 0.5);

      base
        ..strokeWidth = lerpDouble(1.6, 0.6, t)!
        ..color = (isDark ? Colors.white : Colors.black).withOpacity(
          (isDark ? 0.060 : 0.045) * (1 - (t * 0.3)),
        );

      final path = Path();
      final steps = 64;
      for (var s = 0; s <= steps; s++) {
        final a = (s / steps) * (math.pi * 2);
        final r = radius + (wobble * math.sin(a * 4));
        final p = center + Offset(math.cos(a) * r, math.sin(a) * r);
        if (s == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, base);
    }
  }

  @override
  bool shouldRepaint(covariant _VinylGroovesPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.seed != seed;
  }
}

class _GrooveOverlayPainter extends CustomPainter {
  final double opacity;

  _GrooveOverlayPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(opacity);

    final center = Offset(size.width * 0.85, size.height * 0.18);
    final maxRadius = math.max(size.width, size.height) * 0.9;

    for (var i = 0; i < 14; i++) {
      final t = i / 13;
      final r = lerpDouble(12, maxRadius, t)!;
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrooveOverlayPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
