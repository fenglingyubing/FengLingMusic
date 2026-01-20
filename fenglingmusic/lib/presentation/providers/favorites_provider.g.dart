// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoritesHash() => r'8564642c1c0236d1dac2218d4f9f7ec2203d53d4';

/// Provider for managing favorite songs
///
/// Copied from [Favorites].
@ProviderFor(Favorites)
final favoritesProvider =
    AutoDisposeAsyncNotifierProvider<Favorites, List<SongModel>>.internal(
  Favorites.new,
  name: r'favoritesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$favoritesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Favorites = AutoDisposeAsyncNotifier<List<SongModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
