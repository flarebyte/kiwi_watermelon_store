import '../autorisation/autorisation_manager.dart';
import '../autorisation/capability.dart';

/// Provides authorization checks for various data operations.
class KiwiWatermelonActionAccess {
  late KiwiWatermelonAutorisationManager autorisation;

  final List<KiwiWatermelonDataCapability> capabilities;

  KiwiWatermelonActionAccess({required this.capabilities}) {
    autorisation =
        KiwiWatermelonAutorisationManager(capabilities: capabilities);
  }

  /// Returns `true` if [role] can increment the value at [key].
  bool incr(String key, {String role = 'none'}) {
    return autorisation.canReadAndWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can decrement the value at [key].
  bool decr(String key, {String role = 'none'}) {
    return autorisation.canReadAndWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can increment the value at [key] by an integer.
  bool incrBy(String key, {String role = 'none'}) {
    return autorisation.canReadAndWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can decrement the value at [key] by an integer.
  bool decrBy(String key, {String role = 'none'}) {
    return autorisation.canReadAndWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can increment the float value at [key].
  bool incrByFloat(String key, {String role = 'none'}) {
    return autorisation.canReadAndWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can decrement the float value at [key].
  bool decrByFloat(String key, {String role = 'none'}) {
    return autorisation.canReadAndWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can set an integer at [key].
  bool setInteger(String key, {String role = 'none'}) {
    return autorisation.canWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can set a double at [key].
  bool setDouble(String key, {String role = 'none'}) {
    return autorisation.canWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can set a UUID at [key].
  bool setUuid(String key, {String role = 'none'}) {
    return autorisation.canWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can set an enum at [key].
  bool setEnum(String key, {String role = 'none'}) {
    return autorisation.canWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can modify the head of the list at [key].
  bool lpush(String key, {String role = 'none'}) {
    return autorisation.canWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can modify the tail of the list at [key].
  bool rpush(String key, {String role = 'none'}) {
    return autorisation.canWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can remove an element from the list at [key].
  bool lrem(String key, {String role = 'none'}) {
    return autorisation.canWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can trim the list at [key].
  bool ltrim(String key, {String role = 'none'}) {
    return autorisation.canWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can pop from [source] and push to [destination].
  bool rpoplpush(String source, String destination, {String role = 'none'}) {
    return autorisation.canReadAndWrite(role: role, key: source) &&
        autorisation.canReadAndWrite(role: role, key: destination);
  }

  /// Returns `true` if [role] can move an element from [source] to [destination].
  bool lmove(String source, String destination, {String role = 'none'}) {
    return autorisation.canReadAndWrite(role: role, key: source) &&
        autorisation.canReadAndWrite(role: role, key: destination);
  }

  /// Returns `true` if [role] can add to the set at [key].
  bool sadd(String key, {String role = 'none'}) {
    return autorisation.canWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can remove from the set at [key].
  bool srem(String key, {String role = 'none'}) {
    return autorisation.canWrite(key: key, role: role);
  }

  /// Returns `true` if [role] can move [member] from [source] to [destination].
  bool smove(String source, String destination, {String role = 'none'}) {
    return autorisation.canReadAndWrite(role: role, key: source) &&
        autorisation.canReadAndWrite(role: role, key: destination);
  }

  /// Returns `true` if [role] can rename [oldKey] to [newKey].
  bool rename(String oldKey, String newKey, {String role = 'none'}) {
    return autorisation.canReadAndWrite(role: role, key: oldKey) &&
        autorisation.canWrite(role: role, key: newKey);
  }

  /// Returns `true` if [role] can rename [oldKey] to [newKey] only if [newKey] does not exist.
  bool renamenx(String oldKey, String newKey, {String role = 'none'}) {
    return autorisation.canReadAndWrite(role: role, key: oldKey) &&
        autorisation.canWrite(role: role, key: newKey);
  }

  /// Returns `true` if [role] can flush the entire DB.
  bool flushDb({String role = 'none'}) {
    // DB-level operations might be guarded by a specific key prefix
    return autorisation.canDelete(role: role, key: '__root__');
  }

  /// Returns `true` if [role] can delete keys by pattern.
  bool delKeys({String role = 'none'}) {
    return autorisation.canDelete(role: role, key: '__pattern__');
  }

  /// Returns `true` if [role] can delete [key].
  bool del(List<String> keys, {String role = 'none'}) {
    return keys.every((key) => autorisation.canDelete(role: role, key: key));
  }
}
