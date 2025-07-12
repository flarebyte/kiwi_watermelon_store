import 'action_patch.dart';

class KiwiWatermelonActionError {
  final String message;
  final List<String> keys;

  KiwiWatermelonActionError({required this.message, required this.keys});
}

class KiwiWatermelonActionResult {
  final KiwiWatermelonPatch? patch;
  final KiwiWatermelonActionError? error;

  KiwiWatermelonActionResult({this.patch, this.error});
}
