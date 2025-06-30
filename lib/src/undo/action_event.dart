import '../data_store.dart';

class KiwiActionPatch {
  final Map<String, String> updates;
  final List<String> deletions;

  KiwiActionPatch({required this.updates, required this.deletions});

  applyPatch(KiwiWatermelonDataStore store) {
    //todo
  }
}

class KiwiActionEvent {
  final int id;
  final KiwiActionPatch redo;
  final KiwiActionPatch undo;

  KiwiActionEvent({required this.id, required this.redo, required this.undo});
}
