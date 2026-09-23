import 'data/media_database.dart';
import 'selection_controller.dart';

int estimateSavings(MediaItem item, CompressionSettings settings) {
  final ratio = switch (settings.preset) {
    CompressionPreset.light => switch (item.mediaType) {
      'image' => .12,
      'video' => .10,
      _ => .08,
    },
    CompressionPreset.balanced => switch (item.mediaType) {
      'image' => .27,
      'video' => .25,
      _ => .20,
    },
    CompressionPreset.aggressive => switch (item.mediaType) {
      'image' => .43,
      'video' => .40,
      _ => .35,
    },
    CompressionPreset.custom => _customRatio(item, settings),
  };
  return (item.size * ratio).round().clamp(0, item.size);
}

int estimateSelectedSavings(Iterable<MediaItem> items, CompressionSettings settings) {
  return items.fold(0, (sum, item) => sum + estimateSavings(item, settings));
}

double _customRatio(MediaItem item, CompressionSettings settings) {
  if (item.mediaType == 'image') {
    final qualitySavings = (100 - settings.imageQuality) / 100 * .65;
    final dimensionSavings = _dimensionFactor(item.width, item.height, settings.imageMaxDimension);
    return (qualitySavings + dimensionSavings).clamp(.05, .70);
  }
  if (item.mediaType == 'video') {
    final bitrateSavings = (1 - settings.videoBitrateKbps / 8000).clamp(.05, .75);
    final dimensionSavings = _dimensionFactor(item.width, item.height, settings.videoMaxDimension);
    return (bitrateSavings * .7 + dimensionSavings * .3).clamp(.05, .75);
  }
  return (1 - settings.audioBitrateKbps / 320).clamp(.05, .65);
}

double _dimensionFactor(int? width, int? height, int maxDimension) {
  final largest = [width ?? 0, height ?? 0].reduce((a, b) => a > b ? a : b);
  if (largest <= maxDimension || largest == 0) return .02;
  return (1 - maxDimension / largest).clamp(0, .45);
}
