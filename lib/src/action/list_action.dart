import '../../kiwi_watermelon_store.dart';
import 'action_patch.dart';
import 'action_result.dart';
import 'base_action.dart';

/// An abstract base class for Redis-style list operations,
/// where lists are stored as plain strings separated by a custom separator.
abstract class KiwiListAction extends KiwiWatermelonAction {
  /// The string used to separate elements in the list (e.g., "," or "|").
  final String separator;

  /// Constructs a [KiwiListAction] with a list key and separator.
  KiwiListAction({required this.separator});

  /// Splits the raw string value from the data store into a list of strings.
  ///
  /// Returns an empty list if the input is null or empty.
  List<String> splitList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    return raw.split(separator);
  }

  /// Joins a list of strings into a single string using the configured separator.
  ///
  /// Returns an empty string if the list is empty.
  String joinList(List<String> items) {
    return items.join(separator);
  }
}

/// Implements the Redis `LPUSH` operation.
/// Prepends one or more values to the beginning of a string-separated list.
class LPushAction extends KiwiListAction {
  final String key;

  /// The values to insert at the beginning of the list.
  final List<String> values;

  /// Constructs an [LPushAction] for a given key, separator, and values.
  LPushAction({
    required String this.key,
    required String separator,
    required this.values,
  }) : super(separator: separator);

  /// Executes the LPUSH logic, updating the list in-place.
  ///
  /// Returns a [KiwiWatermelonPatch] containing the updated value.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final updatedList = [
      ...values.reversed,
      ...splitList(store.get(key)),
    ];

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {key: joinList(updatedList)},
        deletions: [],
      ),
    );
  }
}

/// Implements the Redis `RPUSH` operation.
/// Appends one or more values to the end of a string-separated list.
class KiwiRPushAction extends KiwiListAction {
  final String key;

  /// The values to append at the end of the list.
  final List<String> values;

  /// Constructs an [KiwiRPushAction] for a given key, separator, and values.
  KiwiRPushAction({
    required this.key,
    required String separator,
    required this.values,
  }) : super(separator: separator);

  /// Executes the RPUSH logic, updating the list in-place.
  ///
  /// Returns a [KiwiWatermelonPatch] containing the updated value.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final updatedList = [
      ...splitList(store.get(key)),
      ...values,
    ];
    final updatedValue = joinList(updatedList);

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {key: updatedValue},
        deletions: [],
      ),
    );
  }
}

/// Implements the Redis `LREM` operation.
/// Removes occurrences of a given value from a string-separated list.
class KiwiLRemAction extends KiwiListAction {
  final String key;

  /// Maximum number of elements to remove:
  /// - Positive = remove from head
  /// - Negative = remove from tail
  /// - Zero = remove all occurrences
  final int count;

  /// The value to remove from the list.
  final String value;

  /// Constructs an [KiwiLRemAction] for a given key, separator, count, and value.
  KiwiLRemAction({
    required this.key,
    required String separator,
    required this.count,
    required this.value,
  }) : super(separator: separator);

  /// Executes the LREM logic, updating the list in-place.
  ///
  /// Returns a [KiwiWatermelonPatch] containing the updated value.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final list = splitList(store.get(key));

    Iterable<String> updatedList;

    if (count == 0) {
      updatedList = list.where((e) => e != value);
    } else if (count > 0) {
      int removed = 0;
      updatedList = list.where((e) {
        final shouldRemove = e == value && removed < count;
        if (shouldRemove) removed++;
        return !shouldRemove;
      });
    } else {
      int removed = 0;
      final reversed = list.reversed;
      final filtered = reversed.where((e) {
        final shouldRemove = e == value && removed < -count;
        if (shouldRemove) removed++;
        return !shouldRemove;
      });
      updatedList = filtered.toList().reversed;
    }

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {key: joinList(updatedList.toList())},
        deletions: [],
      ),
    );
  }
}

