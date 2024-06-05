import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextFormField WhatsApp(TextEditingController _whatsappController) {
  return TextFormField(
    controller: _whatsappController,
    maxLength: 12,
    maxLengthEnforcement: MaxLengthEnforcement.enforced,
    decoration: InputDecoration(labelText: 'WhatsApp'),
    keyboardType: TextInputType.phone,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;
        final newText = StringBuffer();
        if (text.length <= 2) {
          newText.write(text.substring(0, text.length));
        } else if (text.length > 2) {
          newText.write(text.substring(0, 2) + '-' + text.substring(2, text.length));
        }
        return TextEditingValue(
          text: newText.toString(),
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }),
    ],
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Por favor, insira o WhatsApp';
      }
      return null;
    },
  );
}
