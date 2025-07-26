import 'dart:math';

import '../../kiwi_watermelon_store.dart';

class KiwiWatermelonRandom extends BaseGetTypedDataStore<String> {
  @override
  String? get(String key) {
    final [prefix, kind, min, max] = key.split(':');
    if (prefix != 'random' || kind != 'int') {
      return null;
    }
    final minValue = int.tryParse(min);
    final maxValue = int.tryParse(max);
    if (minValue == null || maxValue == null) {
      return null;
    }
    Random random = Random();
    final value = random.nextInt(maxValue - minValue + 1) + minValue;
    return '$value';
  }
}
