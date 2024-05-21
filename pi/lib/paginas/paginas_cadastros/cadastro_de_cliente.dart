import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pi/url.dart';
import 'package:pi/widgets/endereco/cep.dart';
import 'package:pi/widgets/cadastro/cpf.dart';
import 'package:pi/widgets/cadastro/email.dart';
import 'package:pi/widgets/endereco/estado.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:pi/widgets/cadastro/telefone_residencial.dart';
import 'package:pi/widgets/textFormFieldGenerico.dart';
import 'package:pi/widgets/whatsapp.dart';

class CadastroDeCliente extends StatefulWidget {
  const CadastroDeCliente({Key? key}) : super(key: key);

  @override
  _CadastroDeClienteState createState() => _CadastroDeClienteState();
}

class _CadastroDeClienteState extends State<CadastroDeCliente> {
  final _formKey = GlobalKey<FormState>();
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
  String? _estadoSelecionado;
  bool _showEndereco = false;

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
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var response = await registrarPessoa();
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

  Future<http.Response> registrarPessoa() {
    final pessoaEnderecoDTO = {
      'pessoaDTO': {
        'nome': _nomeController.text,
        'email': _emailController.text,
        'telefone': _telefoneController.text,
        'whatsapp': _whatsappController.text,
        'cpf': _cpfController.text,
      },
      'enderecoDTO': {
        'cpf': _cpfController.text,
        'numero': _numeroController.text,
        'cep': _cepController.text,
        'rua': _ruaController.text,
        'bairro': _bairroController.text,
        'complemento': _complementoController.text,
        'cidade': _cidadeController.text,
        'estado': _estadoSelecionado,
      }
    };
    return http.post(
      Uri.parse(BackendUrls().getPessoas()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(pessoaEnderecoDTO),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Cadastro de Cliente',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              //----Pessoa-----//
              TextFormFieldGenerico(_nomeController, 'Nome', 'Por favor, insira o nome'),
              Email(_emailController),
              TelefoneResidencial(_telefoneController),
              WhatsApp(_whatsappController),
              CPF(controller: _cpfController),
              //-----Endereço-----//
              const SizedBox(height: 10,),
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _showEndereco = !isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: const Text('Endereço'),
                        onTap: () {
                          setState(() {
                            _showEndereco = !isExpanded;
                          });
                        },
                      );
                    },
                    body: Column(
                      children: [
                        CEP(_cepController),
                        TextFormFieldGenerico(_numeroController, 'Numero', 'Por favor insira o numero da residência'),
                        TextFormFieldGenerico(_ruaController, 'Rua', 'Por favor, insira o nome da rua'),
                        TextFormFieldGenerico(_bairroController, 'Bairro', 'Por favor, insira o nome do Bairro'),
                        TextFormFieldGenerico(_complementoController, 'Complemento', 'Por favor, insira o complemento (Opcional)'),
                        TextFormFieldGenerico(_cidadeController, 'Cidade', 'Por favor, insira o nome da Cidade'),
                        EstadoDropdown(
                          onChanged: (newValue) {
                            setState(() {
                              _estadoSelecionado = newValue;
                            });
                          },
                          estadoSelecionado: _estadoSelecionado,
                        ),
                      ],
                    ),
                    isExpanded: _showEndereco,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
