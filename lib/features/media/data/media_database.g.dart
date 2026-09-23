// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_database.dart';

// ignore_for_file: type=lint
class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
    'modified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scannedAtMeta = const VerificationMeta(
    'scannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
    'scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    path,
    uri,
    mediaType,
    size,
    modifiedAt,
    width,
    height,
    durationMs,
    mimeType,
    displayName,
    scannedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(
        _scannedAtMeta,
        scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {uri},
  ];
  @override
  MediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_at'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      scannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scanned_at'],
      )!,
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final int id;
  final String path;
  final String uri;
  final String mediaType;
  final int size;
  final DateTime? modifiedAt;
  final int? width;
  final int? height;
  final int? durationMs;
  final String? mimeType;
  final String displayName;
  final DateTime scannedAt;
  const MediaItem({
    required this.id,
    required this.path,
    required this.uri,
    required this.mediaType,
    required this.size,
    this.modifiedAt,
    this.width,
    this.height,
    this.durationMs,
    this.mimeType,
    required this.displayName,
    required this.scannedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path'] = Variable<String>(path);
    map['uri'] = Variable<String>(uri);
    map['media_type'] = Variable<String>(mediaType);
    map['size'] = Variable<int>(size);
    if (!nullToAbsent || modifiedAt != null) {
      map['modified_at'] = Variable<DateTime>(modifiedAt);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    map['display_name'] = Variable<String>(displayName);
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      id: Value(id),
      path: Value(path),
      uri: Value(uri),
      mediaType: Value(mediaType),
      size: Value(size),
      modifiedAt: modifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedAt),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      displayName: Value(displayName),
      scannedAt: Value(scannedAt),
    );
  }

  factory MediaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItem(
      id: serializer.fromJson<int>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      uri: serializer.fromJson<String>(json['uri']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      size: serializer.fromJson<int>(json['size']),
      modifiedAt: serializer.fromJson<DateTime?>(json['modifiedAt']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      displayName: serializer.fromJson<String>(json['displayName']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'path': serializer.toJson<String>(path),
      'uri': serializer.toJson<String>(uri),
      'mediaType': serializer.toJson<String>(mediaType),
      'size': serializer.toJson<int>(size),
      'modifiedAt': serializer.toJson<DateTime?>(modifiedAt),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'durationMs': serializer.toJson<int?>(durationMs),
      'mimeType': serializer.toJson<String?>(mimeType),
      'displayName': serializer.toJson<String>(displayName),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
    };
  }

  MediaItem copyWith({
    int? id,
    String? path,
    String? uri,
    String? mediaType,
    int? size,
    Value<DateTime?> modifiedAt = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    String? displayName,
    DateTime? scannedAt,
  }) => MediaItem(
    id: id ?? this.id,
    path: path ?? this.path,
    uri: uri ?? this.uri,
    mediaType: mediaType ?? this.mediaType,
    size: size ?? this.size,
    modifiedAt: modifiedAt.present ? modifiedAt.value : this.modifiedAt,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    displayName: displayName ?? this.displayName,
    scannedAt: scannedAt ?? this.scannedAt,
  );
  MediaItem copyWithCompanion(MediaItemsCompanion data) {
    return MediaItem(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      uri: data.uri.present ? data.uri.value : this.uri,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      size: data.size.present ? data.size.value : this.size,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItem(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('uri: $uri, ')
          ..write('mediaType: $mediaType, ')
          ..write('size: $size, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('mimeType: $mimeType, ')
          ..write('displayName: $displayName, ')
          ..write('scannedAt: $scannedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    path,
    uri,
    mediaType,
    size,
    modifiedAt,
    width,
    height,
    durationMs,
    mimeType,
    displayName,
    scannedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItem &&
          other.id == this.id &&
          other.path == this.path &&
          other.uri == this.uri &&
          other.mediaType == this.mediaType &&
          other.size == this.size &&
          other.modifiedAt == this.modifiedAt &&
          other.width == this.width &&
          other.height == this.height &&
          other.durationMs == this.durationMs &&
          other.mimeType == this.mimeType &&
          other.displayName == this.displayName &&
          other.scannedAt == this.scannedAt);
}

class MediaItemsCompanion extends UpdateCompanion<MediaItem> {
  final Value<int> id;
  final Value<String> path;
  final Value<String> uri;
  final Value<String> mediaType;
  final Value<int> size;
  final Value<DateTime?> modifiedAt;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> durationMs;
  final Value<String?> mimeType;
  final Value<String> displayName;
  final Value<DateTime> scannedAt;
  const MediaItemsCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.uri = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.size = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.displayName = const Value.absent(),
    this.scannedAt = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    this.id = const Value.absent(),
    required String path,
    required String uri,
    required String mediaType,
    required int size,
    this.modifiedAt = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.mimeType = const Value.absent(),
    required String displayName,
    required DateTime scannedAt,
  }) : path = Value(path),
       uri = Value(uri),
       mediaType = Value(mediaType),
       size = Value(size),
       displayName = Value(displayName),
       scannedAt = Value(scannedAt);
  static Insertable<MediaItem> custom({
    Expression<int>? id,
    Expression<String>? path,
    Expression<String>? uri,
    Expression<String>? mediaType,
    Expression<int>? size,
    Expression<DateTime>? modifiedAt,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? durationMs,
    Expression<String>? mimeType,
    Expression<String>? displayName,
    Expression<DateTime>? scannedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (uri != null) 'uri': uri,
      if (mediaType != null) 'media_type': mediaType,
      if (size != null) 'size': size,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (durationMs != null) 'duration_ms': durationMs,
      if (mimeType != null) 'mime_type': mimeType,
      if (displayName != null) 'display_name': displayName,
      if (scannedAt != null) 'scanned_at': scannedAt,
    });
  }

  MediaItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? path,
    Value<String>? uri,
    Value<String>? mediaType,
    Value<int>? size,
    Value<DateTime?>? modifiedAt,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? durationMs,
    Value<String?>? mimeType,
    Value<String>? displayName,
    Value<DateTime>? scannedAt,
  }) {
    return MediaItemsCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      uri: uri ?? this.uri,
      mediaType: mediaType ?? this.mediaType,
      size: size ?? this.size,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: durationMs ?? this.durationMs,
      mimeType: mimeType ?? this.mimeType,
      displayName: displayName ?? this.displayName,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('uri: $uri, ')
          ..write('mediaType: $mediaType, ')
          ..write('size: $size, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('mimeType: $mimeType, ')
          ..write('displayName: $displayName, ')
          ..write('scannedAt: $scannedAt')
          ..write(')'))
        .toString();
  }
}

