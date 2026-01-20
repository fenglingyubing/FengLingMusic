import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/artist_model.dart';
import '../../data/repositories/song_repository_impl.dart';

/// Provider for artists list
final artistsProvider = FutureProvider<List<ArtistModel>>((ref) async {
  // TODO: Implement actual repository call
  // For now, return empty list
  // final repository = ref.watch(songRepositoryProvider);
  // return await repository.getAllArtists();

  return [];
});

/// Provider for a specific artist
final artistProvider = FutureProvider.family<ArtistModel?, int>((ref, artistId) async {
  // TODO: Implement actual repository call
  // final repository = ref.watch(songRepositoryProvider);
  // return await repository.getArtistById(artistId);

  return null;
});

/// Provider for artist's songs
final artistSongsProvider = FutureProvider.family<List<dynamic>, int>((ref, artistId) async {
  // TODO: Implement actual repository call
  // final repository = ref.watch(songRepositoryProvider);
  // return await repository.getSongsByArtist(artistId);

  return [];
});

/// Provider for artist's albums
final artistAlbumsProvider = FutureProvider.family<List<dynamic>, int>((ref, artistId) async {
  // TODO: Implement actual repository call
  // final repository = ref.watch(songRepositoryProvider);
  // return await repository.getAlbumsByArtist(artistId);

  return [];
});
