import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../data/models/song_model.dart';
import '../../providers/playlist_provider.dart';
import '../../../services/playlist/m3u_service.dart';
import '../../widgets/song_tile_draggable.dart';

/// Playlist detail page with drag-to-reorder and M3U export/import
class PlaylistDetailPage extends ConsumerStatefulWidget {
  final int playlistId;

  const PlaylistDetailPage({
    Key? key,
    required this.playlistId,
  }) : super(key: key);

  @override
  ConsumerState<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends ConsumerState<PlaylistDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  final M3UService _m3uService = M3UService();
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistAsync = ref.watch(playlistProvider(widget.playlistId));
    final songsAsync = ref.watch(playlistSongsProvider(widget.playlistId));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
              const Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, playlistAsync),
              Expanded(
                child: songsAsync.when(
                  data: (songs) => _buildSongList(context, songs),
                  loading: () => _buildLoading(),
                  error: (error, stack) => _buildError(error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue playlistAsync) {
    return playlistAsync.when(
      data: (playlist) {
        if (playlist == null) return const SizedBox.shrink();

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _headerAnimationController,
            curve: Curves.easeOutCubic,
          )),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Back button and actions
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Spacer(),
                    _buildActionButton(
                      icon: Icons.upload_file,
                      label: 'EXPORT',
                      onTap: () => _exportPlaylist(playlist),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.download,
                      label: 'IMPORT',
                      onTap: _importM3U,
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: _isEditMode ? Icons.done : Icons.edit,
                      label: _isEditMode ? 'DONE' : 'EDIT',
                      onTap: () => setState(() => _isEditMode = !_isEditMode),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Cover and info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover image
                    _buildCover(playlist),
                    const SizedBox(width: 24),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PLAYLIST',
                            style: TextStyle(
                              fontFamily: 'Archivo Black',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            playlist.name,
                            style: TextStyle(
                              fontFamily: 'Archivo Black',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          if (playlist.description != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              playlist.description!,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStat(
                                Icons.music_note,
                                '${playlist.songCount} songs',
                              ),
                              const SizedBox(width: 20),
                              _buildStat(
                                Icons.access_time,
                                playlist.formattedDuration,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 200),
      error: (error, stack) => const SizedBox(height: 200),
    );
  }

  Widget _buildCover(playlist) {
    Widget coverWidget;

    if (playlist.coverPath != null) {
      final file = File(playlist.coverPath!);
      if (file.existsSync()) {
        coverWidget = Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        coverWidget = _buildDefaultCover();
      }
    } else {
      coverWidget = _buildDefaultCover();
    }

    return Hero(
      tag: 'playlist_${widget.playlistId}',
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: coverWidget,
        ),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFe94560),
            const Color(0xFFff6b9d),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.queue_music_rounded,
          size: 64,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Archivo Black',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSongList(BuildContext context, List<SongModel> songs) {
    if (songs.isEmpty) {
      return _buildEmptyState();
    }

    if (_isEditMode) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        itemCount: songs.length,
        onReorder: (oldIndex, newIndex) => _handleReorder(oldIndex, newIndex),
        itemBuilder: (context, index) {
          final song = songs[index];
          return SongTileDraggable(
            key: ValueKey(song.id),
            song: song,
            index: index,
            isEditMode: true,
            onDelete: () => _removeSong(song.id!),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return SongTileDraggable(
          key: ValueKey(song.id),
          song: song,
          index: index,
          isEditMode: false,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFe94560).withOpacity(0.3),
                  const Color(0xFFff6b9d).withOpacity(0.3),
                ],
              ),
            ),
            child: Icon(
              Icons.music_note_outlined,
              size: 50,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No songs in this playlist',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add songs to get started',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFe94560)),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Text(
        'Error: $error',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    await ref.read(playlistNotifierProvider.notifier).reorderSong(
          widget.playlistId,
          oldIndex,
          newIndex,
        );

    // Refresh the songs list
    ref.invalidate(playlistSongsProvider(widget.playlistId));
  }

  Future<void> _removeSong(int songId) async {
    await ref.read(playlistNotifierProvider.notifier).removeSongFromPlaylist(
          widget.playlistId,
          songId,
        );

    ref.invalidate(playlistSongsProvider(widget.playlistId));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已从播放列表移除歌曲'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _exportPlaylist(playlist) async {
    final songsAsync = ref.read(playlistSongsProvider(widget.playlistId));

    songsAsync.whenData((songs) async {
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) return;

      final filePath = await _m3uService.exportPlaylist(
        playlist: playlist,
        songs: songs,
        outputPath: directory,
        extendedFormat: true,
      );

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('播放列表已导出到：$filePath'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出播放列表失败'),
            backgroundColor: const Color(0xFFe94560),
          ),
        );
      }
    });
  }

  Future<void> _importM3U() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['m3u', 'm3u8'],
    );

    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    final importResult = await _m3uService.importPlaylist(filePath);

    if (importResult == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入 M3U 文件失败'),
            backgroundColor: const Color(0xFFe94560),
          ),
        );
      }
      return;
    }

    // TODO: Match imported file paths with songs in database and add to playlist
    // This would require access to SongRepository to find songs by file path

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('在 M3U 文件中找到 ${importResult.filePaths.length} 首歌曲'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