class $CompressionJobsTable extends CompressionJobs
    with TableInfo<$CompressionJobsTable, CompressionJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompressionJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<int> mediaItemId = GeneratedColumn<int>(
    'media_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inputPathMeta = const VerificationMeta(
    'inputPath',
  );
  @override
  late final GeneratedColumn<String> inputPath = GeneratedColumn<String>(
    'input_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputUriMeta = const VerificationMeta(
    'inputUri',
  );
  @override
  late final GeneratedColumn<String> inputUri = GeneratedColumn<String>(
    'input_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalSizeMeta = const VerificationMeta(
    'originalSize',
  );
  @override
  late final GeneratedColumn<int> originalSize = GeneratedColumn<int>(
    'original_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outputPathMeta = const VerificationMeta(
    'outputPath',
  );
  @override
  late final GeneratedColumn<String> outputPath = GeneratedColumn<String>(
    'output_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outputSizeMeta = const VerificationMeta(
    'outputSize',
  );
  @override
  late final GeneratedColumn<int> outputSize = GeneratedColumn<int>(
    'output_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaItemId,
    inputPath,
    inputUri,
    displayName,
    mediaType,
    originalSize,
    status,
    attempts,
    progress,
    errorCode,
    errorMessage,
    outputPath,
    outputSize,
    settingsJson,
    nextAttemptAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compression_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompressionJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    }
    if (data.containsKey('input_path')) {
      context.handle(
        _inputPathMeta,
        inputPath.isAcceptableOrUnknown(data['input_path']!, _inputPathMeta),
      );
    } else if (isInserting) {
      context.missing(_inputPathMeta);
    }
    if (data.containsKey('input_uri')) {
      context.handle(
        _inputUriMeta,
        inputUri.isAcceptableOrUnknown(data['input_uri']!, _inputUriMeta),
      );
    } else if (isInserting) {
      context.missing(_inputUriMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('original_size')) {
      context.handle(
        _originalSizeMeta,
        originalSize.isAcceptableOrUnknown(
          data['original_size']!,
          _originalSizeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalSizeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('output_path')) {
      context.handle(
        _outputPathMeta,
        outputPath.isAcceptableOrUnknown(data['output_path']!, _outputPathMeta),
      );
    }
    if (data.containsKey('output_size')) {
      context.handle(
        _outputSizeMeta,
        outputSize.isAcceptableOrUnknown(data['output_size']!, _outputSizeMeta),
      );
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingsJsonMeta);
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompressionJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompressionJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_item_id'],
      ),
      inputPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_path'],
      )!,
      inputUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_uri'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      originalSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_size'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      outputPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_path'],
      ),
      outputSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}output_size'],
      ),
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CompressionJobsTable createAlias(String alias) {
    return $CompressionJobsTable(attachedDatabase, alias);
  }
}

