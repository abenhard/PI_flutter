import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pi/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TecnicoDropdown extends StatefulWidget {
  final Function(String) onTecnicoSelected;

  const TecnicoDropdown({required this.onTecnicoSelected, Key? key}) : super(key: key);

  @override
  _TecnicoDropdownState createState() => _TecnicoDropdownState();
}

class _TecnicoDropdownState extends State<TecnicoDropdown> {
  String? _tecnicoSelecionado;
  List<Map<String, String>> _tecnicos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTechnicians();
  }

  Future<void> _fetchTechnicians() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse(BackendUrls().getFuncionario()),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Response body: $responseBody');

        final List<dynamic> data = jsonDecode(responseBody);
        setState(() {
          _tecnicos = data
              .where((funcionario) => funcionario['cargo']['nome'] == 'TECNICO')
              .map((funcionario) => {
                'nome': funcionario['pessoa']['nome'] as String,
                'login': funcionario['login'] as String
              })
              .toList();
          print('Technicians fetched: $_tecnicos'); // Debug statement
        });
      } else {
        print('Failed to load technicians: ${response.statusCode}');
        // Handle other status codes
      }
    } catch (e) {
      print('Error fetching technicians: $e'); // Handle errors
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : DropdownButtonFormField<String>(
            value: _tecnicoSelecionado,
            items: _tecnicos.map((technician) {
              return DropdownMenuItem<String>(
                value: technician['login'],
                child: Text(technician['nome']!),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _tecnicoSelecionado = newValue;
              });
              widget.onTecnicoSelected(newValue!);
            },
            decoration: InputDecoration(
              labelText: 'Selecione um Técnico Responsável',
            ),
          );
  }
}
