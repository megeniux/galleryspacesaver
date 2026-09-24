import 'package:flutter/services.dart';

enum MediaKind { image, video, audio }

enum MediaPermissionState {
  undetermined,
  granted,
  partial,
  denied,
  permanentlyDenied,
}

class MediaPermissionStatus {
  const MediaPermissionStatus(
    this.state, {
    this.visualUserSelected = false,
    this.grantedKinds = const <MediaKind>{},
  });

  final MediaPermissionState state;

  /// True when Android 14+ only granted access to user-selected photos/videos.
  final bool visualUserSelected;

  /// The media kinds that can actually be scanned right now.
  final Set<MediaKind> grantedKinds;

  bool get canScan =>
      state == MediaPermissionState.granted ||
      state == MediaPermissionState.partial;

  /// Partial access can always be widened by re-opening the Android picker.
  bool get canSelectMore => state == MediaPermissionState.partial;

  bool allows(MediaKind kind) =>
      state == MediaPermissionState.granted ||
      grantedKinds.isEmpty ||
      grantedKinds.contains(kind);
}

class StorageInfo {
  const StorageInfo({required this.totalBytes, required this.freeBytes});

  final int totalBytes;
  final int freeBytes;

  int get usedBytes => (totalBytes - freeBytes).clamp(0, totalBytes).toInt();
}

class MediaRow {
  const MediaRow({
    required this.path,
    required this.uri,
    required this.type,
    required this.size,
    required this.modifiedAt,
    required this.width,
    required this.height,
    required this.durationMs,
    required this.mimeType,
    required this.displayName,
  });

  factory MediaRow.fromMap(Map<Object?, Object?> map) {
    int? intValue(Object? value) => value is num ? value.toInt() : null;
    return MediaRow(
      path: map['path'] as String? ?? map['uri'] as String? ?? '',
      uri: map['uri'] as String? ?? '',
      type: MediaKind.values.firstWhere(
        (kind) => kind.name == map['type'],
        orElse: () => MediaKind.image,
      ),
      size: intValue(map['size']) ?? 0,
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(
        intValue(map['dateMillis']) ?? 0,
      ),
      width: intValue(map['width']),
      height: intValue(map['height']),
      durationMs: intValue(map['durationMs']),
      mimeType: map['mime'] as String?,
      displayName: map['name'] as String? ?? '',
    );
  }

  final String path;
  final String uri;
  final MediaKind type;
  final int size;
  final DateTime modifiedAt;
  final int? width;
  final int? height;
  final int? durationMs;
  final String? mimeType;
  final String displayName;
}

class MediaPlatform {
  const MediaPlatform();

  static const _channel = MethodChannel('com.techrigel.rigelspacesaver/media');

