class QuickQueryMaker {
  final String prefix;

  QuickQueryMaker({required this.prefix});

  String setValue(String name, num value, num? start, num? end) {
    final String? starting = start == null ? null : " start $start";
    final String? ending = end == null ? null : " end $end";
    return "set $prefix:$name to $value;";
  }

  String incValue(String name, num value) {
    return "inc $prefix:$name $value;";
  }

  String decValue(String name, num value) {
    return "dec $prefix:$name $value;";
  }

  String clearValue(String name) {
    return "clear $prefix:$name;";
  }

  String setEnumValue(String name, String value) {
    return "set $prefix:$name $value;";
  }

  String listAppend(String name, String value) {
    return "list append $prefix:$name $value;";
  }

  String setAppend(String name, String value) {
    return "set append $prefix:$name $value;";
  }
}
