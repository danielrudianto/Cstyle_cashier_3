import 'package:flutter/services.dart';

class CustomTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      int selectionIndexFromTheRight =
          newValue.text.length - newValue.selection.extentOffset;

      String newText = newValue.text.replaceAll(' ', '');
      newText = newText.replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]} ');

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: newText.length - selectionIndexFromTheRight,
        ),
      );
    } else {
      return newValue;
    }
  }
}
