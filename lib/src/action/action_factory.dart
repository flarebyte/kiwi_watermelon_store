import '../store/manager_options.dart';
import 'del_action.dart';
import 'incr_action.dart';
import 'key_action.dart';
import 'list_action.dart';
import 'set_action.dart';
import 'sets_action.dart';

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

  /// Returns an action to set the UUID value at [key] to [value].
  static KiwiSetEnumAction setEnum(String key, String value,
      {required KiwiWatermelonOptions options, bool validate = true}) {
    return KiwiSetEnumAction(key, value, options: options, validate: validate);
  }

  /// Returns an action to prepend [values] to the beginning of the list at [key].
  static LPushAction lpush(String key, List<String> values,
      {required String separator}) {
    return LPushAction(key: key, values: values, separator: separator);
  }

  /// Returns an action to append [values] to the end of the list at [key].
  static KiwiRPushAction rpush(String key, List<String> values,
      {required String separator}) {
    return KiwiRPushAction(key: key, values: values, separator: separator);
  }

  /// Returns an action to remove [value] from the list at [key] [count] times.
  ///
  /// If [count] > 0, removes from head; if < 0, from tail; if 0, removes all.
  static KiwiLRemAction lrem(String key, int count, String value,
      {required String separator}) {
    return KiwiLRemAction(
        key: key, count: count, value: value, separator: separator);
  }

  /// Returns an action to trim the list at [key] to the range [[start], [stop]] (inclusive).
  static KiwiLTrimAction ltrim(String key, int start, int stop,
      {required String separator}) {
    return KiwiLTrimAction(
        key: key, start: start, stop: stop, separator: separator);
  }

  /// Returns an action to pop the last element from [source] and push it to the front of [destination].
  static KiwiRPopLPushAction rpoplpush(String source, String destination,
      {required String separator}) {
    return KiwiRPopLPushAction(
        source: source, destination: destination, separator: separator);
  }

  /// Returns an action to move an element from [source] to [destination],
  /// using direction [from] in source and [to] in destination.
  ///
  /// [from] and [to] must be either `"LEFT"` or `"RIGHT"` (case insensitive).
  static KiwiLMoveAction lmove(
    String source,
    String destination,
    String from,
    String to, {
    required String separator,
  }) {
    return KiwiLMoveAction(
      source: source,
      destination: destination,
      from: from,
      to: to,
      separator: separator,
    );
  }

  /// Returns an action to add one or more [members] to the set at [key].
  /// If the key does not exist, it will be created.
  ///
  /// Example:
  /// ```dart
  /// KiwiWatermelonActionFactory.sadd('env:tags', ['a', 'b'], separator: ',');
  /// ```
  static KiwiSAddAction sadd(String key, List<String> members,
      {required String separator}) {
    return KiwiSAddAction(
      key: key,
      members: members,
      separator: separator,
    );
  }

  /// Returns an action to remove one or more [members] from the set at [key].
  /// Members not present in the set are ignored.
  ///
  /// Example:
  /// ```dart
  /// KiwiWatermelonActionFactory.srem('env:tags', ['a'], separator: ',');
  /// ```
  static KiwiSRemAction srem(String key, List<String> members,
      {required String separator}) {
    return KiwiSRemAction(
      key: key,
      members: members,
      separator: separator,
    );
  }

  /// Returns an action to move [member] from the [source] set to the [destination] set.
  /// If the member is not in the source set, this is a no-op.
  ///
  /// Example:
  /// ```dart
  /// KiwiWatermelonActionFactory.smove('env:src', 'env:dst', 'x', separator: ',');
  /// ```
  static KiwiSMoveAction smove(String source, String destination, String member,
      {required String separator}) {
    return KiwiSMoveAction(
      source: source,
      destination: destination,
      member: member,
      separator: separator,
    );
  }

  /// Returns an action to rename [oldKey] to [newKey], overwriting if it exists.
  ///
  /// Example:
  /// ```dart
  /// KiwiWatermelonActionFactory.rename('env:k1', 'env:k2');
  /// ```
  static KiwiRenameAction rename(String oldKey, String newKey) {
    return KiwiRenameAction(oldKey: oldKey, newKey: newKey);
  }

  /// Returns an action to rename [oldKey] to [newKey] only if [newKey] does not exist.
  ///
  /// Example:
  /// ```dart
  /// KiwiWatermelonActionFactory.renamenx('env:k1', 'env:k2');
  /// ```
  static KiwiRenameNXAction renamenx(String oldKey, String newKey) {
    return KiwiRenameNXAction(oldKey: oldKey, newKey: newKey);
  }

  /// Returns an action to delete all keys from the store.
  static KiwiFlushDbAction flushDb() {
    return KiwiFlushDbAction();
  }

  /// Returns an action to delete all keys that match any of the given [patterns].
  ///
  /// Only `*` is supported as a wildcard in patterns.
  ///
  /// Example:
  /// ```dart
  /// KiwiWatermelonActionFactory.delKeys(['env:color:*', 'env:shape:*']);
  /// ```
  static KiwiDelKeysAction delKeys(List<String> patterns) {
    return KiwiDelKeysAction(patterns: patterns);
  }
}