class CompressionJob extends DataClass implements Insertable<CompressionJob> {
  final int id;
  final int? mediaItemId;
  final String inputPath;
  final String inputUri;
  final String displayName;
  final String mediaType;
  final int originalSize;
  final String status;
  final int attempts;
  final double progress;
  final String? errorCode;
  final String? errorMessage;
  final String? outputPath;
  final int? outputSize;
  final String settingsJson;
  final DateTime? nextAttemptAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CompressionJob({
    required this.id,
    this.mediaItemId,
    required this.inputPath,
    required this.inputUri,
    required this.displayName,
    required this.mediaType,
    required this.originalSize,
    required this.status,
    required this.attempts,
    required this.progress,
    this.errorCode,
    this.errorMessage,
    this.outputPath,
    this.outputSize,
    required this.settingsJson,
    this.nextAttemptAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || mediaItemId != null) {
      map['media_item_id'] = Variable<int>(mediaItemId);
    }
    map['input_path'] = Variable<String>(inputPath);
    map['input_uri'] = Variable<String>(inputUri);
    map['display_name'] = Variable<String>(displayName);
    map['media_type'] = Variable<String>(mediaType);
    map['original_size'] = Variable<int>(originalSize);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || outputPath != null) {
      map['output_path'] = Variable<String>(outputPath);
    }
    if (!nullToAbsent || outputSize != null) {
      map['output_size'] = Variable<int>(outputSize);
    }
    map['settings_json'] = Variable<String>(settingsJson);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CompressionJobsCompanion toCompanion(bool nullToAbsent) {
    return CompressionJobsCompanion(
      id: Value(id),
      mediaItemId: mediaItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaItemId),
      inputPath: Value(inputPath),
      inputUri: Value(inputUri),
      displayName: Value(displayName),
      mediaType: Value(mediaType),
      originalSize: Value(originalSize),
      status: Value(status),
      attempts: Value(attempts),
      progress: Value(progress),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      outputPath: outputPath == null && nullToAbsent
          ? const Value.absent()
          : Value(outputPath),
      outputSize: outputSize == null && nullToAbsent
          ? const Value.absent()
          : Value(outputSize),
      settingsJson: Value(settingsJson),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CompressionJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompressionJob(
      id: serializer.fromJson<int>(json['id']),
      mediaItemId: serializer.fromJson<int?>(json['mediaItemId']),
      inputPath: serializer.fromJson<String>(json['inputPath']),
      inputUri: serializer.fromJson<String>(json['inputUri']),
      displayName: serializer.fromJson<String>(json['displayName']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      originalSize: serializer.fromJson<int>(json['originalSize']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      progress: serializer.fromJson<double>(json['progress']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      outputPath: serializer.fromJson<String?>(json['outputPath']),
      outputSize: serializer.fromJson<int?>(json['outputSize']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mediaItemId': serializer.toJson<int?>(mediaItemId),
      'inputPath': serializer.toJson<String>(inputPath),
      'inputUri': serializer.toJson<String>(inputUri),
      'displayName': serializer.toJson<String>(displayName),
      'mediaType': serializer.toJson<String>(mediaType),
      'originalSize': serializer.toJson<int>(originalSize),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'progress': serializer.toJson<double>(progress),
      'errorCode': serializer.toJson<String?>(errorCode),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'outputPath': serializer.toJson<String?>(outputPath),
      'outputSize': serializer.toJson<int?>(outputSize),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CompressionJob copyWith({
    int? id,
    Value<int?> mediaItemId = const Value.absent(),
    String? inputPath,
    String? inputUri,
    String? displayName,
    String? mediaType,
    int? originalSize,
    String? status,
    int? attempts,
    double? progress,
    Value<String?> errorCode = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> outputPath = const Value.absent(),
    Value<int?> outputSize = const Value.absent(),
    String? settingsJson,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CompressionJob(
    id: id ?? this.id,
    mediaItemId: mediaItemId.present ? mediaItemId.value : this.mediaItemId,
    inputPath: inputPath ?? this.inputPath,
    inputUri: inputUri ?? this.inputUri,
    displayName: displayName ?? this.displayName,
    mediaType: mediaType ?? this.mediaType,
    originalSize: originalSize ?? this.originalSize,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    progress: progress ?? this.progress,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    outputPath: outputPath.present ? outputPath.value : this.outputPath,
    outputSize: outputSize.present ? outputSize.value : this.outputSize,
    settingsJson: settingsJson ?? this.settingsJson,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CompressionJob copyWithCompanion(CompressionJobsCompanion data) {
    return CompressionJob(
      id: data.id.present ? data.id.value : this.id,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      inputPath: data.inputPath.present ? data.inputPath.value : this.inputPath,
      inputUri: data.inputUri.present ? data.inputUri.value : this.inputUri,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      originalSize: data.originalSize.present
          ? data.originalSize.value
          : this.originalSize,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      progress: data.progress.present ? data.progress.value : this.progress,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      outputPath: data.outputPath.present
          ? data.outputPath.value
          : this.outputPath,
      outputSize: data.outputSize.present
          ? data.outputSize.value
          : this.outputSize,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompressionJob(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('inputPath: $inputPath, ')
          ..write('inputUri: $inputUri, ')
          ..write('displayName: $displayName, ')
          ..write('mediaType: $mediaType, ')
          ..write('originalSize: $originalSize, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('progress: $progress, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('outputPath: $outputPath, ')
          ..write('outputSize: $outputSize, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaItemId,
    inputPath,
    inputUri,
    displayName,
    mediaType,
    originalSize,
    status,
    attempts,
    progress,
    errorCode,
    errorMessage,
    outputPath,
    outputSize,
    settingsJson,
    nextAttemptAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompressionJob &&
          other.id == this.id &&
          other.mediaItemId == this.mediaItemId &&
          other.inputPath == this.inputPath &&
          other.inputUri == this.inputUri &&
          other.displayName == this.displayName &&
          other.mediaType == this.mediaType &&
          other.originalSize == this.originalSize &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.progress == this.progress &&
          other.errorCode == this.errorCode &&
          other.errorMessage == this.errorMessage &&
          other.outputPath == this.outputPath &&
          other.outputSize == this.outputSize &&
          other.settingsJson == this.settingsJson &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CompressionJobsCompanion extends UpdateCompanion<CompressionJob> {
  final Value<int> id;
  final Value<int?> mediaItemId;
  final Value<String> inputPath;
  final Value<String> inputUri;
  final Value<String> displayName;
  final Value<String> mediaType;
  final Value<int> originalSize;
  final Value<String> status;
  final Value<int> attempts;
  final Value<double> progress;
  final Value<String?> errorCode;
  final Value<String?> errorMessage;
  final Value<String?> outputPath;
  final Value<int?> outputSize;
  final Value<String> settingsJson;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CompressionJobsCompanion({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.inputPath = const Value.absent(),
    this.inputUri = const Value.absent(),
    this.displayName = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.originalSize = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.progress = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.outputPath = const Value.absent(),
    this.outputSize = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CompressionJobsCompanion.insert({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    required String inputPath,
    required String inputUri,
    required String displayName,
    required String mediaType,
    required int originalSize,
    required String status,
    this.attempts = const Value.absent(),
    this.progress = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.outputPath = const Value.absent(),
    this.outputSize = const Value.absent(),
    required String settingsJson,
    this.nextAttemptAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : inputPath = Value(inputPath),
       inputUri = Value(inputUri),
       displayName = Value(displayName),
       mediaType = Value(mediaType),
       originalSize = Value(originalSize),
       status = Value(status),
       settingsJson = Value(settingsJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CompressionJob> custom({
    Expression<int>? id,
    Expression<int>? mediaItemId,
    Expression<String>? inputPath,
    Expression<String>? inputUri,
    Expression<String>? displayName,
    Expression<String>? mediaType,
    Expression<int>? originalSize,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<double>? progress,
    Expression<String>? errorCode,
    Expression<String>? errorMessage,
    Expression<String>? outputPath,
    Expression<int>? outputSize,
    Expression<String>? settingsJson,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (inputPath != null) 'input_path': inputPath,
      if (inputUri != null) 'input_uri': inputUri,
      if (displayName != null) 'display_name': displayName,
      if (mediaType != null) 'media_type': mediaType,
      if (originalSize != null) 'original_size': originalSize,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (progress != null) 'progress': progress,
      if (errorCode != null) 'error_code': errorCode,
      if (errorMessage != null) 'error_message': errorMessage,
      if (outputPath != null) 'output_path': outputPath,
      if (outputSize != null) 'output_size': outputSize,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CompressionJobsCompanion copyWith({
    Value<int>? id,
    Value<int?>? mediaItemId,
    Value<String>? inputPath,
    Value<String>? inputUri,
    Value<String>? displayName,
    Value<String>? mediaType,
    Value<int>? originalSize,
    Value<String>? status,
    Value<int>? attempts,
    Value<double>? progress,
    Value<String?>? errorCode,
    Value<String?>? errorMessage,
    Value<String?>? outputPath,
    Value<int?>? outputSize,
    Value<String>? settingsJson,
    Value<DateTime?>? nextAttemptAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CompressionJobsCompanion(
      id: id ?? this.id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      inputPath: inputPath ?? this.inputPath,
      inputUri: inputUri ?? this.inputUri,
      displayName: displayName ?? this.displayName,
      mediaType: mediaType ?? this.mediaType,
      originalSize: originalSize ?? this.originalSize,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      progress: progress ?? this.progress,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      outputPath: outputPath ?? this.outputPath,
      outputSize: outputSize ?? this.outputSize,
      settingsJson: settingsJson ?? this.settingsJson,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<int>(mediaItemId.value);
    }
    if (inputPath.present) {
      map['input_path'] = Variable<String>(inputPath.value);
    }
    if (inputUri.present) {
      map['input_uri'] = Variable<String>(inputUri.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (originalSize.present) {
      map['original_size'] = Variable<int>(originalSize.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (outputPath.present) {
      map['output_path'] = Variable<String>(outputPath.value);
    }
    if (outputSize.present) {
      map['output_size'] = Variable<int>(outputSize.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompressionJobsCompanion(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('inputPath: $inputPath, ')
          ..write('inputUri: $inputUri, ')
          ..write('displayName: $displayName, ')
          ..write('mediaType: $mediaType, ')
          ..write('originalSize: $originalSize, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('progress: $progress, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('outputPath: $outputPath, ')
          ..write('outputSize: $outputSize, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RecycleBinEntriesTable extends RecycleBinEntries
    with TableInfo<$RecycleBinEntriesTable, RecycleBinEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecycleBinEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _originalPathMeta = const VerificationMeta(
    'originalPath',
  );
  @override
  late final GeneratedColumn<String> originalPath = GeneratedColumn<String>(
    'original_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalUriMeta = const VerificationMeta(
    'originalUri',
  );
  @override
  late final GeneratedColumn<String> originalUri = GeneratedColumn<String>(
    'original_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backupPathMeta = const VerificationMeta(
    'backupPath',
  );
  @override
  late final GeneratedColumn<String> backupPath = GeneratedColumn<String>(
    'backup_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    originalPath,
    originalUri,
    backupPath,
    displayName,
    size,
    createdAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recycle_bin_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecycleBinEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('original_path')) {
      context.handle(
        _originalPathMeta,
        originalPath.isAcceptableOrUnknown(
          data['original_path']!,
          _originalPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalPathMeta);
    }
    if (data.containsKey('original_uri')) {
      context.handle(
        _originalUriMeta,
        originalUri.isAcceptableOrUnknown(
          data['original_uri']!,
          _originalUriMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalUriMeta);
    }
    if (data.containsKey('backup_path')) {
      context.handle(
        _backupPathMeta,
        backupPath.isAcceptableOrUnknown(data['backup_path']!, _backupPathMeta),
      );
    } else if (isInserting) {
      context.missing(_backupPathMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecycleBinEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecycleBinEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      originalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_path'],
      )!,
      originalUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_uri'],
      )!,
      backupPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backup_path'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $RecycleBinEntriesTable createAlias(String alias) {
    return $RecycleBinEntriesTable(attachedDatabase, alias);
  }
}

class RecycleBinEntry extends DataClass implements Insertable<RecycleBinEntry> {
  final int id;
  final String originalPath;
  final String originalUri;
  final String backupPath;
  final String displayName;
  final int size;
  final DateTime createdAt;
  final DateTime expiresAt;
  const RecycleBinEntry({
    required this.id,
    required this.originalPath,
    required this.originalUri,
    required this.backupPath,
    required this.displayName,
    required this.size,
    required this.createdAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['original_path'] = Variable<String>(originalPath);
    map['original_uri'] = Variable<String>(originalUri);
    map['backup_path'] = Variable<String>(backupPath);
    map['display_name'] = Variable<String>(displayName);
    map['size'] = Variable<int>(size);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  RecycleBinEntriesCompanion toCompanion(bool nullToAbsent) {
    return RecycleBinEntriesCompanion(
      id: Value(id),
      originalPath: Value(originalPath),
      originalUri: Value(originalUri),
      backupPath: Value(backupPath),
      displayName: Value(displayName),
      size: Value(size),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory RecycleBinEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecycleBinEntry(
      id: serializer.fromJson<int>(json['id']),
      originalPath: serializer.fromJson<String>(json['originalPath']),
      originalUri: serializer.fromJson<String>(json['originalUri']),
      backupPath: serializer.fromJson<String>(json['backupPath']),
      displayName: serializer.fromJson<String>(json['displayName']),
      size: serializer.fromJson<int>(json['size']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'originalPath': serializer.toJson<String>(originalPath),
      'originalUri': serializer.toJson<String>(originalUri),
      'backupPath': serializer.toJson<String>(backupPath),
      'displayName': serializer.toJson<String>(displayName),
      'size': serializer.toJson<int>(size),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  RecycleBinEntry copyWith({
    int? id,
    String? originalPath,
    String? originalUri,
    String? backupPath,
    String? displayName,
    int? size,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) => RecycleBinEntry(
    id: id ?? this.id,
    originalPath: originalPath ?? this.originalPath,
    originalUri: originalUri ?? this.originalUri,
    backupPath: backupPath ?? this.backupPath,
    displayName: displayName ?? this.displayName,
    size: size ?? this.size,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  RecycleBinEntry copyWithCompanion(RecycleBinEntriesCompanion data) {
    return RecycleBinEntry(
      id: data.id.present ? data.id.value : this.id,
      originalPath: data.originalPath.present
          ? data.originalPath.value
          : this.originalPath,
      originalUri: data.originalUri.present
          ? data.originalUri.value
          : this.originalUri,
      backupPath: data.backupPath.present
          ? data.backupPath.value
          : this.backupPath,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      size: data.size.present ? data.size.value : this.size,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecycleBinEntry(')
          ..write('id: $id, ')
          ..write('originalPath: $originalPath, ')
          ..write('originalUri: $originalUri, ')
          ..write('backupPath: $backupPath, ')
          ..write('displayName: $displayName, ')
          ..write('size: $size, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    originalPath,
    originalUri,
    backupPath,
    displayName,
    size,
    createdAt,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecycleBinEntry &&
          other.id == this.id &&
          other.originalPath == this.originalPath &&
          other.originalUri == this.originalUri &&
          other.backupPath == this.backupPath &&
          other.displayName == this.displayName &&
          other.size == this.size &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class RecycleBinEntriesCompanion extends UpdateCompanion<RecycleBinEntry> {
  final Value<int> id;
  final Value<String> originalPath;
  final Value<String> originalUri;
  final Value<String> backupPath;
  final Value<String> displayName;
  final Value<int> size;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  const RecycleBinEntriesCompanion({
    this.id = const Value.absent(),
    this.originalPath = const Value.absent(),
    this.originalUri = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.displayName = const Value.absent(),
    this.size = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  RecycleBinEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String originalPath,
    required String originalUri,
    required String backupPath,
    required String displayName,
    required int size,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) : originalPath = Value(originalPath),
       originalUri = Value(originalUri),
       backupPath = Value(backupPath),
       displayName = Value(displayName),
       size = Value(size),
       createdAt = Value(createdAt),
       expiresAt = Value(expiresAt);
  static Insertable<RecycleBinEntry> custom({
    Expression<int>? id,
    Expression<String>? originalPath,
    Expression<String>? originalUri,
    Expression<String>? backupPath,
    Expression<String>? displayName,
    Expression<int>? size,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalPath != null) 'original_path': originalPath,
      if (originalUri != null) 'original_uri': originalUri,
      if (backupPath != null) 'backup_path': backupPath,
      if (displayName != null) 'display_name': displayName,
      if (size != null) 'size': size,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  RecycleBinEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? originalPath,
    Value<String>? originalUri,
    Value<String>? backupPath,
    Value<String>? displayName,
    Value<int>? size,
    Value<DateTime>? createdAt,
    Value<DateTime>? expiresAt,
  }) {
    return RecycleBinEntriesCompanion(
      id: id ?? this.id,
      originalPath: originalPath ?? this.originalPath,
      originalUri: originalUri ?? this.originalUri,
      backupPath: backupPath ?? this.backupPath,
      displayName: displayName ?? this.displayName,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (originalPath.present) {
      map['original_path'] = Variable<String>(originalPath.value);
    }
    if (originalUri.present) {
      map['original_uri'] = Variable<String>(originalUri.value);
    }
    if (backupPath.present) {
      map['backup_path'] = Variable<String>(backupPath.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecycleBinEntriesCompanion(')
          ..write('id: $id, ')
          ..write('originalPath: $originalPath, ')
          ..write('originalUri: $originalUri, ')
          ..write('backupPath: $backupPath, ')
          ..write('displayName: $displayName, ')
          ..write('size: $size, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

class $SavingsSessionsTable extends SavingsSessions
    with TableInfo<$SavingsSessionsTable, SavingsSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filesProcessedMeta = const VerificationMeta(
    'filesProcessed',
  );
  @override
  late final GeneratedColumn<int> filesProcessed = GeneratedColumn<int>(
    'files_processed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bytesFreedMeta = const VerificationMeta(
    'bytesFreed',
  );
  @override
  late final GeneratedColumn<int> bytesFreed = GeneratedColumn<int>(
    'bytes_freed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skippedCountMeta = const VerificationMeta(
    'skippedCount',
  );
  @override
  late final GeneratedColumn<int> skippedCount = GeneratedColumn<int>(
    'skipped_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failedCountMeta = const VerificationMeta(
    'failedCount',
  );
  @override
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
    'failed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    completedAt,
    filesProcessed,
    bytesFreed,
    skippedCount,
    failedCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('files_processed')) {
      context.handle(
        _filesProcessedMeta,
        filesProcessed.isAcceptableOrUnknown(
          data['files_processed']!,
          _filesProcessedMeta,
        ),
      );
    }
    if (data.containsKey('bytes_freed')) {
      context.handle(
        _bytesFreedMeta,
        bytesFreed.isAcceptableOrUnknown(data['bytes_freed']!, _bytesFreedMeta),
      );
    }
    if (data.containsKey('skipped_count')) {
      context.handle(
        _skippedCountMeta,
        skippedCount.isAcceptableOrUnknown(
          data['skipped_count']!,
          _skippedCountMeta,
        ),
      );
    }
    if (data.containsKey('failed_count')) {
      context.handle(
        _failedCountMeta,
        failedCount.isAcceptableOrUnknown(
          data['failed_count']!,
          _failedCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      filesProcessed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}files_processed'],
      )!,
      bytesFreed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_freed'],
      )!,
      skippedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped_count'],
      )!,
      failedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_count'],
      )!,
    );
  }

  @override
  $SavingsSessionsTable createAlias(String alias) {
    return $SavingsSessionsTable(attachedDatabase, alias);
  }
}

class SavingsSession extends DataClass implements Insertable<SavingsSession> {
  final int id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int filesProcessed;
  final int bytesFreed;
  final int skippedCount;
  final int failedCount;
  const SavingsSession({
    required this.id,
    required this.startedAt,
    this.completedAt,
    required this.filesProcessed,
    required this.bytesFreed,
    required this.skippedCount,
    required this.failedCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['files_processed'] = Variable<int>(filesProcessed);
    map['bytes_freed'] = Variable<int>(bytesFreed);
    map['skipped_count'] = Variable<int>(skippedCount);
    map['failed_count'] = Variable<int>(failedCount);
    return map;
  }

  SavingsSessionsCompanion toCompanion(bool nullToAbsent) {
    return SavingsSessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      filesProcessed: Value(filesProcessed),
      bytesFreed: Value(bytesFreed),
      skippedCount: Value(skippedCount),
      failedCount: Value(failedCount),
    );
  }

  factory SavingsSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsSession(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      filesProcessed: serializer.fromJson<int>(json['filesProcessed']),
      bytesFreed: serializer.fromJson<int>(json['bytesFreed']),
      skippedCount: serializer.fromJson<int>(json['skippedCount']),
      failedCount: serializer.fromJson<int>(json['failedCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'filesProcessed': serializer.toJson<int>(filesProcessed),
      'bytesFreed': serializer.toJson<int>(bytesFreed),
      'skippedCount': serializer.toJson<int>(skippedCount),
      'failedCount': serializer.toJson<int>(failedCount),
    };
  }

  SavingsSession copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    int? filesProcessed,
    int? bytesFreed,
    int? skippedCount,
    int? failedCount,
  }) => SavingsSession(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    filesProcessed: filesProcessed ?? this.filesProcessed,
    bytesFreed: bytesFreed ?? this.bytesFreed,
    skippedCount: skippedCount ?? this.skippedCount,
    failedCount: failedCount ?? this.failedCount,
  );
  SavingsSession copyWithCompanion(SavingsSessionsCompanion data) {
    return SavingsSession(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      filesProcessed: data.filesProcessed.present
          ? data.filesProcessed.value
          : this.filesProcessed,
      bytesFreed: data.bytesFreed.present
          ? data.bytesFreed.value
          : this.bytesFreed,
      skippedCount: data.skippedCount.present
          ? data.skippedCount.value
          : this.skippedCount,
      failedCount: data.failedCount.present
          ? data.failedCount.value
          : this.failedCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsSession(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('filesProcessed: $filesProcessed, ')
          ..write('bytesFreed: $bytesFreed, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('failedCount: $failedCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    completedAt,
    filesProcessed,
    bytesFreed,
    skippedCount,
    failedCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsSession &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.filesProcessed == this.filesProcessed &&
          other.bytesFreed == this.bytesFreed &&
          other.skippedCount == this.skippedCount &&
          other.failedCount == this.failedCount);
}

class SavingsSessionsCompanion extends UpdateCompanion<SavingsSession> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> filesProcessed;
  final Value<int> bytesFreed;
  final Value<int> skippedCount;
  final Value<int> failedCount;
  const SavingsSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.filesProcessed = const Value.absent(),
    this.bytesFreed = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.failedCount = const Value.absent(),
  });
  SavingsSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.filesProcessed = const Value.absent(),
    this.bytesFreed = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.failedCount = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<SavingsSession> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? filesProcessed,
    Expression<int>? bytesFreed,
    Expression<int>? skippedCount,
    Expression<int>? failedCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (filesProcessed != null) 'files_processed': filesProcessed,
      if (bytesFreed != null) 'bytes_freed': bytesFreed,
      if (skippedCount != null) 'skipped_count': skippedCount,
      if (failedCount != null) 'failed_count': failedCount,
    });
  }

  SavingsSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? filesProcessed,
    Value<int>? bytesFreed,
    Value<int>? skippedCount,
    Value<int>? failedCount,
  }) {
    return SavingsSessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      filesProcessed: filesProcessed ?? this.filesProcessed,
      bytesFreed: bytesFreed ?? this.bytesFreed,
      skippedCount: skippedCount ?? this.skippedCount,
      failedCount: failedCount ?? this.failedCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (filesProcessed.present) {
      map['files_processed'] = Variable<int>(filesProcessed.value);
    }
    if (bytesFreed.present) {
      map['bytes_freed'] = Variable<int>(bytesFreed.value);
    }
    if (skippedCount.present) {
      map['skipped_count'] = Variable<int>(skippedCount.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('filesProcessed: $filesProcessed, ')
          ..write('bytesFreed: $bytesFreed, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('failedCount: $failedCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$MediaDatabase extends GeneratedDatabase {
  _$MediaDatabase(QueryExecutor e) : super(e);
  $MediaDatabaseManager get managers => $MediaDatabaseManager(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  late final $CompressionJobsTable compressionJobs = $CompressionJobsTable(
    this,
  );
  late final $RecycleBinEntriesTable recycleBinEntries =
      $RecycleBinEntriesTable(this);
  late final $SavingsSessionsTable savingsSessions = $SavingsSessionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mediaItems,
    compressionJobs,
    recycleBinEntries,
    savingsSessions,
  ];
}

typedef $$MediaItemsTableCreateCompanionBuilder =
    MediaItemsCompanion Function({
      Value<int> id,
      required String path,
      required String uri,
      required String mediaType,
      required int size,
      Value<DateTime?> modifiedAt,
      Value<int?> width,
      Value<int?> height,
      Value<int?> durationMs,
      Value<String?> mimeType,
      required String displayName,
      required DateTime scannedAt,
    });
typedef $$MediaItemsTableUpdateCompanionBuilder =
    MediaItemsCompanion Function({
      Value<int> id,
      Value<String> path,
      Value<String> uri,
      Value<String> mediaType,
      Value<int> size,
      Value<DateTime?> modifiedAt,
      Value<int?> width,
      Value<int?> height,
      Value<int?> durationMs,
      Value<String?> mimeType,
      Value<String> displayName,
      Value<DateTime> scannedAt,
    });

class $$MediaItemsTableFilterComposer
    extends Composer<_$MediaDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$MediaDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$MediaDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);
}

class $$MediaItemsTableTableManager
    extends
        RootTableManager<
          _$MediaDatabase,
          $MediaItemsTable,
          MediaItem,
          $$MediaItemsTableFilterComposer,
          $$MediaItemsTableOrderingComposer,
          $$MediaItemsTableAnnotationComposer,
          $$MediaItemsTableCreateCompanionBuilder,
          $$MediaItemsTableUpdateCompanionBuilder,
          (
            MediaItem,
            BaseReferences<_$MediaDatabase, $MediaItemsTable, MediaItem>,
          ),
          MediaItem,
          PrefetchHooks Function()
        > {
  $$MediaItemsTableTableManager(_$MediaDatabase db, $MediaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<DateTime?> modifiedAt = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> scannedAt = const Value.absent(),
              }) => MediaItemsCompanion(
                id: id,
                path: path,
                uri: uri,
                mediaType: mediaType,
                size: size,
                modifiedAt: modifiedAt,
                width: width,
                height: height,
                durationMs: durationMs,
                mimeType: mimeType,
                displayName: displayName,
                scannedAt: scannedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String path,
                required String uri,
                required String mediaType,
                required int size,
                Value<DateTime?> modifiedAt = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                required String displayName,
                required DateTime scannedAt,
              }) => MediaItemsCompanion.insert(
                id: id,
                path: path,
                uri: uri,
                mediaType: mediaType,
                size: size,
                modifiedAt: modifiedAt,
                width: width,
                height: height,
                durationMs: durationMs,
                mimeType: mimeType,
                displayName: displayName,
                scannedAt: scannedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$MediaDatabase,
      $MediaItemsTable,
      MediaItem,
      $$MediaItemsTableFilterComposer,
      $$MediaItemsTableOrderingComposer,
      $$MediaItemsTableAnnotationComposer,
      $$MediaItemsTableCreateCompanionBuilder,
      $$MediaItemsTableUpdateCompanionBuilder,
      (MediaItem, BaseReferences<_$MediaDatabase, $MediaItemsTable, MediaItem>),
      MediaItem,
      PrefetchHooks Function()
    >;
typedef $$CompressionJobsTableCreateCompanionBuilder =
    CompressionJobsCompanion Function({
      Value<int> id,
      Value<int?> mediaItemId,
      required String inputPath,
      required String inputUri,
      required String displayName,
      required String mediaType,
      required int originalSize,
      required String status,
      Value<int> attempts,
      Value<double> progress,
      Value<String?> errorCode,
      Value<String?> errorMessage,
      Value<String?> outputPath,
      Value<int?> outputSize,
      required String settingsJson,
      Value<DateTime?> nextAttemptAt,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CompressionJobsTableUpdateCompanionBuilder =
    CompressionJobsCompanion Function({
      Value<int> id,
      Value<int?> mediaItemId,
      Value<String> inputPath,
      Value<String> inputUri,
      Value<String> displayName,
      Value<String> mediaType,
      Value<int> originalSize,
      Value<String> status,
      Value<int> attempts,
      Value<double> progress,
      Value<String?> errorCode,
      Value<String?> errorMessage,
      Value<String?> outputPath,
      Value<int?> outputSize,
      Value<String> settingsJson,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CompressionJobsTableFilterComposer
    extends Composer<_$MediaDatabase, $CompressionJobsTable> {
  $$CompressionJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputPath => $composableBuilder(
    column: $table.inputPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputUri => $composableBuilder(
    column: $table.inputUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalSize => $composableBuilder(
    column: $table.originalSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputPath => $composableBuilder(
    column: $table.outputPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outputSize => $composableBuilder(
    column: $table.outputSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompressionJobsTableOrderingComposer
    extends Composer<_$MediaDatabase, $CompressionJobsTable> {
  $$CompressionJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputPath => $composableBuilder(
    column: $table.inputPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputUri => $composableBuilder(
    column: $table.inputUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalSize => $composableBuilder(
    column: $table.originalSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputPath => $composableBuilder(
    column: $table.outputPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outputSize => $composableBuilder(
    column: $table.outputSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompressionJobsTableAnnotationComposer
    extends Composer<_$MediaDatabase, $CompressionJobsTable> {
  $$CompressionJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mediaItemId => $composableBuilder(
    column: $table.mediaItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inputPath =>
      $composableBuilder(column: $table.inputPath, builder: (column) => column);

  GeneratedColumn<String> get inputUri =>
      $composableBuilder(column: $table.inputUri, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<int> get originalSize => $composableBuilder(
    column: $table.originalSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outputPath => $composableBuilder(
    column: $table.outputPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outputSize => $composableBuilder(
    column: $table.outputSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CompressionJobsTableTableManager
    extends
        RootTableManager<
          _$MediaDatabase,
          $CompressionJobsTable,
          CompressionJob,
          $$CompressionJobsTableFilterComposer,
          $$CompressionJobsTableOrderingComposer,
          $$CompressionJobsTableAnnotationComposer,
          $$CompressionJobsTableCreateCompanionBuilder,
          $$CompressionJobsTableUpdateCompanionBuilder,
          (
            CompressionJob,
            BaseReferences<
              _$MediaDatabase,
              $CompressionJobsTable,
              CompressionJob
            >,
          ),
          CompressionJob,
          PrefetchHooks Function()
        > {
  $$CompressionJobsTableTableManager(
    _$MediaDatabase db,
    $CompressionJobsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompressionJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompressionJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompressionJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> mediaItemId = const Value.absent(),
                Value<String> inputPath = const Value.absent(),
                Value<String> inputUri = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<int> originalSize = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> outputPath = const Value.absent(),
                Value<int?> outputSize = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CompressionJobsCompanion(
                id: id,
                mediaItemId: mediaItemId,
                inputPath: inputPath,
                inputUri: inputUri,
                displayName: displayName,
                mediaType: mediaType,
                originalSize: originalSize,
                status: status,
                attempts: attempts,
                progress: progress,
                errorCode: errorCode,
                errorMessage: errorMessage,
                outputPath: outputPath,
                outputSize: outputSize,
                settingsJson: settingsJson,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> mediaItemId = const Value.absent(),
                required String inputPath,
                required String inputUri,
                required String displayName,
                required String mediaType,
                required int originalSize,
                required String status,
                Value<int> attempts = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> outputPath = const Value.absent(),
                Value<int?> outputSize = const Value.absent(),
                required String settingsJson,
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CompressionJobsCompanion.insert(
                id: id,
                mediaItemId: mediaItemId,
                inputPath: inputPath,
                inputUri: inputUri,
                displayName: displayName,
                mediaType: mediaType,
                originalSize: originalSize,
                status: status,
                attempts: attempts,
                progress: progress,
                errorCode: errorCode,
                errorMessage: errorMessage,
                outputPath: outputPath,
                outputSize: outputSize,
                settingsJson: settingsJson,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompressionJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$MediaDatabase,
      $CompressionJobsTable,
      CompressionJob,
      $$CompressionJobsTableFilterComposer,
      $$CompressionJobsTableOrderingComposer,
      $$CompressionJobsTableAnnotationComposer,
      $$CompressionJobsTableCreateCompanionBuilder,
      $$CompressionJobsTableUpdateCompanionBuilder,
      (
        CompressionJob,
        BaseReferences<_$MediaDatabase, $CompressionJobsTable, CompressionJob>,
      ),
      CompressionJob,
      PrefetchHooks Function()
    >;
typedef $$RecycleBinEntriesTableCreateCompanionBuilder =
    RecycleBinEntriesCompanion Function({
      Value<int> id,
      required String originalPath,
      required String originalUri,
      required String backupPath,
      required String displayName,
      required int size,
      required DateTime createdAt,
      required DateTime expiresAt,
    });
typedef $$RecycleBinEntriesTableUpdateCompanionBuilder =
    RecycleBinEntriesCompanion Function({
      Value<int> id,
      Value<String> originalPath,
      Value<String> originalUri,
      Value<String> backupPath,
      Value<String> displayName,
      Value<int> size,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
    });

class $$RecycleBinEntriesTableFilterComposer
    extends Composer<_$MediaDatabase, $RecycleBinEntriesTable> {
  $$RecycleBinEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalUri => $composableBuilder(
    column: $table.originalUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecycleBinEntriesTableOrderingComposer
    extends Composer<_$MediaDatabase, $RecycleBinEntriesTable> {
  $$RecycleBinEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalUri => $composableBuilder(
    column: $table.originalUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecycleBinEntriesTableAnnotationComposer
    extends Composer<_$MediaDatabase, $RecycleBinEntriesTable> {
  $$RecycleBinEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalUri => $composableBuilder(
    column: $table.originalUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$RecycleBinEntriesTableTableManager
    extends
        RootTableManager<
          _$MediaDatabase,
          $RecycleBinEntriesTable,
          RecycleBinEntry,
          $$RecycleBinEntriesTableFilterComposer,
          $$RecycleBinEntriesTableOrderingComposer,
          $$RecycleBinEntriesTableAnnotationComposer,
          $$RecycleBinEntriesTableCreateCompanionBuilder,
          $$RecycleBinEntriesTableUpdateCompanionBuilder,
          (
            RecycleBinEntry,
            BaseReferences<
              _$MediaDatabase,
              $RecycleBinEntriesTable,
              RecycleBinEntry
            >,
          ),
          RecycleBinEntry,
          PrefetchHooks Function()
        > {
  $$RecycleBinEntriesTableTableManager(
    _$MediaDatabase db,
    $RecycleBinEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecycleBinEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecycleBinEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecycleBinEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> originalPath = const Value.absent(),
                Value<String> originalUri = const Value.absent(),
                Value<String> backupPath = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => RecycleBinEntriesCompanion(
                id: id,
                originalPath: originalPath,
                originalUri: originalUri,
                backupPath: backupPath,
                displayName: displayName,
                size: size,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String originalPath,
                required String originalUri,
                required String backupPath,
                required String displayName,
                required int size,
                required DateTime createdAt,
                required DateTime expiresAt,
              }) => RecycleBinEntriesCompanion.insert(
                id: id,
                originalPath: originalPath,
                originalUri: originalUri,
                backupPath: backupPath,
                displayName: displayName,
                size: size,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecycleBinEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$MediaDatabase,
      $RecycleBinEntriesTable,
      RecycleBinEntry,
      $$RecycleBinEntriesTableFilterComposer,
      $$RecycleBinEntriesTableOrderingComposer,
      $$RecycleBinEntriesTableAnnotationComposer,
      $$RecycleBinEntriesTableCreateCompanionBuilder,
      $$RecycleBinEntriesTableUpdateCompanionBuilder,
      (
        RecycleBinEntry,
        BaseReferences<
          _$MediaDatabase,
          $RecycleBinEntriesTable,
          RecycleBinEntry
        >,
      ),
      RecycleBinEntry,
      PrefetchHooks Function()
    >;
typedef $$SavingsSessionsTableCreateCompanionBuilder =
    SavingsSessionsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<int> filesProcessed,
      Value<int> bytesFreed,
      Value<int> skippedCount,
      Value<int> failedCount,
    });
typedef $$SavingsSessionsTableUpdateCompanionBuilder =
    SavingsSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int> filesProcessed,
      Value<int> bytesFreed,
      Value<int> skippedCount,
      Value<int> failedCount,
    });

class $$SavingsSessionsTableFilterComposer
    extends Composer<_$MediaDatabase, $SavingsSessionsTable> {
  $$SavingsSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get filesProcessed => $composableBuilder(
    column: $table.filesProcessed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesFreed => $composableBuilder(
    column: $table.bytesFreed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingsSessionsTableOrderingComposer
    extends Composer<_$MediaDatabase, $SavingsSessionsTable> {
  $$SavingsSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get filesProcessed => $composableBuilder(
    column: $table.filesProcessed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesFreed => $composableBuilder(
    column: $table.bytesFreed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsSessionsTableAnnotationComposer
    extends Composer<_$MediaDatabase, $SavingsSessionsTable> {
  $$SavingsSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get filesProcessed => $composableBuilder(
    column: $table.filesProcessed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bytesFreed => $composableBuilder(
    column: $table.bytesFreed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => column,
  );
}

class $$SavingsSessionsTableTableManager
    extends
        RootTableManager<
          _$MediaDatabase,
          $SavingsSessionsTable,
          SavingsSession,
          $$SavingsSessionsTableFilterComposer,
          $$SavingsSessionsTableOrderingComposer,
          $$SavingsSessionsTableAnnotationComposer,
          $$SavingsSessionsTableCreateCompanionBuilder,
          $$SavingsSessionsTableUpdateCompanionBuilder,
          (
            SavingsSession,
            BaseReferences<
              _$MediaDatabase,
              $SavingsSessionsTable,
              SavingsSession
            >,
          ),
          SavingsSession,
          PrefetchHooks Function()
        > {
  $$SavingsSessionsTableTableManager(
    _$MediaDatabase db,
    $SavingsSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> filesProcessed = const Value.absent(),
                Value<int> bytesFreed = const Value.absent(),
                Value<int> skippedCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
              }) => SavingsSessionsCompanion(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                filesProcessed: filesProcessed,
                bytesFreed: bytesFreed,
                skippedCount: skippedCount,
                failedCount: failedCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> filesProcessed = const Value.absent(),
                Value<int> bytesFreed = const Value.absent(),
                Value<int> skippedCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
              }) => SavingsSessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                filesProcessed: filesProcessed,
                bytesFreed: bytesFreed,
                skippedCount: skippedCount,
                failedCount: failedCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$MediaDatabase,
      $SavingsSessionsTable,
      SavingsSession,
      $$SavingsSessionsTableFilterComposer,
      $$SavingsSessionsTableOrderingComposer,
      $$SavingsSessionsTableAnnotationComposer,
      $$SavingsSessionsTableCreateCompanionBuilder,
      $$SavingsSessionsTableUpdateCompanionBuilder,
      (
        SavingsSession,
        BaseReferences<_$MediaDatabase, $SavingsSessionsTable, SavingsSession>,
      ),
      SavingsSession,
      PrefetchHooks Function()
    >;

class $MediaDatabaseManager {
  final _$MediaDatabase _db;
  $MediaDatabaseManager(this._db);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
  $$CompressionJobsTableTableManager get compressionJobs =>
      $$CompressionJobsTableTableManager(_db, _db.compressionJobs);
  $$RecycleBinEntriesTableTableManager get recycleBinEntries =>
      $$RecycleBinEntriesTableTableManager(_db, _db.recycleBinEntries);
  $$SavingsSessionsTableTableManager get savingsSessions =>
      $$SavingsSessionsTableTableManager(_db, _db.savingsSessions);
}
