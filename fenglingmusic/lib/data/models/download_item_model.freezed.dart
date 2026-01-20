// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DownloadItemModel _$DownloadItemModelFromJson(Map<String, dynamic> json) {
  return _DownloadItemModel.fromJson(json);
}

/// @nodoc
mixin _$DownloadItemModel {
  int? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get artist => throw _privateConstructorUsedError;
  String? get album => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_url')
  String get sourceUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_path')
  String get targetPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_size')
  int? get fileSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'downloaded_size')
  int get downloadedSize => throw _privateConstructorUsedError;
  DownloadStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'error_message')
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get quality => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_added')
  int get dateAdded => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_started')
  int? get dateStarted => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_completed')
  int? get dateCompleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DownloadItemModelCopyWith<DownloadItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadItemModelCopyWith<$Res> {
  factory $DownloadItemModelCopyWith(
          DownloadItemModel value, $Res Function(DownloadItemModel) then) =
      _$DownloadItemModelCopyWithImpl<$Res, DownloadItemModel>;
  @useResult
  $Res call(
      {int? id,
      String title,
      String? artist,
      String? album,
      @JsonKey(name: 'source_url') String sourceUrl,
      @JsonKey(name: 'target_path') String targetPath,
      @JsonKey(name: 'file_size') int? fileSize,
      @JsonKey(name: 'downloaded_size') int downloadedSize,
      DownloadStatus status,
      @JsonKey(name: 'error_message') String? errorMessage,
      String? quality,
      @JsonKey(name: 'date_added') int dateAdded,
      @JsonKey(name: 'date_started') int? dateStarted,
      @JsonKey(name: 'date_completed') int? dateCompleted});
}

/// @nodoc
class _$DownloadItemModelCopyWithImpl<$Res, $Val extends DownloadItemModel>
    implements $DownloadItemModelCopyWith<$Res> {
  _$DownloadItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? artist = freezed,
    Object? album = freezed,
    Object? sourceUrl = null,
    Object? targetPath = null,
    Object? fileSize = freezed,
    Object? downloadedSize = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? quality = freezed,
    Object? dateAdded = null,
    Object? dateStarted = freezed,
    Object? dateCompleted = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: freezed == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String?,
      album: freezed == album
          ? _value.album
          : album // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceUrl: null == sourceUrl
          ? _value.sourceUrl
          : sourceUrl // ignore: cast_nullable_to_non_nullable
              as String,
      targetPath: null == targetPath
          ? _value.targetPath
          : targetPath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      downloadedSize: null == downloadedSize
          ? _value.downloadedSize
          : downloadedSize // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      quality: freezed == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as String?,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as int,
      dateStarted: freezed == dateStarted
          ? _value.dateStarted
          : dateStarted // ignore: cast_nullable_to_non_nullable
              as int?,
      dateCompleted: freezed == dateCompleted
          ? _value.dateCompleted
          : dateCompleted // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadItemModelImplCopyWith<$Res>
    implements $DownloadItemModelCopyWith<$Res> {
  factory _$$DownloadItemModelImplCopyWith(_$DownloadItemModelImpl value,
          $Res Function(_$DownloadItemModelImpl) then) =
      __$$DownloadItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String title,
      String? artist,
      String? album,
      @JsonKey(name: 'source_url') String sourceUrl,
      @JsonKey(name: 'target_path') String targetPath,
      @JsonKey(name: 'file_size') int? fileSize,
      @JsonKey(name: 'downloaded_size') int downloadedSize,
      DownloadStatus status,
      @JsonKey(name: 'error_message') String? errorMessage,
      String? quality,
      @JsonKey(name: 'date_added') int dateAdded,
      @JsonKey(name: 'date_started') int? dateStarted,
      @JsonKey(name: 'date_completed') int? dateCompleted});
}

