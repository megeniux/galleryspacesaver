import 'package:flutter_test/flutter_test.dart';
import 'package:rigel_space_saver/core/utils/formatters.dart';

void main() {
  group('formatBytes', () {
    test('formats bytes below 1 KB', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(512), '512 B');
    });

    test('formats kilobytes, megabytes and gigabytes', () {
      expect(formatBytes(1536), '1.5 KB');
      expect(formatBytes(5 * 1024 * 1024), '5.0 MB');
      expect(formatBytes(3 * 1024 * 1024 * 1024), '3.0 GB');
    });

    test('drops decimals for large values within a unit', () {
      expect(formatBytes(700 * 1024 * 1024), '700 MB');
    });

    test('treats negative input as zero', () {
      expect(formatBytes(-10), '0 B');
    });
  });

  group('formatDuration', () {
    test('formats minutes and seconds', () {
      expect(formatDuration(const Duration(minutes: 3, seconds: 7)), '3:07');
    });

    test('formats hours when present', () {
      expect(
        formatDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });
  });

  group('path helpers', () {
    test('extracts lowercase extension', () {
      expect(fileExtension('/storage/DCIM/Photo.JPG'), 'jpg');
      expect(fileExtension(r'C:\media\clip.mp4'), 'mp4');
      expect(fileExtension('/storage/noextension'), '');
    });

    test('extracts file name', () {
      expect(fileName('/storage/DCIM/Photo.jpg'), 'Photo.jpg');
      expect(fileName(r'C:\media\clip.mp4'), 'clip.mp4');
    });
  });
}
