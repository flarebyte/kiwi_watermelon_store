import 'dart:convert';
import 'dart:io';

abstract class JsonConverter<T> {
  Map<String, dynamic> toJson(T value);
  T fromJson(Map<String, dynamic> json);
}

class FixtureStore<T> {
  final String filePath;
  final JsonConverter<T> converter;

  const FixtureStore({
    required this.filePath,
    required this.converter,
  });

  Future<void> save(Map<String, T> data) async {
    final file = File(filePath);
    final jsonMap = <String, dynamic>{
      for (final entry in data.entries)
        entry.key: converter.toJson(entry.value),
    };

    final encoder = const JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(jsonMap);
    await file.writeAsString(prettyJson);
  }

  Future<Map<String, T>> load() async {
    final file = File(filePath);
    if (!file.existsSync()) return {};

    final jsonString = await file.readAsString();
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    return decoded.map((key, value) {
      return MapEntry(key, converter.fromJson(value as Map<String, dynamic>));
    });
  }
}

class TokenInfo {
  final String code;
  final List<String> types;
  final List<String> texts;

  const TokenInfo({
    required this.code,
    required this.types,
    required this.texts,
  });
}

class TokenInfoConverter implements JsonConverter<TokenInfo> {
  @override
  TokenInfo fromJson(Map<String, dynamic> json) {
    return TokenInfo(
      code: json['code'] as String,
      types: List<String>.from(json['types'] as List),
      texts: List<String>.from(json['texts'] as List),
    );
  }

  @override
  Map<String, dynamic> toJson(TokenInfo value) {
    return {
      'code': value.code,
      'types': value.types,
      'texts': value.texts,
    };
  }
}
