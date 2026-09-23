import 'package:flutter_test/flutter_test.dart';
import 'package:rigel_space_saver/features/media/data/media_database.dart';
import 'package:rigel_space_saver/features/media/selection_controller.dart';
import 'package:rigel_space_saver/features/media/selection_estimator.dart';

void main() {
  final scannedAt = DateTime(2026);

  MediaItem item({required String type, int size = 1000}) => MediaItem(
    id: 1,
    path: '/media/item',
    uri: 'content://media/item',
    mediaType: type,
    size: size,
    displayName: 'item',
    scannedAt: scannedAt,
  );

  test('balanced estimate is positive and never exceeds the source', () {
    final source = item(type: 'image', size: 10 * 1024 * 1024);
    final savings = estimateSavings(source, const CompressionSettings());

    expect(savings, greaterThan(0));
    expect(savings, lessThanOrEqualTo(source.size));
  });

  test('custom image dimensions increase estimated savings for a large image', () {
    final source = MediaItem(
      id: 1,
      path: '/media/item',
      uri: 'content://media/item',
      mediaType: 'image',
      size: 10 * 1024 * 1024,
      width: 4000,
      height: 3000,
      displayName: 'item',
      scannedAt: scannedAt,
    );
    final settings = const CompressionSettings(preset: CompressionPreset.custom, imageQuality: 70, imageMaxDimension: 720);
    expect(estimateSavings(source, settings), greaterThan(estimateSavings(source, settings.copyWith(imageMaxDimension: 4000))));
  });

  test('selection controller toggles and clears URIs', () {
    final controller = SelectionController();
    addTearDown(controller.dispose);

    controller.toggle('one');
    controller.toggle('two');
    expect(controller.state.selectedUris, {'one', 'two'});
    controller.toggle('one');
    expect(controller.state.selectedUris, {'two'});
    controller.clear();
    expect(controller.state.selectedUris, isEmpty);
  });
}
