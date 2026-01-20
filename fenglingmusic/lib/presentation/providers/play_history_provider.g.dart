// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$songPlayCountHash() => r'b705ae4e9482075d30ebdd2f8053fff737792be7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for getting play count of a specific song
///
/// Copied from [songPlayCount].
@ProviderFor(songPlayCount)
const songPlayCountProvider = SongPlayCountFamily();

/// Provider for getting play count of a specific song
///
/// Copied from [songPlayCount].
class SongPlayCountFamily extends Family<AsyncValue<int>> {
  /// Provider for getting play count of a specific song
  ///
  /// Copied from [songPlayCount].
  const SongPlayCountFamily();

  /// Provider for getting play count of a specific song
  ///
  /// Copied from [songPlayCount].
  SongPlayCountProvider call(
    int songId,
  ) {
    return SongPlayCountProvider(
      songId,
    );
  }

  @override
  SongPlayCountProvider getProviderOverride(
    covariant SongPlayCountProvider provider,
  ) {
    return call(
      provider.songId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'songPlayCountProvider';
}

/// Provider for getting play count of a specific song
///
/// Copied from [songPlayCount].
class SongPlayCountProvider extends AutoDisposeFutureProvider<int> {
  /// Provider for getting play count of a specific song
  ///
  /// Copied from [songPlayCount].
  SongPlayCountProvider(
    int songId,
  ) : this._internal(
          (ref) => songPlayCount(
            ref as SongPlayCountRef,
            songId,
          ),
          from: songPlayCountProvider,
          name: r'songPlayCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$songPlayCountHash,
          dependencies: SongPlayCountFamily._dependencies,
          allTransitiveDependencies:
              SongPlayCountFamily._allTransitiveDependencies,
          songId: songId,
        );

  SongPlayCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.songId,
  }) : super.internal();

  final int songId;

  @override
  Override overrideWith(
    FutureOr<int> Function(SongPlayCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SongPlayCountProvider._internal(
        (ref) => create(ref as SongPlayCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        songId: songId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _SongPlayCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SongPlayCountProvider && other.songId == songId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, songId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SongPlayCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `songId` of this provider.
  int get songId;
}

class _SongPlayCountProviderElement
    extends AutoDisposeFutureProviderElement<int> with SongPlayCountRef {
  _SongPlayCountProviderElement(super.provider);

  @override
  int get songId => (origin as SongPlayCountProvider).songId;
}

String _$songTotalPlayTimeHash() => r'e1040ff7b7f5779c8f704ce530eac8e9659dcb4c';

/// Provider for getting total play time of a specific song
///
/// Copied from [songTotalPlayTime].
@ProviderFor(songTotalPlayTime)
const songTotalPlayTimeProvider = SongTotalPlayTimeFamily();

/// Provider for getting total play time of a specific song
///
/// Copied from [songTotalPlayTime].
class SongTotalPlayTimeFamily extends Family<AsyncValue<int>> {
  /// Provider for getting total play time of a specific song
  ///
  /// Copied from [songTotalPlayTime].
  const SongTotalPlayTimeFamily();

  /// Provider for getting total play time of a specific song
  ///
  /// Copied from [songTotalPlayTime].
  SongTotalPlayTimeProvider call(
    int songId,
  ) {
    return SongTotalPlayTimeProvider(
      songId,
    );
  }

  @override
  SongTotalPlayTimeProvider getProviderOverride(
    covariant SongTotalPlayTimeProvider provider,
  ) {
    return call(
      provider.songId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'songTotalPlayTimeProvider';
}

/// Provider for getting total play time of a specific song
///
/// Copied from [songTotalPlayTime].
class SongTotalPlayTimeProvider extends AutoDisposeFutureProvider<int> {
  /// Provider for getting total play time of a specific song
  ///
  /// Copied from [songTotalPlayTime].
  SongTotalPlayTimeProvider(
    int songId,
  ) : this._internal(
          (ref) => songTotalPlayTime(
            ref as SongTotalPlayTimeRef,
            songId,
          ),
          from: songTotalPlayTimeProvider,
          name: r'songTotalPlayTimeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$songTotalPlayTimeHash,
          dependencies: SongTotalPlayTimeFamily._dependencies,
          allTransitiveDependencies:
              SongTotalPlayTimeFamily._allTransitiveDependencies,
          songId: songId,
        );

  SongTotalPlayTimeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.songId,
  }) : super.internal();

  final int songId;

  @override
  Override overrideWith(
    FutureOr<int> Function(SongTotalPlayTimeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SongTotalPlayTimeProvider._internal(
        (ref) => create(ref as SongTotalPlayTimeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        songId: songId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _SongTotalPlayTimeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SongTotalPlayTimeProvider && other.songId == songId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, songId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SongTotalPlayTimeRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `songId` of this provider.
  int get songId;
}

class _SongTotalPlayTimeProviderElement
    extends AutoDisposeFutureProviderElement<int> with SongTotalPlayTimeRef {
  _SongTotalPlayTimeProviderElement(super.provider);

  @override
  int get songId => (origin as SongTotalPlayTimeProvider).songId;
}

String _$recentlyPlayedHash() => r'7ca214367ad38061a801528ea9a4a45df33ca7fc';

/// Provider for recently played songs
///
/// Copied from [RecentlyPlayed].
@ProviderFor(RecentlyPlayed)
final recentlyPlayedProvider =
    AutoDisposeAsyncNotifierProvider<RecentlyPlayed, List<SongModel>>.internal(
  RecentlyPlayed.new,
  name: r'recentlyPlayedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentlyPlayedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecentlyPlayed = AutoDisposeAsyncNotifier<List<SongModel>>;
String _$mostPlayedHash() => r'64d737f84a3539eee5e7badcbd2a3865e6f5f2ce';

/// Provider for most played songs with play counts
///
/// Copied from [MostPlayed].
@ProviderFor(MostPlayed)
final mostPlayedProvider = AutoDisposeAsyncNotifierProvider<MostPlayed,
    List<Map<String, dynamic>>>.internal(
  MostPlayed.new,
  name: r'mostPlayedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mostPlayedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MostPlayed = AutoDisposeAsyncNotifier<List<Map<String, dynamic>>>;
String _$playRecorderHash() => r'2e92cf5b906886f059a4cc6ec86173ffdfc151b3';

/// Provider for recording play events
///
/// Copied from [PlayRecorder].
@ProviderFor(PlayRecorder)
final playRecorderProvider =
    AutoDisposeNotifierProvider<PlayRecorder, void>.internal(
  PlayRecorder.new,
  name: r'playRecorderProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$playRecorderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PlayRecorder = AutoDisposeNotifier<void>;
String _$playStatisticsHash() => r'941ce3e7a0fe9091b6a54932459e96c4dd55afe6';

/// Provider for play statistics
///
/// Copied from [PlayStatistics].
@ProviderFor(PlayStatistics)
final playStatisticsProvider = AutoDisposeAsyncNotifierProvider<PlayStatistics,
    Map<String, dynamic>>.internal(
  PlayStatistics.new,
  name: r'playStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PlayStatistics = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$historyManagerHash() => r'1b4fd5656ef31e85f329f8c654cc2387b6ac4c8f';

/// Provider for clearing history
///
/// Copied from [HistoryManager].
@ProviderFor(HistoryManager)
final historyManagerProvider =
    AutoDisposeNotifierProvider<HistoryManager, void>.internal(
  HistoryManager.new,
  name: r'historyManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historyManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HistoryManager = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