  Future<MediaPermissionStatus> permissionStatus() async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'permissionStatus',
    );
    return _statusFrom(result);
  }

  /// Requests media access. Pass [kinds] to re-open the Android 14 picker for
  /// photos and videos only (the "select more" flow).
  Future<MediaPermissionStatus> requestPermissions({
    Iterable<MediaKind>? kinds,
  }) async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'requestPermissions',
      <String, Object>{
        'types': (kinds ?? MediaKind.values).map((kind) => kind.name).toList(),
      },
    );
    return _statusFrom(result);
  }

  Future<void> openAppSettings() =>
      _channel.invokeMethod<void>('openAppSettings');

  Future<void> openPreview({required String path, required String mediaType}) {
    final mimeType = switch (mediaType) {
      'image' => 'image/*',
      'video' => 'video/*',
      'audio' => 'audio/*',
      _ => 'application/octet-stream',
    };
    return _channel.invokeMethod<void>('openPreview', <String, String>{
      'path': path,
      'mimeType': mimeType,
    });
  }

  Future<void> openMediaPreview({
    required String uri,
    required String mediaType,
    String? mimeType,
  }) => _channel.invokeMethod<void>('openMediaPreview', <String, String>{
    'uri': uri,
    'mediaType': mediaType,
    'mimeType': ?mimeType,
  });

  Future<List<MediaRow>> scan({DateTime? modifiedAfter}) async {
    final result = await _channel
        .invokeListMethod<Object?>('scanMedia', <String, Object>{
          'types': MediaKind.values.map((kind) => kind.name).toList(),
          if (modifiedAfter != null)
            'modifiedAfter': modifiedAfter.millisecondsSinceEpoch,
        });
    return (result ?? const <Object?>[])
        .whereType<Map<Object?, Object?>>()
        .map(MediaRow.fromMap)
        .toList();
  }

  Future<Uint8List?> thumbnail(String uri, MediaKind type) {
    return _channel.invokeMethod<Uint8List>('thumbnail', <String, Object>{
      'uri': uri,
      'type': type.name,
    });
  }

  Future<Uint8List?> previewCompression({
    required String uri,
    required String mimeType,
    required int quality,
    required int maxDimension,
  }) {
    return _channel.invokeMethod<Uint8List>(
      'previewCompression',
      <String, Object>{
        'uri': uri,
        'mime': mimeType,
        'quality': quality,
        'maxDimension': maxDimension,
      },
    );
  }

  Future<String> copyToCache({
    required String source,
    required String targetPath,
  }) async {
    final result = await _channel.invokeMethod<String>(
      'copyMediaToCache',
      <String, Object>{'source': source, 'targetPath': targetPath},
    );
    if (result == null || result.isEmpty) {
      throw StateError('Media could not be staged in app cache.');
    }
    return result;
  }

  Future<String> compressImage({
    required String source,
    required String outputPath,
    required String mimeType,
    required int quality,
    required int maxDimension,
  }) async {
    final result = await _channel
        .invokeMethod<String>('compressImage', <String, Object>{
          'source': source,
          'outputPath': outputPath,
          'mime': mimeType,
          'quality': quality,
          'maxDimension': maxDimension,
        });
    if (result == null || result.isEmpty) {
      throw StateError('Image compression produced no output.');
    }
    return result;
  }

  Future<Map<String, Object?>> processingGuards() async {
    return (await _channel.invokeMapMethod<String, Object?>(
          'processingGuards',
        )) ??
        const <String, Object?>{};
  }

  Future<StorageInfo> storageInfo() async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'storageInfo',
    );
    return StorageInfo(
      totalBytes: (result?['totalBytes'] as num?)?.toInt() ?? 0,
      freeBytes: (result?['freeBytes'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> startProcessingService() =>
      _channel.invokeMethod<void>('startProcessingService');

  Future<void> stopProcessingService() =>
      _channel.invokeMethod<void>('stopProcessingService');

  Future<bool> requestMediaStoreConsent({
    required String uri,
    required String action,
  }) async {
    return await _channel.invokeMethod<bool>(
          'requestMediaStoreConsent',
          <String, Object>{'uri': uri, 'action': action},
        ) ??
        false;
  }

  Future<void> writeCachedFileToUri({
    required String sourcePath,
    required String uri,
  }) {
    return _channel.invokeMethod<void>('writeCachedFileToUri', <String, Object>{
      'sourcePath': sourcePath,
      'uri': uri,
    });
  }

  Future<bool> mediaUriMatchesFile({
    required String sourcePath,
    required String uri,
  }) async {
    return await _channel.invokeMethod<bool>(
          'verifyMediaUriMatchesFile',
          <String, Object>{'sourcePath': sourcePath, 'uri': uri},
        ) ??
        false;
  }

  Future<MediaRow?> mediaInfo({
    required String uri,
    required String type,
  }) async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'mediaInfo',
      <String, Object>{'uri': uri, 'type': type},
    );
    return result == null
        ? null
        : MediaRow.fromMap(Map<Object?, Object?>.from(result));
  }

  Future<void> deleteMediaUri(String uri) {
    return _channel.invokeMethod<void>('deleteMediaUri', <String, Object>{
      'uri': uri,
    });
  }

  Future<void> rescanMedia(String path) {
    return _channel.invokeMethod<void>('rescanMedia', <String, Object>{
      'path': path,
    });
  }

  MediaPermissionStatus _statusFrom(Map<String, Object?>? result) {
    final state = MediaPermissionState.values.firstWhere(
      (item) => item.name == result?['state'],
      orElse: () => MediaPermissionState.denied,
    );
    final granted =
        (result?['grantedTypes'] as List?)
            ?.whereType<String>()
            .map(
              (name) => MediaKind.values
                  .where((kind) => kind.name == name)
                  .firstOrNull,
            )
            .whereType<MediaKind>()
            .toSet() ??
        const <MediaKind>{};
    return MediaPermissionStatus(
      state,
      visualUserSelected: result?['visualUserSelected'] == true,
      grantedKinds: granted,
    );
  }
}
