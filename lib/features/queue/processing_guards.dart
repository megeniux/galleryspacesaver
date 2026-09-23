import '../media/data/media_platform.dart';

class ProcessingGuards {
  const ProcessingGuards(this._platform);
  final MediaPlatform _platform;

  Future<GuardResult> check({required int upcomingBytes}) async {
    final status = await _platform.processingGuards();
    if ((status['batteryPercent'] as num? ?? 100) < 15 && status['charging'] != true) {
      return const GuardResult.blocked('Paused: battery is below 15%. Connect a charger to continue.');
    }
    if ((status['thermalStatus'] as num? ?? 0) >= 3) {
      return const GuardResult.blocked('Paused: device temperature is too high.');
    }
    final freeBytes = status['freeBytes'] as num?;
    if (freeBytes != null && freeBytes < upcomingBytes * 2) {
      return const GuardResult.blocked('Paused: not enough free storage for a safe temporary output.');
    }
    return const GuardResult.allowed();
  }
}

class GuardResult {
  const GuardResult.allowed() : message = null, isAllowed = true;
  const GuardResult.blocked(this.message) : isAllowed = false;
  final bool isAllowed;
  final String? message;
}
