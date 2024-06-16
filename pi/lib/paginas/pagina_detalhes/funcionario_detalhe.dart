import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pi/url.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FuncionarioDetalhes extends StatefulWidget {
  final Map<String, dynamic>? funcionario;

  const FuncionarioDetalhes({required this.funcionario, Key? key}) : super(key: key);

  @override
  _FuncionarioDetalhesState createState() => _FuncionarioDetalhesState();
}

class _FuncionarioDetalhesState extends State<FuncionarioDetalhes> {
  bool isEditing = false;
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController telefoneController;
  late TextEditingController whatsappController;
  late TextEditingController cpfController;
  late TextEditingController ruaController;
  late TextEditingController bairroController;
  late TextEditingController complementoController;
  late TextEditingController cepController;
  late TextEditingController numeroController;
  late TextEditingController cidadeController;
  late TextEditingController estadoController;
  late TextEditingController cargoController;
  bool ativo = false;

  @override
  void initState() {
    super.initState();

    final funcionario = widget.funcionario ?? {};
    final pessoa = funcionario['pessoa'] ?? {};
    final cargo = funcionario['funcionario']?['cargo'] ?? {};

    print('Funcionario: ${widget.funcionario}');
    print('Pessoa: $pessoa');

    nomeController = TextEditingController(text: pessoa['nome'] ?? '');
    emailController = TextEditingController(text: pessoa['email'] ?? '');
    telefoneController = TextEditingController(text: pessoa['telefone'] ?? '');
    whatsappController = TextEditingController(text: pessoa['whatsapp'] ?? '');
    cpfController = TextEditingController(text: pessoa['cpf'] ?? '');
    ruaController = TextEditingController(text: pessoa['rua'] ?? '');
    bairroController = TextEditingController(text: pessoa['bairro'] ?? '');
    complementoController = TextEditingController(text: pessoa['complemento'] ?? '');
    cepController = TextEditingController(text: pessoa['cep'] ?? '');
    numeroController = TextEditingController(text: pessoa['numero'] ?? '');
    cidadeController = TextEditingController(text: pessoa['cidade'] ?? '');
    estadoController = TextEditingController(text: pessoa['estado'] ?? '');
    cargoController = TextEditingController(text: cargo['nome'] ?? '');
    ativo = funcionario['funcionario']?['ativo'] ?? false;
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    whatsappController.dispose();
    cpfController.dispose();
    ruaController.dispose();
    bairroController.dispose();
    complementoController.dispose();
    cepController.dispose();
    numeroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    cargoController.dispose();
    super.dispose();
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _submitForm() async {
    final response = await _updateFuncionario();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionario atualizado com sucesso!')),
      );
      setState(() {
        isEditing = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar funcionario: ${response.body}')),
      );
    }
  }

  Future<http.Response> _updateFuncionario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final FuncionarioAtualizado = {
      'pessoaEnderecoDTO': {
        'pessoaDTO': {
          'nome': nomeController.text,
          'email': emailController.text,
          'telefone': telefoneController.text,
          'whatsapp': whatsappController.text,
          'cpf': cpfController.text,
          'rua': ruaController.text,
          'bairro': bairroController.text,
          'complemento': complementoController.text,
          'cep': cepController.text,
          'numero': numeroController.text,
          'cidade': cidadeController.text,
          'estado': estadoController.text,
        }
      },
      'funcionarioDTO': {
        'login': emailController.text,
        'cargo': cargoController.text,
        'ativo': ativo,
      }
    };

    return http.put(
      Uri.parse(BackendUrls().getFuncionario()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(FuncionarioAtualizado),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Detalhes do Funcionário',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalhes do Funcionário',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton(
                  onPressed: isEditing ? _submitForm : toggleEditing,
                  child: Text(isEditing ? 'Salvar' : 'Editar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
              enabled: isEditing,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              enabled: isEditing,
            ),
            TextField(
              controller: telefoneController,
              decoration: InputDecoration(labelText: 'Telefone'),
              enabled: isEditing,
            ),
            TextField(
              controller: whatsappController,
              decoration: InputDecoration(labelText: 'Whatsapp'),
              enabled: isEditing,
            ),
            TextField(
              controller: cpfController,
              decoration: InputDecoration(labelText: 'CPF'),
              enabled: isEditing,
            ),
            TextField(
              controller: ruaController,
              decoration: InputDecoration(labelText: 'Rua'),
              enabled: isEditing,
            ),
            TextField(
              controller: bairroController,
              decoration: InputDecoration(labelText: 'Bairro'),
              enabled: isEditing,
            ),
            TextField(
              controller: complementoController,
              decoration: InputDecoration(labelText: 'Complemento'),
              enabled: isEditing,
            ),
            TextField(
              controller: cepController,
              decoration: InputDecoration(labelText: 'CEP'),
              enabled: isEditing,
            ),
            TextField(
              controller: numeroController,
              decoration: InputDecoration(labelText: 'Número'),
              enabled: isEditing,
            ),
            TextField(
              controller: cidadeController,
              decoration: InputDecoration(labelText: 'Cidade'),
              enabled: isEditing,
            ),
            TextField(
              controller: estadoController,
              decoration: InputDecoration(labelText: 'Estado'),
              enabled: isEditing,
            ),
            TextField(
              controller: cargoController,
              decoration: InputDecoration(labelText: 'Cargo'),
              enabled: isEditing,
            ),
            SwitchListTile(
              title: const Text('Ativo'),
              value: ativo,
              onChanged: isEditing
                  ? (bool value) {
                      setState(() {
                        ativo = value;
                      });
                      if (!value) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Aviso'),
                              content: const Text('Você está desativando este funcionário.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  : null,
              secondary: const Icon(Icons.warning, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
