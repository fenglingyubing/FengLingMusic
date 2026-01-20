import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/song_model.dart';

/// Folder information model
class FolderInfo {
  final String name;
  final String path;
  final int songCount;

  FolderInfo({
    required this.name,
    required this.path,
    required this.songCount,
  });
}

/// Folder contents model
class FolderContents {
  final List<FolderInfo> folders;
  final List<SongModel> songs;

  FolderContents({
    required this.folders,
    required this.songs,
  });
}

/// Provider for folder contents
final folderContentsProvider =
    FutureProvider.family<FolderContents, String>((ref, path) async {
  // TODO: Implement actual repository call
  // final repository = ref.watch(songRepositoryProvider);
  // return await repository.getFolderContents(path);

  return FolderContents(
    folders: [],
    songs: [],
  );
});

/// Provider for folder tree (all folders)
final folderTreeProvider = FutureProvider<List<FolderInfo>>((ref) async {
  // TODO: Implement actual repository call
  // final repository = ref.watch(songRepositoryProvider);
  // return await repository.getAllFolders();

  return [];
});
