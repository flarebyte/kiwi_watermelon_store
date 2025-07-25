import '../../kiwi_watermelon_store.dart';
import 'action_patch.dart';
import 'action_result.dart';
import 'base_action.dart';

/// Base class for all numeric mutation actions.
abstract class NumericMutationAction extends KiwiWatermelonAction {
  final String key;

  NumericMutationAction(this.key);

  /// Executes the mutation against [store].
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store);

  KiwiWatermelonActionResult error(String message) {
    return KiwiWatermelonActionResult(
      error: KiwiWatermelonActionError(message: message, keys: [key]),
    );
  }
}

/// Handles integer mutation semantics.
/// Delegates overflow detection and result computation.
abstract class IntegerMutationAction extends NumericMutationAction {
  final int by;

  IntegerMutationAction(String key, this.by) : super(key);

  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final raw = store.get(key) ?? '0';
    final current = int.tryParse(raw);

    if (current == null) {
      return error('Value at "$key" is not a valid integer.');
    }

    // Pre-check overflow bounds manually before addition
    if ((by > 0 && current > maxInt - by) ||
        (by < 0 && current < minInt - by)) {
      return error('Integer overflow at "$key".');
    }

    final result = current + by;

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {key: result.toString()},
        deletions: [],
      ),
    );
  }

  static const int maxInt = 9223372036854775807;
  static const int minInt = -9223372036854775808;
}

/// Handles float mutation semantics.
/// Ensures valid numeric format and checks for Infinity/NaN.
abstract class FloatMutationAction extends NumericMutationAction {
  final double by;

  FloatMutationAction(String key, this.by) : super(key);

  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final raw = store.get(key) ?? '0.0';
    final current = double.tryParse(raw);

    if (current == null) {
      return error('Value at "$key" is not a valid float.');
    }

    final result = current + by;

    if (result.isNaN || result.isInfinite) {
      return error('Float overflow or invalid value at "$key".');
    }

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {key: result.toString()},
        deletions: [],
      ),
    );
  }
}

/// INCR key by 1
class KiwiIncrAction extends IntegerMutationAction {
  KiwiIncrAction(String key) : super(key, 1);
}

/// DECR key by 1
class KiwiDecrAction extends IntegerMutationAction {
  KiwiDecrAction(String key) : super(key, -1);
}

/// INCRBY key by value
class KiwiIncrByAction extends IntegerMutationAction {
  KiwiIncrByAction(String key, int value) : super(key, value);
}

/// DECRBY key by value
class KiwiDecrByAction extends IntegerMutationAction {
  KiwiDecrByAction(String key, int value) : super(key, -value);
}

/// INCRBYFLOAT key by value
class KiwiIncrByFloatAction extends FloatMutationAction {
  KiwiIncrByFloatAction(String key, double value) : super(key, value);
}

/// DECRBYFLOAT key by value
class KiwiDecrByFloatAction extends FloatMutationAction {
  KiwiDecrByFloatAction(String key, double value) : super(key, -value);
}
