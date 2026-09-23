import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../media/media_providers.dart';
import 'replace_original_service.dart';

final replaceOriginalServiceProvider = Provider<ReplaceOriginalService>((ref) {
  return ReplaceOriginalService(
    ref.watch(mediaDatabaseProvider),
    ref.watch(mediaPlatformProvider),
  );
});

final recycleBinProvider = StreamProvider((ref) {
  return ref.watch(mediaDatabaseProvider).watchRecycleBin();
});
