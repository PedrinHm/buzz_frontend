import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    
    // Remove tudo que não é dígito
    text = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limita a 11 dígitos
    if (text.length > 11) {
      text = text.substring(0, 11);
    }
    
    var newText = '';
    for (var i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) newText += '.';
      if (i == 9) newText += '-';
      newText += text[i];
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
} 