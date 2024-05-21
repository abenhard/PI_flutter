import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pi/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuscarCliente extends StatefulWidget {
  final Function(String) onClienteSelecionado;

  const BuscarCliente({required this.onClienteSelecionado, Key? key}) : super(key: key);

  @override
  _BuscarClienteState createState() => _BuscarClienteState();
}

class _BuscarClienteState extends State<BuscarCliente> {
  final TextEditingController _buscaController = TextEditingController();
  List<Map<String, String>> _clientes = [];
  bool _isLoading = false;

  Future<void> _searchClient(String query) async {
    setState(() {
        _isLoading = true;
    });

    try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('jwt_token');

        final response = await http.get(
            Uri.parse('${BackendUrls().getPessoas()}?query=$query'),
            headers: {
                'Authorization': 'Bearer $token',
            },
        );

        if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            setState(() {
                _clientes = data.map((cliente) => {
                  'nome': cliente['nome'] as String,
                  'cpf': cliente['cpf'] as String
                }).toList();
            });
        } else {
            // Handle other status codes
        }
    } catch (e) {
        // Handle errors
    } finally {
        setState(() {
            _isLoading = false;
        });
    }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _buscaController,
          decoration: InputDecoration(
            labelText: 'Selecione o Cliente por nome ou CPF',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _searchClient(_buscaController.text),
            ),
          ),
        ),
        if (_isLoading)
          CircularProgressIndicator()
        else
          ListView.builder(
            shrinkWrap: true,
            itemCount: _clientes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_clientes[index]['nome']!),
                onTap: () {
                  widget.onClienteSelecionado(_clientes[index]['cpf']!);
                  setState(() {
                    _buscaController.text = _clientes[index]['nome']!;
                  });
                },
              );
            },
          ),
      ],
    );
  }
}
