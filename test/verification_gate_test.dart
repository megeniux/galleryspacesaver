import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rigel_space_saver/features/compression/domain/codec_strategy.dart';
import 'package:rigel_space_saver/features/compression/domain/verification_gate.dart';
import 'package:rigel_space_saver/features/media/data/media_database.dart';

void main() {
  final input = MediaItem(
    id: 1,
    path: '/input.jpg',
    uri: 'content://input.jpg',
    mediaType: 'image',
    size: 100,
    width: 100,
    height: 100,
    displayName: 'input.jpg',
    scannedAt: DateTime(2026),
  );

  test('rejects a missing output before any decode attempt', () async {
    final result = await VerificationGate.verify(
      input: input,
      output: File('${Directory.systemTemp.path}/does-not-exist-rigel.jpg'),
      format: MediaFormat.jpeg,
    );

    expect(result.passed, isFalse);
    expect(result.reason, contains('no output'));
  });

  test('rejects output that is not smaller than the source', () async {
    final file = File('${Directory.systemTemp.path}/rigel-larger-output.bin');
    await file.writeAsBytes(List<int>.filled(101, 0));
    addTearDown(() => file.delete());

    final result = await VerificationGate.verify(input: input, output: file, format: MediaFormat.jpeg);

    expect(result.passed, isFalse);
    expect(result.reason, contains('not smaller'));
  });
}
