import '../../kiwi_watermelon_store.dart';
import 'action_patch.dart';
import 'action_result.dart';
import 'base_action.dart';

/// Matches `key` against a glob-like pattern (e.g., `env:color:*:site:*`).
/// Only `*` is supported and treated as a wildcard for any substring.
bool matchesPattern(String key, String pattern) {
  final parts = pattern.split('*');
  int index = 0;

  for (final part in parts) {
    if (part.isEmpty) continue;
    index = key.indexOf(part, index);
    if (index == -1) return false;
    index += part.length;
  }

  return true;
}

/// Deletes all keys from the data store (flushes the database).
class KiwiFlushDbAction extends KiwiWatermelonAction {
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final allKeys = store.keys.toList();

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {},
        deletions: allKeys,
      ),
    );
  }
}

/// Deletes all keys that match at least one of the provided glob-style [patterns].
///
/// Only `*` is supported as a wildcard. Patterns must match the full key.
class KiwiDelKeysAction extends KiwiWatermelonAction {
  final List<String> patterns;

  /// Constructs a [KiwiDelKeysAction] with a list of glob patterns.
  KiwiDelKeysAction({required this.patterns});

  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final keysToDelete = <String>[];

    for (final key in store.keys) {
      for (final pattern in patterns) {
        if (matchesPattern(key, pattern)) {
          keysToDelete.add(key);
          break;
        }
      }
    }

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {},
        deletions: keysToDelete,
      ),
    );
  }
}
