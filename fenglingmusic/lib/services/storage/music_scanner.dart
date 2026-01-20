import 'dart:io';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as path_lib;
import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository_impl.dart';

/// Callback for scan progress updates
typedef ScanProgressCallback = void Function(
  int scanned,
  int total,
  String currentPath,
);

/// Music file scanner service
/// Handles recursive scanning of directories for audio files
class MusicScanner {
  final SongRepositoryImpl _songRepository;

  /// Supported audio file extensions
  static const List<String> supportedExtensions = [
    '.mp3',
    '.m4a',
    '.aac',
    '.flac',
    '.wav',
    '.ogg',
    '.opus',
    '.wma',
  ];

  MusicScanner({SongRepositoryImpl? songRepository})
      : _songRepository = songRepository ?? SongRepositoryImpl();

  /// Scan a directory for music files
  ///
  /// [directoryPath] - The path to scan
  /// [recursive] - Whether to scan subdirectories (default: true)
  /// [onProgress] - Callback for progress updates
  ///
  /// Returns the number of new songs added
  Future<int> scanDirectory(
    String directoryPath, {
    bool recursive = true,
    ScanProgressCallback? onProgress,
  }) async {
    try {
      final directory = Directory(directoryPath);

      if (!await directory.exists()) {
        throw Exception('Directory does not exist: $directoryPath');
      }

      // Get all audio files
      final files = await _findAudioFiles(directory, recursive);

      if (files.isEmpty) {
        return 0;
      }

      int scanned = 0;
      int added = 0;
      final List<SongModel> newSongs = [];

      for (final file in files) {
        try {
          onProgress?.call(scanned, files.length, file.path);

          // Check if file already exists in database
          final exists = await _songRepository.filePathExists(file.path);
          if (!exists) {
            final song = await _extractMetadata(file);
            if (song != null) {
              newSongs.add(song);
            }
          }

          scanned++;
        } catch (e) {
          // Log error but continue scanning
          print('Error processing ${file.path}: $e');
        }
      }

      // Batch insert new songs
      if (newSongs.isNotEmpty) {
        await _songRepository.insertSongs(newSongs);
        added = newSongs.length;
      }

      onProgress?.call(files.length, files.length, 'Scan complete');

      return added;
    } catch (e) {
      print('Error scanning directory: $e');
      rethrow;
    }
  }

  /// Scan multiple directories
  ///
  /// [directoryPaths] - List of paths to scan
  /// [recursive] - Whether to scan subdirectories (default: true)
  /// [onProgress] - Callback for progress updates
  ///
  /// Returns the total number of new songs added
  Future<int> scanDirectories(
    List<String> directoryPaths, {
    bool recursive = true,
    ScanProgressCallback? onProgress,
  }) async {
    int totalAdded = 0;

    for (final dirPath in directoryPaths) {
      try {
        final added = await scanDirectory(
          dirPath,
          recursive: recursive,
          onProgress: onProgress,
        );
        totalAdded += added;
      } catch (e) {
        print('Error scanning $dirPath: $e');
      }
    }

    return totalAdded;
  }

  /// Find all audio files in a directory
  Future<List<File>> _findAudioFiles(
    Directory directory,
    bool recursive,
  ) async {
    final List<File> audioFiles = [];

    try {
      await for (final entity in directory.list(
        recursive: recursive,
        followLinks: false,
      )) {
        if (entity is File) {
          final extension = path_lib.extension(entity.path).toLowerCase();
          if (supportedExtensions.contains(extension)) {
            audioFiles.add(entity);
          }
        }
      }
    } catch (e) {
      print('Error listing directory: $e');
    }

    return audioFiles;
  }

