/// Represents a strictly accepted literal parsed from a command stream.
sealed class ParsedLiteral {
  const ParsedLiteral();

  /// Returns the string representation of the literal value.
  String get asString;

  T valueAs<T>() {
    if (this is ParsedInteger && T == int)
      return (this as ParsedInteger).value as T;
    if (this is ParsedFloat && T == double)
      return (this as ParsedFloat).value as T;
    if (this is ParsedUuid && T == String)
      return (this as ParsedUuid).value as T;
    if (this is ParsedEnum && T == String)
      return (this as ParsedEnum).value as T;
    throw StateError('Invalid type access on ParsedLiteral');
  }
}

final class ParsedInteger extends ParsedLiteral {
  final int value;
  const ParsedInteger(this.value);
  @override
  String get asString => value.toString();
}

final class ParsedFloat extends ParsedLiteral {
  final double value;
  const ParsedFloat(this.value);
  @override
  String get asString => value.toString();
}

final class ParsedUuid extends ParsedLiteral {
  final String value;
  const ParsedUuid(this.value);
  @override
  String get asString => value;
}

final class ParsedHash extends ParsedLiteral {
  final String value;
  const ParsedHash(this.value);
  @override
  String get asString => value;
}

final class ParsedEnum extends ParsedLiteral {
  final String value;
  const ParsedEnum(this.value);
  @override
  String get asString => value;
}
