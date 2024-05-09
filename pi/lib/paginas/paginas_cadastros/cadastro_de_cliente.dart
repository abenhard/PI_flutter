import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pi/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroDeCliente extends StatefulWidget {
  const CadastroDeCliente({Key? key}) : super(key: key);

  @override
  _CadastroDeClienteState createState() => _CadastroDeClienteState();
}

class _CadastroDeClienteState extends State<CadastroDeCliente> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  final TextEditingController _ruaController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();

  // Clean up controllers
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _whatsappController.dispose();
    _cpfController.dispose();

    _ruaController.dispose();
    _bairroController.dispose();
    _numeroController.dispose();
    _cepController.dispose();
    _cidadeController.dispose();
    _complementoController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var response = await registerClient();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente cadastrado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${response.body}')),
        );
      }
    }
  }

  Future<http.Response> registerClient() {

    final pessoaEnderecoDTO ={
      'pessoaDTO': {
        'nome': _nomeController.text,
        'email': _emailController.text,
        'telefone': _telefoneController.text,
        'whatsapp': _whatsappController.text,
        'cpf': _cpfController.text
      },
      'enderecoDTO': {
        'cpf': _cpfController.text,

        'numero': _numeroController.text,
        'cep': _cepController.text,
        'rua': _ruaController.text,
        'bairro': _bairroController.text,
        'complemento': _complementoController.text,
        'cidade':_cidadeController.text,
        'estado': _estadoController,
      }
    };
    return http.post(
      Uri.parse('http://192.168.100.3:8080/PI_Backend/pessoa'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(pessoaEnderecoDTO),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Cliente'),
        actions: [
          IconButton(
            iconSize: 40,
            icon: const Icon(Icons.person),
            onPressed: () async {
              // Clear token from SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_token');
              // Navigate to login screen
              Get.offAllNamed(Routes.login);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              //----Pessoa-----//
              buildTextFormField(_nomeController, 'Nome', 'Por favor, insira o nome'),
              buildEmailFormField(),
              buildTextFormField(_telefoneController, 'Telefone', null, TextInputType.phone),
              buildWhatsAppFormField(),
              buildCPFFormField(),
              //-----Endereço-----//
              buildCEPFormField(),
              buildTextFormField(_numeroController, 'Numero', 'Por favor insira o numero da residência'),
              buildTextFormField(_ruaController, 'Rua', 'Por favor, Insira o nome da rua'),
              buildTextFormField(_bairroController, 'Bairro', 'Por favor, Insira o nome do Bairro'),
              optionalBuildTextFormField(_complementoController, 'complemento'),
              buildTextFormField(_cidadeController, 'Cidade', 'Por favor, Insira o nome da Cidade'),
              buildTextFormField(_estadoController, 'Estado', 'Por favor, Escolha a sigla do Estado'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField buildTextFormField(TextEditingController controller, String label, String? validationMessage, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }
  TextFormField optionalBuildTextFormField(TextEditingController controller, String label, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
    );
  }
  TextFormField buildEmailFormField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira o email';
        }
        if (!isValidEmail(value)) {
          return 'Por favor, insira um email válido';
        }
        return null;
      },
    );
  }

  TextFormField buildWhatsAppFormField() {
    return TextFormField(
      controller: _whatsappController,
      decoration: InputDecoration(labelText: 'WhatsApp'),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira o WhatsApp';
        }
        if (!isValidTelefone(value)) {
          return 'Por favor, insira um número de WhatsApp válido';
        }
        return null;
      },
    );
  }

  TextFormField buildCPFFormField() {
    return TextFormField(
      controller: _cpfController,
      decoration: InputDecoration(labelText: 'CPF'),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira o CPF';
        }
        if (!CPFValidator.isValid(value)) {
          return 'Por favor, insira um CPF válido';
        }
        return null;
      },
    );
  }
  TextFormField buildCEPFormField(){
    return TextFormField(
      controller: _cepController,
      decoration: InputDecoration(labelText: 'CEP'),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
            final cepRegex = RegExp(r'^\d{5}-\d{3}$');
            
            if (!cepRegex.hasMatch(value)) {
              return 'Por favor, insira um CEP válido (Formato: 12345-678)';
            }
        }
      }
    );
  }
  
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidTelefone(String number) {
    final phoneRegex = RegExp(r'^\+?55?\d{2}\d{9}$');
    return phoneRegex.hasMatch(number);
  }
}
