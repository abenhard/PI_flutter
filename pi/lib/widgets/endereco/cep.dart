import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextFormField CEP(TextEditingController _cepController, {required bool enabled}) {
  return TextFormField(
    controller: _cepController,
    maxLength: 9,
    maxLengthEnforcement: MaxLengthEnforcement.enforced,
    decoration: InputDecoration(labelText: 'CEP'),
    keyboardType: TextInputType.datetime,
    enabled: enabled,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;
        final newText = StringBuffer();
        if (text.length <= 5) {
          newText.write(text.substring(0, text.length));
        } else if (text.length > 5 && text.length <= 9) {
          newText.write(text.substring(0, 5) + '-' + text.substring(5, text.length));
        } else {
          newText.write(text.substring(0, 5) + '-' + text.substring(5, 8));
        }
        return TextEditingValue(
          text: newText.toString(),
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }),
    ],
    validator: (value) {
      if (value != null && value.isNotEmpty) {
        final cepRegex = RegExp(r'^\d{5}-\d{3}$');
        
        if (!cepRegex.hasMatch(value)) {
          return 'Por favor, insira um CEP válido (Formato: 12345-678)';
        }
      }
      return null;
    },
  );
}
