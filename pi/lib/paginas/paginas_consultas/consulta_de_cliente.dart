import 'package:flutter/material.dart';
import 'package:pi/paginas/pagina_detalhes/cliente_detalhe.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pi/url.dart';

class ConsultaDeCliente extends StatefulWidget {
  const ConsultaDeCliente({Key? key}) : super(key: key);

  @override
  _ConsultaDeClienteState createState() => _ConsultaDeClienteState();
}

class _ConsultaDeClienteState extends State<ConsultaDeCliente> {
  List<dynamic> _clientes = [];

  Future<void> _fetchClientes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse(BackendUrls().getPessoas()),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _clientes = json.decode(response.body);
      });
    } else {
      // Handle error
      throw Exception('Failed to load clients');
    }
  }

  void _filterClientes(String query) {
    if (query.isEmpty) {
      _fetchClientes();
      return;
    }

    setState(() {
      _clientes = _clientes.where((cliente) {
        final nome = cliente['nome'].toString().toLowerCase();
        final cpf = cliente['cpf'].toString().toLowerCase();
        final searchLower = query.toLowerCase();

        return nome.contains(searchLower) || cpf.contains(searchLower);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchClientes();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Consulta de Clientes',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por Nome ou CPF',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterClientes,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _clientes.length,
              itemBuilder: (context, index) {
                final cliente = _clientes[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    title: Text(cliente['nome']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CPF: ${cliente['cpf']}'),
                        Text('Telefone: ${cliente['telefone']}'),
                        Text('Email: ${cliente['email']}'),
                        Text('Whatsapp: ${cliente['whatsapp']}'),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClienteDetalhes(cliente: cliente),
                        ),
                      );
                      _fetchClientes();
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