  /// Extract metadata from an audio file
  Future<SongModel?> _extractMetadata(File file) async {
    try {
      final metadata = await MetadataGod.readMetadata(file: file.path);
      final fileStat = await file.stat();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Extract basic metadata
      String title = metadata.title ?? path_lib.basenameWithoutExtension(file.path);
      String? artist = metadata.artist;
      String? album = metadata.album;
      String? albumArtist = metadata.albumArtist;
      int duration = metadata.duration?.inSeconds ?? 0;
      int? trackNumber = metadata.trackNumber;
      int? discNumber = metadata.discNumber;
      int? year = metadata.year;
      String? genre = metadata.genre;

      // Get file info
      final fileSize = fileStat.size;
      final mimeType = _getMimeType(path_lib.extension(file.path));

      // Try to extract cover art and save it
      String? coverPath;
      if (metadata.picture != null && metadata.picture!.data.isNotEmpty) {
        coverPath = await _saveCoverArt(file.path, metadata.picture!.data);
      }

      // Create song model
      return SongModel(
        title: title.isNotEmpty ? title : 'Unknown Title',
        artist: artist,
        album: album,
        albumArtist: albumArtist,
        duration: duration,
        filePath: file.path,
        fileSize: fileSize,
        mimeType: mimeType,
        trackNumber: trackNumber,
        discNumber: discNumber,
        year: year,
        genre: genre,
        coverPath: coverPath,
        dateAdded: now,
        dateModified: fileStat.modified.millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error extracting metadata from ${file.path}: $e');
      return null;
    }
  }

  /// Save cover art to a file
  Future<String?> _saveCoverArt(String audioFilePath, List<int> coverData) async {
    try {
      // Create a cover art filename based on the audio file path
      final audioFileName = path_lib.basenameWithoutExtension(audioFilePath);
      final audioDir = path_lib.dirname(audioFilePath);
      final coverPath = path_lib.join(audioDir, '.$audioFileName.cover.jpg');

      final coverFile = File(coverPath);

      // Only save if it doesn't already exist
      if (!await coverFile.exists()) {
        await coverFile.writeAsBytes(coverData);
      }

      return coverPath;
    } catch (e) {
      print('Error saving cover art: $e');
      return null;
    }
  }

  /// Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.mp3':
        return 'audio/mpeg';
      case '.m4a':
      case '.aac':
        return 'audio/mp4';
      case '.flac':
        return 'audio/flac';
      case '.wav':
        return 'audio/wav';
      case '.ogg':
        return 'audio/ogg';
      case '.opus':
        return 'audio/opus';
      case '.wma':
        return 'audio/x-ms-wma';
      default:
        return 'audio/unknown';
    }
  }

  /// Check if a file is a supported audio file
  static bool isSupportedFile(String filePath) {
    final extension = path_lib.extension(filePath).toLowerCase();
    return supportedExtensions.contains(extension);
  }

  /// Get file count in a directory (without full scan)
  static Future<int> estimateFileCount(
    String directoryPath, {
    bool recursive = true,
  }) async {
    try {
      final directory = Directory(directoryPath);

      if (!await directory.exists()) {
        return 0;
      }

      int count = 0;

      await for (final entity in directory.list(
        recursive: recursive,
        followLinks: false,
      )) {
        if (entity is File) {
          final extension = path_lib.extension(entity.path).toLowerCase();
          if (supportedExtensions.contains(extension)) {
            count++;
          }
        }
      }

      return count;
    } catch (e) {
      print('Error estimating file count: $e');
      return 0;
    }
  }

  /// Rescan a single file (useful for updating metadata)
  Future<bool> rescanFile(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return false;
      }

      if (!isSupportedFile(filePath)) {
        return false;
      }

      final song = await _extractMetadata(file);
      if (song == null) {
        return false;
      }

      // Check if song exists
      final existingSong = await _songRepository.getSongByFilePath(filePath);

      if (existingSong != null) {
        // Update existing song
        final updatedSong = song.copyWith(id: existingSong.id);
        await _songRepository.updateSong(updatedSong);
      } else {
        // Insert new song
        await _songRepository.insertSong(song);
      }

      return true;
    } catch (e) {
      print('Error rescanning file $filePath: $e');
      return false;
    }
  }

  /// Remove songs from database that no longer exist on disk
  Future<int> cleanupMissingSongs() async {
    try {
      final allSongs = await _songRepository.getAllSongs();
      final List<int> missingIds = [];

      for (final song in allSongs) {
        final file = File(song.filePath);
        if (!await file.exists()) {
          if (song.id != null) {
            missingIds.add(song.id!);
          }
        }
      }

      if (missingIds.isNotEmpty) {
        await _songRepository.deleteSongs(missingIds);
      }

      return missingIds.length;
    } catch (e) {
      print('Error cleaning up missing songs: $e');
      return 0;
    }
  }
}
