import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pi/url.dart';

class CPF extends StatefulWidget {
  final TextEditingController controller;

  CPF({required this.controller});

  @override
  CPFstate createState() => CPFstate();
}

class CPFstate extends State<CPF> {
  String? _cpfError;

  Future<void> _validateCPF(String cpf) async {
    // Perform validation against the database
    final response = await http.get(Uri.parse(BackendUrls().getPessoaCPF(cpf)));
    if (response.statusCode == 200) {
      // If CPF exists in the database, set error message
      setState(() {
        _cpfError = 'CPF já cadastrado';
      });
    } else {
      // If CPF does not exist in the database, clear error message
      setState(() {
        _cpfError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      maxLength: 14, // Adjusted length back to 11
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      decoration: InputDecoration(
        labelText: 'CPF',
        errorText: _cpfError,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text.replaceAll(RegExp(r'[^\d]'), ''); // Remove non-digits
          final newText = StringBuffer();
          if (text.length <= 3) {
            newText.write(text.substring(0, text.length));
          } else if (text.length <= 6) {
            newText.write(text.substring(0, 3) + '.' + text.substring(3, text.length));
          } else if (text.length <= 9) {
            newText.write(text.substring(0, 3) + '.' + text.substring(3, 6) + '.' + text.substring(6, text.length));
          } else {
            newText.write(text.substring(0, 3) +
                '.' +
                text.substring(3, 6) +
                '.' +
                text.substring(6, 9) +
                '-' +
                text.substring(9, text.length));
          }
          return TextEditingValue(
            text: newText.toString(),
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }),
      ],
      onChanged: (value) {
        // Reset error message on change
        setState(() {
          _cpfError = null;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira o CPF';
        }
        final cleanCPF = value.replaceAll(RegExp(r'[^\d]'), ''); // Remove non-digits
        if (cleanCPF.length != 11) {
          return 'O CPF deve conter 11 dígitos';
        }
        if (!CPFValidator.isValid(cleanCPF)) {
          return 'Por favor, insira um CPF válido';
        }
        return null;
      },
    );
  }
}
