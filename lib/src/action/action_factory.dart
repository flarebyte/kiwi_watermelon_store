import 'incr_action.dart';
import 'set_action.dart';

/// Factory for constructing Redis-style numeric mutation actions.
///
/// All methods return instances of [KiwiWatermelonAction] for use in
/// command execution flows.
///
/// Example:
/// ```dart
/// final action = KiwiWatermelonActionFactory.incrBy("counter", 5);
/// final result = action.execute(store);
/// ```
class KiwiWatermelonActionFactory {
  /// Returns an action to increment the value at [key] by 1.
  static KiwiIncrAction incr(String key) {
    return KiwiIncrAction(key);
  }

  /// Returns an action to decrement the value at [key] by 1.
  static KiwiDecrAction decr(String key) {
    return KiwiDecrAction(key);
  }

  /// Returns an action to increment the value at [key] by [value].
  static KiwiIncrByAction incrBy(String key, int value) {
    return KiwiIncrByAction(key, value);
  }

  /// Returns an action to decrement the value at [key] by [value].
  static KiwiDecrByAction decrBy(String key, int value) {
    return KiwiDecrByAction(key, value);
  }

  /// Returns an action to increment the float value at [key] by [value].
  static KiwiIncrByFloatAction incrByFloat(String key, double value) {
    return KiwiIncrByFloatAction(key, value);
  }

  /// Returns an action to decrement the float value at [key] by [value].
  static KiwiDecrByFloatAction decrByFloat(String key, double value) {
    return KiwiDecrByFloatAction(key, value);
  }

  /// Returns an action to set the int value at [key] to [value].
  static KiwiSetIntegerAction setInteger(String key, int value) {
    return KiwiSetIntegerAction(key, value);
  }

  /// Returns an action to set the double value at [key] to [value].
  static KiwiSetFloatAction setDouble(String key, double value) {
    return KiwiSetFloatAction(key, value);
  }

  /// Returns an action to set the UUID value at [key] to [value].
  static KiwiSetUuidAction setUuid(String key, String value,
      {bool validate = true}) {
    return KiwiSetUuidAction(key, value, validate: validate);
  }
}
