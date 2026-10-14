import 'package:flutter/services.dart';

class PercentInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }
    final newText = '$digits%';
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
