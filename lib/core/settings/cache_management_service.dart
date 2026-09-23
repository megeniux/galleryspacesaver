import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Removes only directories created by the compression engine.
class CacheManagementService {
  Future<int> clearCompressionCache() async {
    final root = await getTemporaryDirectory();
    final candidates = <FileSystemEntity>[];
    final output = Directory('${root.path}${Platform.pathSeparator}rigel_outputs');
    if (await output.exists()) candidates.add(output);
    await for (final entity in root.list(followLinks: false)) {
      final name = entity.uri.pathSegments.isEmpty ? '' : entity.uri.pathSegments.last;
      if (entity is Directory && name.startsWith('rigel_compression_')) {
        candidates.add(entity);
      }
    }
    var removed = 0;
    for (final candidate in candidates) {
      try {
        await candidate.delete(recursive: true);
        removed++;
      } on FileSystemException {
        // A locked temporary file can be cleaned on the next launch.
      }
    }
    return removed;
  }
}
