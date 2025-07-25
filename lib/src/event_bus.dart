import 'dart:async';

import '../kiwi_watermelon_store.dart';
import 'action/action_patch.dart';

enum KiwiWatermelonEventType {
  update,
  restore,
}

class KiwiWatermelonEvent {
  final KiwiWatermelonPatch? patch;
  final BaseReadTypedDataStore<String> readStore;
  final KiwiWatermelonEventType eventType;

  KiwiWatermelonEvent({this.patch, required this.readStore, required this.eventType});
}

class PatchEventBus {
  final _controller = StreamController<KiwiWatermelonEvent>.broadcast();

  void publish(KiwiWatermelonEvent event) => _controller.add(event);

  Stream<KiwiWatermelonEvent> get stream => _controller.stream;

  void dispose() => _controller.close();
}
