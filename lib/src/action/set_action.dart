import '../data_store.dart';
import 'action_event.dart';
import 'action_result.dart';
import 'base_action.dart';

class KiwiSetAction extends KiwiWatermelonAction {
  final String key;

  final num value;

  KiwiSetAction({required this.key, required this.value});

  @override
  KiwiWatermelonActionResult execute(KiwiWatermelonDataStore store) {
    final previousValue = store.get(key);
    final undo = previousValue == null
        ? KiwiActionPatch(updates: {}, deletions: [key])
        : KiwiActionPatch(
            updates: {}.putIfAbsent(key, () => value.toString()),
            deletions: []);
    store.set(key, value.toString());
    final KiwiActionEvent event = KiwiActionEvent(
        redo: KiwiActionPatch(updates: {key: value.toString()}, deletions: []),
        undo: undo);
    return new KiwiWatermelonActionResult(event: event);
  }
}
