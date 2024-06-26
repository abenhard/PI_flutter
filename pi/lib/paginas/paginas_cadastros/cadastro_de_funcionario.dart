import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pi/url.dart';
import 'package:pi/widgets/cadastro/cargo.dart';
import 'package:pi/widgets/endereco/cep.dart';
import 'package:pi/widgets/cadastro/cpf.dart';
import 'package:pi/widgets/cadastro/email.dart';
import 'package:pi/widgets/endereco/estado.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:pi/widgets/cadastro/telefone_residencial.dart';
import 'package:pi/widgets/textFormFieldGenerico.dart';
import 'package:pi/widgets/whatsapp.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CadastroDeFuncionario extends StatefulWidget {
  const CadastroDeFuncionario({Key? key}) : super(key: key);

  @override
  _CadastroDeFuncionarioState createState() => _CadastroDeFuncionarioState();
}

class _CadastroDeFuncionarioState extends State<CadastroDeFuncionario> {
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

  final TextEditingController _senhaController = TextEditingController();

  String? _cargoSelecionado;
  String? _estadoSelecionado;

  bool _showEndereco = false;
  bool _showCargo = false;

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
    _senhaController.dispose();

    super.dispose();
  }

  void _handlePessoaFound(Map<String, dynamic> pessoa) {
    setState(() {
      _nomeController.text = pessoa['nome'];
      _emailController.text = pessoa['email'];
      _telefoneController.text = pessoa['telefone'];
      _whatsappController.text = pessoa['whatsapp'];
      _ruaController.text = pessoa['rua'];
      _bairroController.text = pessoa['bairro'];
      _complementoController.text = pessoa['complemento'];
      _cepController.text = pessoa['cep'];
      _numeroController.text = pessoa['numero'];
      _cidadeController.text = pessoa['cidade'];
      _estadoSelecionado = pessoa['estado'];
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var response = await registrarFuncionario();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionario cadastrado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${response.body}')),
        );
      }
    }
  }

  Future<http.Response> registrarFuncionario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final FuncionarioCadastro = {
      'pessoaEnderecoDTO': {
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
          'cidade': _cidadeController.text,
          'estado': _estadoSelecionado,
        }
      },
      'funcionarioDTO': {
        'senha': _senhaController.text,
        'login': _emailController.text,
        'cargo': _cargoSelecionado,
        'ativo': true
      }
    };

    return http.post(
      Uri.parse(BackendUrls().getCadastrarFuncionario()),
      headers: <String, String>{
         'Content-Type': 'application/json; charset=UTF-8',
         'Authorization': 'Bearer $token',
      },
      body: jsonEncode(FuncionarioCadastro),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Cadastro de Funcionário',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              //----Pessoa-----//
              TextFormFieldGenerico(
                controller: _nomeController,
                label: 'Nome',
                validationMessage: 'Por favor, insira o nome',
              ),
              Email(_emailController),
              TelefoneResidencial(_telefoneController),
              WhatsApp(_whatsappController),
              CPF(
                controller: _cpfController,
                onPessoaFound: _handlePessoaFound,
                enabled: true,
              ),
              SizedBox(height: 20),

              //--Endereco--//
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
                        CEP(_cepController, enabled: true),
                        TextFormFieldGenerico(
                          controller: _numeroController,
                          label: 'Numero',
                          validationMessage: 'Por favor insira o numero da residência',
                        ),
                        TextFormFieldGenerico(
                          controller: _ruaController,
                          label: 'Rua',
                          validationMessage: 'Por favor, Insira o nome da rua',
                        ),
                        TextFormFieldGenerico(
                          controller: _bairroController,
                          label: 'Bairro',
                          validationMessage: 'Por favor, Insira o nome do Bairro',
                        ),
                        optionalBuildTextFormField(_complementoController, 'complemento'),
                        TextFormFieldGenerico(
                          controller: _cidadeController,
                          label: 'Cidade',
                          validationMessage: 'Por favor, Insira o nome da Cidade',
                        ),
                        EstadoDropdown(
                          onChanged: (valorSelecionado) {
                            setState(() {
                              _estadoSelecionado = valorSelecionado;
                            });
                          },
                          estadoSelecionado: _estadoSelecionado,
                          enabled: true,
                        ),
                      ],
                    ),
                    isExpanded: _showEndereco,
                  ),
                ],
              ),
              SizedBox(height: 20),

              //------CARGO------//
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _showCargo = !isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: const Text('Função'),
                        onTap: () {
                          setState(() {
                            _showCargo = !isExpanded;
                          });
                        },
                      );
                    },
                    body: Column(
                      children: [
                        TextFormFieldGenerico(
                          controller: _senhaController,
                          label: 'Senha',
                          validationMessage: 'Digite sua Senha!',
                        ),
                        CargoDropdown(
                          enabled: true,
                          onChanged: (valorSelecionado) {
                            setState(() {
                              _cargoSelecionado = valorSelecionado;
                            });
                          },
                          cargoSelecionado: _cargoSelecionado,
                        ),
                        
                      ],
                    ),
                    isExpanded: _showCargo,
                  ),
                ],
              ),

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

  TextFormField optionalBuildTextFormField(TextEditingController controller, String label, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
    );
  }
}
