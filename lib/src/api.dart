import 'autorisation/capability.dart';
import 'language/syntax_analyser.dart';
import 'language/tokeniser.dart';
import 'store/manager_options.dart';

class KiwiWatermelonApi {
  /// Constructs a [KiwiWatermelonOptions] using default or provided values.
  /// Delegates all validation to the [KiwiWatermelonOptions] constructor.
  static KiwiWatermelonOptions createOptions({
    required List<String> prefixes,
    Map<String, String>? mapping,
    bool Function(String)? variableValidator,
    List<KiwiWatermelonDataCapability>? capabilities,
  }) {
    return KiwiWatermelonOptions(
      prefixes: prefixes,
      mapping: mapping ?? const {'true': 'T', 'false': 'F'},
      variableValidator: variableValidator ?? _defaultValidator,
      capabilities: capabilities ?? const [],
    );
  }

  static bool _defaultValidator(String name) =>
      RegExp(r'^[a-zA-Z][a-zA-Z0-9_:]*$').hasMatch(name);

  /// create a Tokeniser
  static KiwiWatermelonTokeniser createTokeniser() {
    return KiwiWatermelonTokeniser();
  }

  /// create a syntax analyser
  static createSyntaxAnalyser(
      {required KiwiWatermelonOptions options, required String role}) {
    return KiwiWatermelonSyntaxAnalyser(options: options, role: role);
  }
}
