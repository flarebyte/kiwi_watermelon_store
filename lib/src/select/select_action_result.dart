
class KiwiWatermelonSelectActionError {
  final String message;
  final List<String> keys;

  KiwiWatermelonSelectActionError({required this.message, required this.keys});
}

class KiwiWatermelonSelectActionResult<T> {
  final T? value;
  final KiwiWatermelonSelectActionError? error;

  KiwiWatermelonSelectActionResult({this.value, this.error});
}
