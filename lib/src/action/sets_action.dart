import '../../kiwi_watermelon_store.dart';
import 'action_patch.dart';
import 'action_result.dart';
import 'base_action.dart';

/// Base class for Redis-style Set operations where sets are stored
/// as strings with elements separated by a custom separator.
///
/// All operations treat missing keys as empty sets.
abstract class KiwiSetAction extends KiwiWatermelonAction {
  /// Separator used to encode/decode set values.
  final String separator;

  /// Constructs a [KiwiSetAction] with the given [separator].
  KiwiSetAction({required this.separator});

  /// Decodes a string from the data store into a `Set<String>`.
  ///
  /// Returns an empty set if the input is null or blank.
  Set<String> parseSet(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    return raw.split(separator).toSet();
  }

  /// Encodes a `Set<String>` into a string using the configured [separator].
  ///
  /// Returns an empty string if the set is empty.
  String serializeSet(Set<String> items) {
    return items.join(separator);
  }
}

/// Implements the Redis `SADD` operation.
/// Adds one or more members to the set at [key].
///
/// If the key does not exist, it will be created.
/// Duplicates are ignored.
class KiwiSAddAction extends KiwiSetAction {
  /// Key for the target set.
  final String key;

  /// List of members to add to the set.
  final List<String> members;

  /// Constructs a [KiwiSAddAction] for a given [key], [separator], and [members].
  KiwiSAddAction({
    required this.key,
    required String separator,
    required this.members,
  }) : super(separator: separator);

  /// Executes the SADD operation.
  ///
  /// Returns a [KiwiWatermelonPatch] with the updated set value.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final set = parseSet(store.get(key));
    set.addAll(members);

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {key: serializeSet(set)},
        deletions: [],
      ),
    );
  }
}

/// Implements the Redis `SREM` operation.
/// Removes one or more members from the set at [key].
///
/// If the key does not exist, this is a no-op.
/// Members not present in the set are ignored.
class KiwiSRemAction extends KiwiSetAction {
  /// Key for the target set.
  final String key;

  /// List of members to remove from the set.
  final List<String> members;

  /// Constructs a [KiwiSRemAction] with the given [key], [separator], and [members].
  KiwiSRemAction({
    required this.key,
    required String separator,
    required this.members,
  }) : super(separator: separator);

  /// Executes the SREM operation.
  ///
  /// Returns a [KiwiWatermelonPatch] with the updated set value.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final set = parseSet(store.get(key));
    set.removeAll(members);

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {key: serializeSet(set)},
        deletions: [],
      ),
    );
  }
}

/// Implements the Redis `SMOVE` operation.
/// Moves a member from the [source] set to the [destination] set.
///
/// If the member does not exist in the source set, this is a no-op.
/// If [source] and [destination] are the same, the operation is still safe.
class KiwiSMoveAction extends KiwiSetAction {
  /// Key for the source set.
  final String source;

  /// Key for the destination set.
  final String destination;

  /// The member to move from source to destination.
  final String member;

  /// Constructs a [KiwiSMoveAction] with source, destination, member, and separator.
  KiwiSMoveAction({
    required this.source,
    required this.destination,
    required this.member,
    required String separator,
  }) : super(separator: separator);

  /// Executes the SMOVE operation.
  ///
  /// Returns a [KiwiWatermelonPatch] updating source and destination sets.
  /// If the member is not found in the source, returns a no-op result.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final sourceSet = parseSet(store.get(source));
    if (!sourceSet.remove(member)) {
      return KiwiWatermelonActionResult(
        patch: KiwiWatermelonPatch(updates: {}, deletions: []),
      );
    }

    final destSet =
        (source == destination) ? sourceSet : parseSet(store.get(destination));

    destSet.add(member);

    final updates = <String, String>{
      source: serializeSet(sourceSet),
    };

    if (source != destination) {
      updates[destination] = serializeSet(destSet);
    } else {
      updates[source] = serializeSet(destSet);
    }

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(updates: updates, deletions: []),
    );
  }
}
