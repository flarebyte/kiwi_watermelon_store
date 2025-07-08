class QuickQueryMaker {
  final String prefix;

  QuickQueryMaker({required this.prefix});

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
  String lpush(String name, List<Object> values) {
    final joined = values.join(' ');
    return 'LPUSH $prefix:$name $joined';
  }

  String rpush(String name, List<Object> values) {
    final joined = values.join(' ');
    return 'RPUSH $prefix:$name $joined';
  }

  String lrem(String name, int count, Object value) {
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

  String sadd(String name, List<Object> members) {
    final joined = members.join(' ');
    return 'SADD $prefix:$name $joined';
  }

  String srem(String name, List<Object> members) {
    final joined = members.join(' ');
    return 'SREM $prefix:$name $joined';
  }

  String smove(String source, String destination, Object member) {
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
}
