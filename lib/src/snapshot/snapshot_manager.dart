import '../data_store.dart';

class KiwiWatermelonSnapshotManager {
  KiwiWatermelonDataStore store;
  final Map<String, Map<String, String>> snapshots = {};

  KiwiWatermelonSnapshotManager({required this.store});

  void save(String key) {
    snapshots.putIfAbsent(key, () => store.toUnmodifiableMap());
  }

  void restore(String key) {
    final restorable = snapshots[key];
    if (restorable != null) {
      store = KiwiWatermelonDataStore.fromMap(restorable);
    }
  }

  KiwiWatermelonDataStore getStore() {
    return store;
  }
}
