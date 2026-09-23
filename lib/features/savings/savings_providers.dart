import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../media/media_providers.dart';

final savingsSessionsProvider = StreamProvider((ref) {
  return ref.watch(mediaDatabaseProvider).watchSavingsSessions();
});