/// Implements the Redis `LTRIM` operation.
/// Trims a string-separated list to only include elements in the specified range.
class KiwiLTrimAction extends KiwiListAction {
  final String key;

  /// Start index (inclusive) of the trim range.
  final int start;

  /// Stop index (inclusive) of the trim range.
  final int stop;

  /// Constructs an [KiwiLTrimAction] with a key, separator, start, and stop.
  KiwiLTrimAction({
    required this.key,
    required String separator,
    required this.start,
    required this.stop,
  }) : super(separator: separator);

  /// Executes the LTRIM logic, reducing the list to the specified range.
  ///
  /// Returns a [KiwiWatermelonPatch] containing the updated value.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final list = splitList(store.get(key));

    final safeStart = start.clamp(0, list.length - 1);
    final safeStop = stop.clamp(safeStart, list.length - 1);

    final trimmed = list.sublist(safeStart, safeStop + 1);

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {key: joinList(trimmed)},
        deletions: [],
      ),
    );
  }
}

/// Implements the Redis `RPOPLPUSH` operation.
/// Removes the last element from the source list and prepends it to the destination list.
class KiwiRPopLPushAction extends KiwiListAction {
  /// Source list key to pop from.
  final String source;

  /// Destination list key to push into.
  final String destination;

  /// Separator used for both lists.
  final String separator;

  /// Constructs an [KiwiRPopLPushAction] with source, destination, and separator.
  KiwiRPopLPushAction({
    required this.source,
    required this.destination,
    required this.separator,
  }) : super(separator: separator);

  /// Executes the RPOPLPUSH logic.
  ///
  /// If the source is empty, returns an error result.
  /// Otherwise, returns a [KiwiWatermelonPatch] with updates to both keys.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final sourceList = splitList(store.get(source));

    if (sourceList.isEmpty) {
      return KiwiWatermelonActionResult(
        error: KiwiWatermelonActionError(
          message: 'Source list is empty',
          keys: [source],
        ),
      );
    }

    final value = sourceList.removeLast();
    final updatedDest = [value, ...splitList(store.get(destination))];

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {
          source: joinList(sourceList),
          destination: joinList(updatedDest),
        },
        deletions: [],
      ),
    );
  }
}

/// Implements the Redis `LMOVE` operation.
/// Moves an element from one end of the source list to one end of the destination list.
class KiwiLMoveAction extends KiwiListAction {
  /// Source list key to remove the element from.
  final String source;

  /// Destination list key to insert the element into.
  final String destination;

  /// Direction from which to remove in the source list: "LEFT" or "RIGHT".
  final String from;

  /// Direction to insert in the destination list: "LEFT" or "RIGHT".
  final String to;

  /// Separator used for both lists.
  final String separator;

  /// Constructs an [KiwiLMoveAction] with source, destination, directions, and separator.
  KiwiLMoveAction({
    required this.source,
    required this.destination,
    required this.from,
    required this.to,
    required this.separator,
  }) : super(separator: separator);

  /// Executes the LMOVE logic.
  ///
  /// Returns a patch with updated values or an error if source is empty.
  @override
  KiwiWatermelonActionResult execute(BaseStringDataStore store) {
    final sourceList = splitList(store.get(source));
    if (sourceList.isEmpty) {
      return KiwiWatermelonActionResult(
        error: KiwiWatermelonActionError(
          message: 'Source list is empty',
          keys: [source],
        ),
      );
    }

    final isFromLeft = from.toUpperCase() == 'LEFT';
    final isToLeft = to.toUpperCase() == 'LEFT';

    final value = isFromLeft ? sourceList.removeAt(0) : sourceList.removeLast();

    final destinationList = splitList(store.get(destination));
    final updatedDest =
        isToLeft ? [value, ...destinationList] : [...destinationList, value];

    return KiwiWatermelonActionResult(
      patch: KiwiWatermelonPatch(
        updates: {
          source: joinList(sourceList),
          destination: joinList(updatedDest),
        },
        deletions: [],
      ),
    );
  }
}