/// @nodoc
class __$$DownloadItemModelImplCopyWithImpl<$Res>
    extends _$DownloadItemModelCopyWithImpl<$Res, _$DownloadItemModelImpl>
    implements _$$DownloadItemModelImplCopyWith<$Res> {
  __$$DownloadItemModelImplCopyWithImpl(_$DownloadItemModelImpl _value,
      $Res Function(_$DownloadItemModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? artist = freezed,
    Object? album = freezed,
    Object? sourceUrl = null,
    Object? targetPath = null,
    Object? fileSize = freezed,
    Object? downloadedSize = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? quality = freezed,
    Object? dateAdded = null,
    Object? dateStarted = freezed,
    Object? dateCompleted = freezed,
  }) {
    return _then(_$DownloadItemModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: freezed == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String?,
      album: freezed == album
          ? _value.album
          : album // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceUrl: null == sourceUrl
          ? _value.sourceUrl
          : sourceUrl // ignore: cast_nullable_to_non_nullable
              as String,
      targetPath: null == targetPath
          ? _value.targetPath
          : targetPath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      downloadedSize: null == downloadedSize
          ? _value.downloadedSize
          : downloadedSize // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      quality: freezed == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as String?,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as int,
      dateStarted: freezed == dateStarted
          ? _value.dateStarted
          : dateStarted // ignore: cast_nullable_to_non_nullable
              as int?,
      dateCompleted: freezed == dateCompleted
          ? _value.dateCompleted
          : dateCompleted // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadItemModelImpl implements _DownloadItemModel {
  const _$DownloadItemModelImpl(
      {this.id,
      required this.title,
      this.artist,
      this.album,
      @JsonKey(name: 'source_url') required this.sourceUrl,
      @JsonKey(name: 'target_path') required this.targetPath,
      @JsonKey(name: 'file_size') this.fileSize,
      @JsonKey(name: 'downloaded_size') this.downloadedSize = 0,
      this.status = DownloadStatus.pending,
      @JsonKey(name: 'error_message') this.errorMessage,
      this.quality,
      @JsonKey(name: 'date_added') required this.dateAdded,
      @JsonKey(name: 'date_started') this.dateStarted,
      @JsonKey(name: 'date_completed') this.dateCompleted});

  factory _$DownloadItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadItemModelImplFromJson(json);

  @override
  final int? id;
  @override
  final String title;
  @override
  final String? artist;
  @override
  final String? album;
  @override
  @JsonKey(name: 'source_url')
  final String sourceUrl;
  @override
  @JsonKey(name: 'target_path')
  final String targetPath;
  @override
  @JsonKey(name: 'file_size')
  final int? fileSize;
  @override
  @JsonKey(name: 'downloaded_size')
  final int downloadedSize;
  @override
  @JsonKey()
  final DownloadStatus status;
  @override
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  @override
  final String? quality;
  @override
  @JsonKey(name: 'date_added')
  final int dateAdded;
  @override
  @JsonKey(name: 'date_started')
  final int? dateStarted;
  @override
  @JsonKey(name: 'date_completed')
  final int? dateCompleted;

  @override
  String toString() {
    return 'DownloadItemModel(id: $id, title: $title, artist: $artist, album: $album, sourceUrl: $sourceUrl, targetPath: $targetPath, fileSize: $fileSize, downloadedSize: $downloadedSize, status: $status, errorMessage: $errorMessage, quality: $quality, dateAdded: $dateAdded, dateStarted: $dateStarted, dateCompleted: $dateCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.album, album) || other.album == album) &&
            (identical(other.sourceUrl, sourceUrl) ||
                other.sourceUrl == sourceUrl) &&
            (identical(other.targetPath, targetPath) ||
                other.targetPath == targetPath) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.downloadedSize, downloadedSize) ||
                other.downloadedSize == downloadedSize) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded) &&
            (identical(other.dateStarted, dateStarted) ||
                other.dateStarted == dateStarted) &&
            (identical(other.dateCompleted, dateCompleted) ||
                other.dateCompleted == dateCompleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      artist,
      album,
      sourceUrl,
      targetPath,
      fileSize,
      downloadedSize,
      status,
      errorMessage,
      quality,
      dateAdded,
      dateStarted,
      dateCompleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadItemModelImplCopyWith<_$DownloadItemModelImpl> get copyWith =>
      __$$DownloadItemModelImplCopyWithImpl<_$DownloadItemModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadItemModelImplToJson(
      this,
    );
  }
}

abstract class _DownloadItemModel implements DownloadItemModel {
  const factory _DownloadItemModel(
          {final int? id,
          required final String title,
          final String? artist,
          final String? album,
          @JsonKey(name: 'source_url') required final String sourceUrl,
          @JsonKey(name: 'target_path') required final String targetPath,
          @JsonKey(name: 'file_size') final int? fileSize,
          @JsonKey(name: 'downloaded_size') final int downloadedSize,
          final DownloadStatus status,
          @JsonKey(name: 'error_message') final String? errorMessage,
          final String? quality,
          @JsonKey(name: 'date_added') required final int dateAdded,
          @JsonKey(name: 'date_started') final int? dateStarted,
          @JsonKey(name: 'date_completed') final int? dateCompleted}) =
      _$DownloadItemModelImpl;

  factory _DownloadItemModel.fromJson(Map<String, dynamic> json) =
      _$DownloadItemModelImpl.fromJson;

  @override
  int? get id;
  @override
  String get title;
  @override
  String? get artist;
  @override
  String? get album;
  @override
  @JsonKey(name: 'source_url')
  String get sourceUrl;
  @override
  @JsonKey(name: 'target_path')
  String get targetPath;
  @override
  @JsonKey(name: 'file_size')
  int? get fileSize;
  @override
  @JsonKey(name: 'downloaded_size')
  int get downloadedSize;
  @override
  DownloadStatus get status;
  @override
  @JsonKey(name: 'error_message')
  String? get errorMessage;
  @override
  String? get quality;
  @override
  @JsonKey(name: 'date_added')
  int get dateAdded;
  @override
  @JsonKey(name: 'date_started')
  int? get dateStarted;
  @override
  @JsonKey(name: 'date_completed')
  int? get dateCompleted;
  @override
  @JsonKey(ignore: true)
  _$$DownloadItemModelImplCopyWith<_$DownloadItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
