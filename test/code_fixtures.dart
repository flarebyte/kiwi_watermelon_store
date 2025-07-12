import 'dart:math';

import 'package:kiwi_watermelon_store/src/store/manager_options.dart';

typedef RedisValue = Object; // convention: int, double, or Uuid

class QuickQueryMaker {
  final String prefix;

  QuickQueryMaker({required this.prefix});

  bool _isUuid(String input) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-'
      r'[0-9a-fA-F]{4}-'
      r'[1-5][0-9a-fA-F]{3}-'
      r'[89abAB][0-9a-fA-F]{3}-'
      r'[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(input);
  }

  bool _isValidRedisValue(Object value) {
    return value is int || value is double || _isUuid(value.toString());
  }

  void _validateRedisValues(List<RedisValue> values) {
    for (final value in values) {
      assert(_isValidRedisValue(value),
          'Unsupported Redis value type: ${value.runtimeType} for $value');
    }
  }

  /** Let's try to be compatible with a subset of Redis commands */
  String setNum(String name, num value) {
    return "SET $prefix:$name $value";
  }

  String setEnum(String name, String value) {
    return "SET $prefix:$name $value";
  }

  String setUUID(String name, String value) {
    return "SET $prefix:$name $value";
  }

  String incrBy(String name, int value) {
    return "INCRBY $prefix:$name $value";
  }

  String incr(String name) {
    return "INCR $prefix:$name";
  }

  String decr(String name) {
    return "DECR $prefix:$name";
  }

  String decrBY(String name, int value) {
    return "DECRBY $prefix:$name $value;";
  }

  String del(List<String> keys) {
    final values = keys.map((key) => "$prefix:$key").join(' ');
    return "DEL $values";
  }

// List Commands
  String lpush(String name, List<RedisValue> values) {
    _validateRedisValues(values);
    final joined = values.join(' ');
    return 'LPUSH $prefix:$name $joined';
  }

  String rpush(String name, List<RedisValue> values) {
    _validateRedisValues(values);
    final joined = values.join(' ');
    return 'RPUSH $prefix:$name $joined';
  }

  String lrem(String name, int count, RedisValue value) {
    assert(_isValidRedisValue(value),
        'Unsupported Redis value type: ${value.runtimeType}');
    return 'LREM $prefix:$name $count $value';
  }

  String ltrim(String name, int start, int stop) {
    return 'LTRIM $prefix:$name $start $stop';
  }

  String rpoplpush(String source, String destination) {
    return 'RPOPLPUSH $prefix:$source $prefix:$destination';
  }

  String lmove(String source, String destination, String from, String to) {
    return 'LMOVE $prefix:$source $prefix:$destination $from $to';
  }

  // Set commands

  String sadd(String name, List<RedisValue> members) {
    _validateRedisValues(members);
    final joined = members.join(' ');
    return 'SADD $prefix:$name $joined';
  }

  String srem(String name, List<RedisValue> members) {
    _validateRedisValues(members);
    final joined = members.join(' ');
    return 'SREM $prefix:$name $joined';
  }

  String smove(String source, String destination, RedisValue member) {
    assert(_isValidRedisValue(member),
        'Unsupported Redis value type: ${member.runtimeType}');
    return 'SMOVE $prefix:$source $prefix:$destination $member';
  }

  // Keys command

  String rename(String oldKey, String newKey) {
    return 'RENAME $prefix:$oldKey $prefix:$newKey';
  }

  String renamenx(String oldKey, String newKey) {
    return 'RENAMENX $prefix:$oldKey $prefix:$newKey';
  }

  String flushDb() {
    return 'FLUSHDB';
  }
  // Not Redis-like

  // Delete keys that matches patterns like
  String delKeys(String name, List<String> patterns) {
    final list = patterns.join(" ");
    return "DELKEYS $list";
  }
}

class SimpleUuid {
  static final Random _random = Random();

  /// Generates a random UUID (version 4-like, not RFC-compliant).
  /// Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  static String v4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

    // Set version to 4 (0100xxxx)
    bytes[6] = (bytes[6] & 0x0F) | 0x40;

    // Set variant to DCE 1.1 (10xxxxxx)
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    String _byteToHex(int byte) => byte.toRadixString(16).padLeft(2, '0');

    final hex = bytes.map(_byteToHex).join();

    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20, 32),
    ].join('-');
  }
}

uuid() {
  return SimpleUuid.v4();
}

final maker =
    QuickQueryMaker(prefix: 'env'); // scope can be 'env', 'user', etc.

final List<String> validCommands = [
  // SET commands
  maker.setNum('metrics:cpu:load', 0.75),
  maker.setEnum('settings:display:mode', 'dark'),
  maker.setUUID(
      'session:users:1234:token', 'b81cdae6-86d1-447f-811f-d23ab70e6d98'),
  maker.setUUID(
      'session:users:a__b:token', '12345678-1234-4234-8234-123456789012'),

  // INCR/DECR
  maker.incrBy('metrics:api:calls:version:2', 10),
  maker.incr('metrics:api:total:color:blue:status:ready'),
  maker.decr('metrics:cache:misses'),
  maker.decrBY('metrics:errors:timeout', 3),

  // DEL command
  maker.del(['temp:keys:1', 'temp:keys:2', 'temp:keys:3:version:2']),

  // List commands
  maker.lpush('queue:jobs:pending',
      [123, '75df7c47-4599-4cfb-8443-5f4546c743db', 42.5]),
  maker.rpush('queue:jobs:complete', [1, 2]),
  maker.lrem('queue:jobs:failed', 2, 'fead3654-abe1-4719-b89c-b837440ec16d'),
  maker.ltrim('queue:jobs:batch', 0, 9),
  maker.rpoplpush('queue:jobs:active', 'queue:jobs:retry'),
  maker.lmove('queue:one', 'queue:two', 'LEFT', 'RIGHT'),

  // Set commands
  maker.sadd('users:roles:admin', [
    '660cba17-a6f4-43d3-bf5f-ebc359c69e9c',
    '9a7256a7-5268-4fe3-b5fc-bf27a105a8ba'
  ]),
  maker.srem('users:roles:guest', [12345]),
  maker.smove('users:roles:temp', 'users:roles:active',
      'a15838ce-e8d8-4374-b862-b8fdf611fa5a'),

  // Key commands
  maker.rename('cache:a', 'cache:b'),
  maker.renamenx('tmp:a', 'tmp:b'),

  // Custom deletion (non-Redis)
  maker.delKeys('cache:views', ['cache:views:*', 'cache:users:*']),
];

final storeOptions = KiwiWatermelonOptions(
  mapping: {'true': 'T', 'false': 'F'},
  prefixes: ['env'],
  userPrefixes: ['env'],
  variableValidator: (String variableName) {
    // A valid variable name must start with a letter and may contain letters and digits.
    return RegExp(r'^[a-zA-Z][a-zA-Z0-9_:]*$').hasMatch(variableName);
  },
);
