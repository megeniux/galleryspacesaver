import 'dart:io';

enum MediaFormat {
  jpeg('jpeg', 'image/jpeg', 'image'),
  png('png', 'image/png', 'image'),
  heic('heic', 'image/heic', 'image'),
  webp('webp', 'image/webp', 'image'),
  gif('gif', 'image/gif', 'image'),
  bmp('bmp', 'image/bmp', 'image'),
  tiff('tiff', 'image/tiff', 'image'),
  mp4('mp4', 'video/mp4', 'video'),
  mkv('mkv', 'video/x-matroska', 'video'),
  mov('mov', 'video/quicktime', 'video'),
  threeGp('3gp', 'video/3gpp', 'video'),
  avi('avi', 'video/x-msvideo', 'video'),
  webm('webm', 'video/webm', 'video'),
  mp3('mp3', 'audio/mpeg', 'audio'),
  aac('aac', 'audio/aac', 'audio'),
  m4a('m4a', 'audio/mp4', 'audio'),
  wav('wav', 'audio/wav', 'audio'),
  flac('flac', 'audio/flac', 'audio'),
  ogg('ogg', 'audio/ogg', 'audio'),
  opus('opus', 'audio/opus', 'audio');

  const MediaFormat(this.extension, this.mimeType, this.mediaType);
  final String extension;
  final String mimeType;
  final String mediaType;
}

enum CodecPath { nativeImage, ffmpeg }

class DetectedFormat {
  const DetectedFormat({required this.format, required this.path});
  final MediaFormat format;
  final CodecPath path;
}

class CodecStrategy {
  const CodecStrategy._();

  static Future<DetectedFormat?> detectFile(File file, {String? fallbackMime}) async {
    if (!await file.exists()) return null;
    final bytes = await file.openRead(0, 64 * 1024).fold<List<int>>(<int>[], (all, chunk) => all..addAll(chunk));
    return detectBytes(bytes, fallbackMime: fallbackMime);
  }

  static DetectedFormat? detectBytes(List<int> bytes, {String? fallbackMime}) {
    MediaFormat? format;
    bool starts(List<int> signature) => bytes.length >= signature.length && _matches(bytes, signature);
    if (starts([0xFF, 0xD8, 0xFF])) format = MediaFormat.jpeg;
    if (starts([0x89, 0x50, 0x4E, 0x47])) format = MediaFormat.png;
    if (starts('GIF'.codeUnits)) format = MediaFormat.gif;
    if (starts('BM'.codeUnits)) format = MediaFormat.bmp;
    if (starts([0x49, 0x49, 0x2A, 0x00]) || starts([0x4D, 0x4D, 0x00, 0x2A])) format = MediaFormat.tiff;
    if (starts('RIFF'.codeUnits) && _containsAt(bytes, 'WEBP'.codeUnits, 8)) format = MediaFormat.webp;
    if (starts('RIFF'.codeUnits) && _containsAt(bytes, 'AVI '.codeUnits, 8)) format = MediaFormat.avi;
    if (_containsAt(bytes, 'ftyp'.codeUnits, 4)) format = _formatFromFtyp(bytes);
    if (starts([0x1A, 0x45, 0xDF, 0xA3])) format ??= _extensionFormat(fallbackMime);
    if (starts('ID3'.codeUnits) || (bytes.length > 1 && bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0)) format = MediaFormat.mp3;
    if (starts('fLaC'.codeUnits)) format = MediaFormat.flac;
    if (starts('OggS'.codeUnits)) format = fallbackMime?.contains('opus') == true ? MediaFormat.opus : MediaFormat.ogg;
    if (starts('RIFF'.codeUnits) && _containsAt(bytes, 'WAVE'.codeUnits, 8)) format = MediaFormat.wav;
    format ??= _extensionFormat(fallbackMime);
    if (format == null) return null;
    return DetectedFormat(
      format: format,
      path: _nativeImageFormats.contains(format) ? CodecPath.nativeImage : CodecPath.ffmpeg,
    );
  }

  static const _nativeImageFormats = {MediaFormat.jpeg, MediaFormat.webp};

  static MediaFormat? _formatFromFtyp(List<int> bytes) {
    final brand = String.fromCharCodes(bytes.skip(8).take(4));
    if (brand == 'qt  ') return MediaFormat.mov;
    if (brand == 'heic' || brand == 'heix' || brand == 'heif' || brand == 'hevc' || brand == 'hevx') return MediaFormat.heic;
    if (brand == 'M4A ' || brand == 'M4B ') return MediaFormat.m4a;
    if (brand == '3gp4' || brand == '3gp5') return MediaFormat.threeGp;
    return MediaFormat.mp4;
  }

  static MediaFormat? _extensionFormat(String? mime) {
    final value = mime?.toLowerCase();
    return MediaFormat.values.where((format) => format.mimeType == value).firstOrNull;
  }

  static bool _matches(List<int> bytes, List<int> signature) {
    for (var index = 0; index < signature.length; index++) {
      if (bytes[index] != signature[index]) return false;
    }
    return true;
  }

  static bool _containsAt(List<int> bytes, List<int> signature, int offset) {
    if (bytes.length < offset + signature.length) return false;
    for (var index = 0; index < signature.length; index++) {
      if (bytes[offset + index] != signature[index]) return false;
    }
    return true;
  }
}
