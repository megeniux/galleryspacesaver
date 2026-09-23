/// Formats a byte count into a compact, human-readable string.
String formatBytes(int bytes, {int decimals = 1}) {
  if (bytes < 0) return '0 B';
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes / 1024;
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  final fixed = value >= 100 ? 0 : decimals;
  return '${value.toStringAsFixed(fixed)} ${units[unitIndex]}';
}

/// Formats a duration as `m:ss` or `h:mm:ss`.
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  final ss = seconds.toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$ss';
  }
  return '$minutes:$ss';
}

/// Returns the lowercase extension of [path] without the leading dot.
String fileExtension(String path) {
  final name = path.split(RegExp(r'[/\\]')).last;
  final dot = name.lastIndexOf('.');
  return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
}

/// Returns the file name portion of [path].
String fileName(String path) => path.split(RegExp(r'[/\\]')).last;
