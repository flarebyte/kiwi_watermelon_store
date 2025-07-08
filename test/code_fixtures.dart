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

}
