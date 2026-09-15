import 'package:flutter/services.dart';

/// Allows a non-negative decimal (digits and at most one `.`).
///
/// Used by the target-price field so rupee drafts stay numeric.
class DecimalInputFormatter extends TextInputFormatter {
  const DecimalInputFormatter();

  static final RegExp _pattern = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _pattern.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
