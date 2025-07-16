import '../../kiwi_watermelon_store.dart';
import 'action_patch.dart';
import 'action_result.dart';
import 'base_action.dart';

/// Implements the Redis `RENAME` operation.
/// Renames [oldKey] to [newKey], overwriting the new key if it exists.
class KiwiRenameAction extends KiwiWatermelonAction {
  final String oldKey;
  final String newKey;

  /// Constructs a [KiwiRenameAction] to rename [oldKey] to [newKey].
  KiwiRenameAction({
    required this.oldKey,
    required this.newKey,
  });

  /// Executes the RENAME operation.
  ///
  /// If the source key does not exist, this is a no-op.
  /// If the destination exists, it will be overwritten.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final value = store.get(oldKey);
    if (value == null) {
      return KiwiWatermelonActionResult(
        patch: KiwiWatermelonPatch(updates: {}, deletions: []),
      );
    }

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {newKey: value},
        deletions: [oldKey],
      ),
    );
  }
}

/// Implements the Redis `RENAMENX` operation.
/// Renames [oldKey] to [newKey] only if [newKey] does not already exist.
class KiwiRenameNXAction extends KiwiWatermelonAction {
  final String oldKey;
  final String newKey;

  /// Constructs a [KiwiRenameNXAction] to rename [oldKey] to [newKey]
  /// only if [newKey] does not exist.
  KiwiRenameNXAction({
    required this.oldKey,
    required this.newKey,
  });

  /// Executes the RENAMENX operation.
  ///
  /// If the source key does not exist, or if the destination already exists,
  /// this is a no-op.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final value = store.get(oldKey);
    if (value == null || store.get(newKey) != null) {
      return KiwiWatermelonActionResult(
        patch: KiwiWatermelonPatch(updates: {}, deletions: []),
      );
    }

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {newKey: value},
        deletions: [oldKey],
      ),
    );
  }
}
