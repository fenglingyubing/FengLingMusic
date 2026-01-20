import 'dart:io';
import 'package:path/path.dart' as path;
import '../../data/models/song_model.dart';
import '../../data/models/playlist_model.dart';

/// Service for exporting and importing M3U playlists
class M3UService {
  /// Export playlist to M3U format
  /// Returns the file path if successful
  Future<String?> exportPlaylist({
    required PlaylistModel playlist,
    required List<SongModel> songs,
    required String outputPath,
    bool extendedFormat = true,
  }) async {
    try {
      final fileName = _sanitizeFileName(playlist.name);
      final extension = extendedFormat ? '.m3u8' : '.m3u';
      final filePath = path.join(outputPath, '$fileName$extension');

      final file = File(filePath);
      final buffer = StringBuffer();

      // Write header for extended format
      if (extendedFormat) {
        buffer.writeln('#EXTM3U');
      }

      // Write each song
      for (final song in songs) {
        if (extendedFormat) {
          // Extended info: #EXTINF:duration,artist - title
          final duration = song.duration ~/ 1000; // Convert ms to seconds
          final artist = song.artist ?? 'Unknown Artist';
          final title = song.title;
          buffer.writeln('#EXTINF:$duration,$artist - $title');
        }

        // Write file path
        buffer.writeln(song.filePath);
      }

      await file.writeAsString(buffer.toString());
      return filePath;
    } catch (e) {
      print('Error exporting playlist: $e');
      return null;
    }
  }

  /// Import M3U playlist
  /// Returns a list of file paths found in the M3U file
  Future<M3UImportResult?> importPlaylist(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      final lines = content.split('\n').map((line) => line.trim()).toList();

      final result = M3UImportResult(
        playlistName: path.basenameWithoutExtension(filePath),
        filePaths: [],
        metadata: [],
      );

      bool isExtended = false;
      M3USongMetadata? currentMetadata;

      for (final line in lines) {
        if (line.isEmpty || line.startsWith('#') && !line.startsWith('#EXTINF')) {
          if (line == '#EXTM3U') {
            isExtended = true;
          }
          continue;
        }

        if (line.startsWith('#EXTINF:')) {
          // Parse extended info
          currentMetadata = _parseExtInf(line);
        } else if (!line.startsWith('#')) {
          // This is a file path
          result.filePaths.add(line);
          if (currentMetadata != null) {
            result.metadata.add(currentMetadata);
            currentMetadata = null;
          } else {
            result.metadata.add(M3USongMetadata());
          }
        }
      }

      return result;
    } catch (e) {
      print('Error importing playlist: $e');
      return null;
    }
  }

  /// Parse EXTINF line
  /// Format: #EXTINF:duration,artist - title
  M3USongMetadata _parseExtInf(String line) {
    final metadata = M3USongMetadata();

    try {
      // Remove #EXTINF: prefix
      final content = line.substring(8);

      // Split by comma
      final parts = content.split(',');
      if (parts.length >= 2) {
        // Parse duration
        final duration = int.tryParse(parts[0].trim());
        if (duration != null) {
          metadata.duration = duration * 1000; // Convert to ms
        }

        // Parse artist and title
        final info = parts.sublist(1).join(',').trim();
        final dashIndex = info.indexOf(' - ');
        if (dashIndex != -1) {
          metadata.artist = info.substring(0, dashIndex).trim();
          metadata.title = info.substring(dashIndex + 3).trim();
        } else {
          metadata.title = info;
        }
      }
    } catch (e) {
      print('Error parsing EXTINF: $e');
    }

    return metadata;
  }

  /// Sanitize file name by removing invalid characters
  String _sanitizeFileName(String name) {
    // Remove invalid file name characters
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// Validate M3U file
  Future<bool> isValidM3UFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final extension = path.extension(filePath).toLowerCase();
      if (extension != '.m3u' && extension != '.m3u8') return false;

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Result of M3U import operation
class M3UImportResult {
  final String playlistName;
  final List<String> filePaths;
  final List<M3USongMetadata> metadata;

  M3UImportResult({
    required this.playlistName,
    required this.filePaths,
    required this.metadata,
  });
}

/// Metadata extracted from M3U EXTINF tag
class M3USongMetadata {
  int? duration;
  String? artist;
  String? title;

  M3USongMetadata({
    this.duration,
    this.artist,
    this.title,
  });
}
