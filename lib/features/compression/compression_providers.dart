import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../media/media_providers.dart';
import 'domain/compression_engine.dart';

final compressionEngineProvider = Provider<CompressionEngine>((ref) {
  return CompressionEngine(platform: ref.watch(mediaPlatformProvider));
});
