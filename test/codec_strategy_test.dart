import 'package:flutter_test/flutter_test.dart';
import 'package:rigel_space_saver/features/compression/domain/codec_strategy.dart';

void main() {
  test('detects image formats from headers rather than extensions', () {
    expect(CodecStrategy.detectBytes([0xFF, 0xD8, 0xFF])?.format, MediaFormat.jpeg);
    expect(CodecStrategy.detectBytes([0x89, 0x50, 0x4E, 0x47])?.format, MediaFormat.png);
    expect(CodecStrategy.detectBytes([... 'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits])?.format, MediaFormat.webp);
  });

  test('uses MIME fallback only when the header is unknown', () {
    final result = CodecStrategy.detectBytes([1, 2, 3], fallbackMime: 'audio/flac');
    expect(result?.format, MediaFormat.flac);
    expect(result?.path, CodecPath.ffmpeg);
  });

  test('routes simple images to the native image path', () {
    expect(CodecStrategy.detectBytes('GIF89a'.codeUnits)?.path, CodecPath.ffmpeg);
    expect(CodecStrategy.detectBytes([0xFF, 0xD8, 0xFF])?.path, CodecPath.nativeImage);
  });

  test('keeps QuickTime and AVI containers distinct from MP4', () {
    expect(CodecStrategy.detectBytes([... '....ftyp'.codeUnits, ...'qt  '.codeUnits])?.format, MediaFormat.mov);
    expect(CodecStrategy.detectBytes([... 'RIFF'.codeUnits, 0, 0, 0, 0, ...'AVI '.codeUnits])?.format, MediaFormat.avi);
  });
}
