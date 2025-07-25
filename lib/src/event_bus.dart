import 'dart:async';

import 'action/action_patch.dart';

class PatchEventBus {
  final _controller = StreamController<KiwiWatermelonPatch>.broadcast();

  void publish(KiwiWatermelonPatch event) => _controller.add(event);

  Stream<KiwiWatermelonPatch> get stream => _controller.stream;

  void dispose() => _controller.close();
}
