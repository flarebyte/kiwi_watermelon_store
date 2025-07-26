class KiwiWatermelonSelectActionError {
  final String message;
  final String code;

  KiwiWatermelonSelectActionError({required this.message, required this.code});
}

class KiwiWatermelonSelectActionResult<T> {
  final T? value;
  final KiwiWatermelonSelectActionError? error;

  KiwiWatermelonSelectActionResult({this.value, this.error});
}
