import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pi/paginas/pagina_detalhes/cliente_detalhe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pi/url.dart';


class SearchClientes extends StatefulWidget {
  final Function(String) onClienteSelected;

  const SearchClientes({required this.onClienteSelected, Key? key}) : super(key: key);

  @override
  _SearchClientesState createState() => _SearchClientesState();
}

class _SearchClientesState extends State<SearchClientes> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchClientes(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse(BackendUrls().getPessoaCPF('$query')),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          _searchResults = jsonResponse;
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Widget _buildSearchResults() {
    return _isSearching
        ? CircularProgressIndicator()
        : ListView.builder(
            shrinkWrap: true,
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final cliente = _searchResults[index];
              return ListTile(
                title: Text(cliente['nome']),
                subtitle: Text(cliente['cpf']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClienteDetalhes(cliente: cliente),
                    ),
                  );
                },
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Buscar Cliente',
            hintText: 'Digite o nome ou CPF',
          ),
          onChanged: _searchClientes,
        ),
        _buildSearchResults(),
      ],
    );
  }
}
