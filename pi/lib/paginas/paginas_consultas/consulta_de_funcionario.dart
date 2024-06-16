import 'package:flutter/material.dart';
import 'package:pi/paginas/pagina_detalhes/funcionario_detalhe.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pi/url.dart';

class ConsultaDeFuncionario extends StatefulWidget {
  const ConsultaDeFuncionario({Key? key}) : super(key: key);

  @override
  _ConsultaDeFuncionarioState createState() => _ConsultaDeFuncionarioState();
}

class _ConsultaDeFuncionarioState extends State<ConsultaDeFuncionario> {
  List<dynamic> _funcionarios = [];
  List<dynamic> _filteredFuncionarios = [];
  bool _showInactive = false;

  Future<void> _fetchFuncionarios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse(BackendUrls().getFuncionario()), // Adjust the URL accordingly
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _funcionarios = json.decode(response.body);
        _filterFuncionarios('');
      });
    } else {
      // Handle error
      throw Exception('Falha ao carregar funcionarios');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFuncionarios();
  }

  void _filterFuncionarios(String query) {
    setState(() {
      _filteredFuncionarios = _funcionarios.where((funcionario) {
        final nome = funcionario['pessoa']['nome'].toString().toLowerCase();
        final cpf = funcionario['pessoa']['cpf'].toString().toLowerCase();
        final ativo = funcionario['funcionario']['ativo'];
        final searchLower = query.toLowerCase();

        return (nome.contains(searchLower) || cpf.contains(searchLower)) &&
            (ativo == true || _showInactive);
      }).toList();
    });
  }

  void _toggleInactive(bool showInactive) {
    setState(() {
      _showInactive = showInactive;
      _filterFuncionarios('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Consulta de Funcionários',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por Nome ou CPF',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterFuncionarios,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mostrar inativos'),
                Switch(
                  value: _showInactive,
                  onChanged: _toggleInactive,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFuncionarios.length,
              itemBuilder: (context, index) {
                final funcionario = _filteredFuncionarios[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    title: Text(funcionario['pessoa']['nome']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cargo: ${funcionario['funcionario']['cargo']['nome']}'),
                        Text('CPF: ${funcionario['pessoa']['cpf']}'),
                        Text('Email: ${funcionario['pessoa']['email']}'),
                        Text('Whatsapp: ${funcionario['pessoa']['whatsapp']}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FuncionarioDetalhes(funcionario: funcionario),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
