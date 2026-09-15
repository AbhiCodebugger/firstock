import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/utils/input_formatters.dart';

void main() {
  const formatter = DecimalInputFormatter();

  TextEditingValue apply(String oldText, String newText) {
    return formatter.formatEditUpdate(
      TextEditingValue(text: oldText),
      TextEditingValue(text: newText),
    );
  }

  test('accepts digits and a single decimal point', () {
    expect(apply('', '310').text, '310');
    expect(apply('310', '310.5').text, '310.5');
    expect(apply('', '').text, '');
  });

  test('rejects a second decimal point and letters', () {
    expect(apply('310.5', '310.5.1').text, '310.5');
    expect(apply('310', '310a').text, '310');
  });
}
