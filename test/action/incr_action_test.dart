import 'package:kiwi_watermelon_store/src/action/action_factory.dart';
import 'package:kiwi_watermelon_store/src/action/incr_action.dart';
import 'package:kiwi_watermelon_store/src/store/data_store.dart';
import 'package:kiwi_watermelon_store/src/store/mem_data_store.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';

void main() {
  group('KiwiWatermelonActionFactory integer operations', () {
    late BaseStringDataStore store;

    setUp(() {
      store = KiwiWatermelonDataStore(options: storeOptions);
    });

    test('incr on nonexistent key sets to 1', () {
      final result =
          KiwiWatermelonActionFactory.incr('env:counter').execute(store);
      expect(result.error, isNull);
      expect(result.patch?.updates['env:counter'], '1');
    });

    test('incr on existing integer', () {
      store.set('env:counter', '3');
      final result =
          KiwiWatermelonActionFactory.incr('env:counter').execute(store);
      expect(result.patch?.updates['env:counter'], '4');
    });

    test('decr on existing integer', () {
      store.set('env:counter', '3');
      final result =
          KiwiWatermelonActionFactory.decr('env:counter').execute(store);
      expect(result.patch?.updates['env:counter'], '2');
    });

    test('incrBy with positive value', () {
      store.set('env:views', '10');
      final result =
          KiwiWatermelonActionFactory.incrBy('env:views', 5).execute(store);
      expect(result.patch?.updates['env:views'], '15');
    });

    test('decrBy with positive value', () {
      store.set('env:views', '10');
      final result =
          KiwiWatermelonActionFactory.decrBy('env:views', 4).execute(store);
      expect(result.patch?.updates['env:views'], '6');
    });

    test('incr on invalid integer fails', () {
      store.set('env:x', 'abc');
      final result = KiwiWatermelonActionFactory.incr('env:x').execute(store);
      expect(result.error, isNotNull);
      expect(result.patch, isNull);
    });

    test('integer overflow fails', () {
      store.set('env:x', IntegerMutationAction.maxInt.toString());
      final result = KiwiWatermelonActionFactory.incr('env:x').execute(store);
      expect(result.error, isNotNull);
    });
    test('integer negative overflow fails', () {
      store.set('env:x', IntegerMutationAction.minInt.toString());
      final result = KiwiWatermelonActionFactory.decr('env:x').execute(store);
      expect(result.error, isNotNull);
      expect(result.error!.message, contains('overflow'));
    });
  });

  group('KiwiWatermelonActionFactory float operations', () {
    late BaseStringDataStore store;

    setUp(() {
      store = KiwiWatermelonDataStore(options: storeOptions);
    });

    test('incrByFloat on nonexistent key sets to value', () {
      final result = KiwiWatermelonActionFactory.incrByFloat('env:balance', 1.5)
          .execute(store);
      expect(result.error, isNull);
      expect(result.patch?.updates['env:balance'], '1.5');
    });

    test('incrByFloat on existing float', () {
      store.set('env:balance', '2.5');
      final result =
          KiwiWatermelonActionFactory.incrByFloat('env:balance', 1.25)
              .execute(store);
      expect(result.patch?.updates['env:balance'], '3.75');
    });

    test('decrByFloat on existing float', () {
      store.set('env:balance', '5.0');
      final result = KiwiWatermelonActionFactory.decrByFloat('env:balance', 2.0)
          .execute(store);
      expect(result.patch?.updates['env:balance'], '3.0');
    });

    test('incrByFloat on invalid float fails', () {
      store.set('env:x', 'hello');
      final result =
          KiwiWatermelonActionFactory.incrByFloat('env:x', 1.0).execute(store);
      expect(result.error, isNotNull);
    });

    test('float overflow (Infinity) fails', () {
      store.set('env:x', double.maxFinite.toString());
      final result =
          KiwiWatermelonActionFactory.incrByFloat('env:x', double.maxFinite)
              .execute(store);
      expect(result.error, isNotNull);
    });
  });
}
