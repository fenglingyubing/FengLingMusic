import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/album_model.dart';
import '../../data/models/song_model.dart';

/// Provider for albums list
final albumsProvider = FutureProvider<List<AlbumModel>>((ref) async {
  // TODO: Implement actual repository call
  // final repository = ref.watch(songRepositoryProvider);
  // return await repository.getAllAlbums();

  return [];
});

/// Provider for a specific album
final albumProvider = FutureProvider.family<AlbumModel?, int>((ref, albumId) async {
  // TODO: Implement actual repository call
  // final repository = ref.watch(songRepositoryProvider);
  // return await repository.getAlbumById(albumId);

  return null;
});

/// Provider for album's songs
final albumSongsProvider = FutureProvider.family<List<SongModel>, int>((ref, albumId) async {
  // TODO: Implement actual repository call
  // final repository = ref.watch(songRepositoryProvider);
  // return await repository.getSongsByAlbum(albumId);

  return [];
});
