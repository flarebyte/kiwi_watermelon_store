import 'package:kiwi_watermelon_store/src/action/action_factory.dart';
import 'package:kiwi_watermelon_store/src/store/data_store.dart';
import 'package:kiwi_watermelon_store/src/store/mem_data_store.dart';
import 'package:test/test.dart';

import '../code_fixtures.dart';

void main() {
  group('KiwiWatermelonActionFactory set operations', () {
    late BaseStringDataStore store;

    setUp(() {
      store = KiwiWatermelonDataStore(options: storeOptions);
    });

    test('sadd should add values to the set', () {
      store.set('env:myset', 'c,d');
      final result = KiwiWatermelonActionFactory.sadd('env:myset', ['a', 'b'],
              separator: ',')
          .execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:myset'], equals('c,d,a,b'));
    });
    test('sadd should add values to the set', () {
      store.set('env:myset', 'c,d');
      final result = KiwiWatermelonActionFactory.sadd(
        'env:myset',
        ['a', 'b'],
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:myset'], equals('c,d,a,b'));
    });

    test('sadd should ignore duplicate entries', () {
      store.set('env:dupeset', 'a,b');
      final result = KiwiWatermelonActionFactory.sadd(
        'env:dupeset',
        ['b', 'c'],
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:dupeset'], equals('a,b,c'));
    });

    test('sadd should create set if key is missing', () {
      final result = KiwiWatermelonActionFactory.sadd(
        'env:newset',
        ['x', 'y'],
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:newset'], equals('x,y'));
    });
    //
    test('srem should remove values from the set', () {
      store.set('env:myset', 'a,b,c');
      final result = KiwiWatermelonActionFactory.srem(
        'env:myset',
        ['b'],
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:myset'], equals('a,c'));
    });

    test('srem should ignore non-existing members', () {
      store.set('env:myset', 'a,b');
      final result = KiwiWatermelonActionFactory.srem(
        'env:myset',
        ['z'],
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:myset'], equals('a,b'));
    });

    test('srem on non-existent key should be a no-op', () {
      final result = KiwiWatermelonActionFactory.srem(
        'env:missing',
        ['a'],
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:missing'], equals(''));
    });
//
    test('smove should move member from source to destination', () {
      store.set('env:srcset', 'a,b');
      store.set('env:dstset', 'x,y');
      final result = KiwiWatermelonActionFactory.smove(
        'env:srcset',
        'env:dstset',
        'b',
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:srcset'], equals('a'));
      expect(result.patch?.updates['env:dstset'], equals('x,y,b'));
    });

    test('smove should do nothing if member not in source', () {
      store.set('env:src', 'a,b');
      store.set('env:dst', 'x');

      final result = KiwiWatermelonActionFactory.smove(
        'env:src',
        'env:dst',
        'z',
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates, isEmpty);
    });

    test('smove should work when source equals destination', () {
      store.set('env:selfset', 'a,b,c');
      final result = KiwiWatermelonActionFactory.smove(
        'env:selfset',
        'env:selfset',
        'a',
        separator: ',',
      ).execute(store);

      expect(result.error, isNull);
      expect(result.patch?.updates['env:selfset'], equals('b,c,a'));
    });
  });
}
