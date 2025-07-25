import 'package:kiwi_watermelon_store/src/action/action_factory.dart';
import 'package:kiwi_watermelon_store/src/store/data_store.dart';
import 'package:kiwi_watermelon_store/src/store/mem_data_store.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';

void main() {
  group('KiwiWatermelonActionFactory key operations', () {
    late BaseStringDataStore store;

    setUp(() {
      store = KiwiWatermelonDataStore(options: storeOptions);
    });

    test('rename should move value from old key to new key', () {
      store.set('env:old', 'value');
      final result = KiwiWatermelonActionFactory.rename('env:old', 'env:new')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:new'], equals('value'));
      expect(result.patch?.deletions, contains('env:old'));
    });

    test('rename should overwrite existing destination key', () {
      store.set('env:old', 'a');
      store.set('env:new', 'b');
      final result = KiwiWatermelonActionFactory.rename('env:old', 'env:new')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:new'], equals('a'));
      expect(result.patch?.deletions, contains('env:old'));
    });

    ///
    test('renamenx should move value if destination does not exist', () {
      store.set('env:old', '123');
      final result = KiwiWatermelonActionFactory.renamenx('env:old', 'env:new')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:new'], equals('123'));
      expect(result.patch?.deletions, contains('env:old'));
    });

    test('renamenx should do nothing if destination key exists', () {
      store.set('env:old', 'foo');
      store.set('env:new', 'bar');
      final result = KiwiWatermelonActionFactory.renamenx('env:old', 'env:new')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates, isEmpty);
      expect(result.patch?.deletions, isEmpty);
    });

    test('renamenx should do nothing if source key does not exist', () {
      final result =
          KiwiWatermelonActionFactory.renamenx('env:missing', 'env:new')
              .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates, isEmpty);
      expect(result.patch?.deletions, isEmpty);
    });
  });
}
