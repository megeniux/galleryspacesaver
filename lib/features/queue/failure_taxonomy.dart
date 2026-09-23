enum FailureCode { outOfMemory, unsupportedCodec, noStorage, permissionRevoked, thermal, corruptInput, cancelled, unknown }

FailureCode classifyFailure(String? message) {
  final value = (message ?? '').toLowerCase();
  if (value.contains('memory') || value.contains('oom')) return FailureCode.outOfMemory;
  if (value.contains('codec') || value.contains('encoder') || value.contains('format')) return FailureCode.unsupportedCodec;
  if (value.contains('space') || value.contains('storage') || value.contains('no such file')) return FailureCode.noStorage;
  if (value.contains('permission') || value.contains('denied')) return FailureCode.permissionRevoked;
  if (value.contains('thermal') || value.contains('hot')) return FailureCode.thermal;
  if (value.contains('decode') || value.contains('corrupt') || value.contains('probe')) return FailureCode.corruptInput;
  if (value.contains('cancel')) return FailureCode.cancelled;
  return FailureCode.unknown;
}
