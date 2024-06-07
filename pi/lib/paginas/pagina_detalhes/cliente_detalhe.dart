import 'package:flutter/material.dart';
import 'package:pi/widgets/endereco/cep.dart';
import 'package:pi/widgets/endereco/estado.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pi/url.dart';

class ClienteDetalhes extends StatefulWidget {
  final Map<String, dynamic> cliente;

  const ClienteDetalhes({required this.cliente, Key? key}) : super(key: key);

  @override
  _ClienteDetalhesState createState() => _ClienteDetalhesState();
}

class _ClienteDetalhesState extends State<ClienteDetalhes> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _cliente;
  bool _isEditing = false;
  late TextEditingController _cepController;
  String? _estadoSelecionado;

  @override
  void initState() {
    super.initState();
    _cliente = Map<String, dynamic>.from(widget.cliente);
    _cepController = TextEditingController(text: _cliente['cep']);
    _estadoSelecionado = _cliente['estado'];
  }

  Future<void> _saveCliente() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.put(
        Uri.parse(BackendUrls().updatePessoa()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(_cliente),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Changes saved successfully')),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes do Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _cliente['nome'],
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Nome'),
                onSaved: (value) => _cliente['nome'] = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome não pode ser vazio';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _cliente['cpf'],
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'CPF'),
                onSaved: (value) => _cliente['cpf'] = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CPF não pode ser vazio';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _cliente['telefone'],
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Telefone'),
                onSaved: (value) => _cliente['telefone'] = value,
              ),
              TextFormField(
                initialValue: _cliente['email'],
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (value) => _cliente['email'] = value,
              ),
              TextFormField(
                initialValue: _cliente['whatsapp'],
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Whatsapp'),
                onSaved: (value) => _cliente['whatsapp'] = value,
              ),
              TextFormField(
                initialValue: _cliente['rua'],
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Rua'),
                onSaved: (value) => _cliente['rua'] = value,
              ),
              TextFormField(
                initialValue: _cliente['bairro'],
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Bairro'),
                onSaved: (value) => _cliente['bairro'] = value,
              ),
              CEP(_cepController, enabled: _isEditing), // Use the CEP widget
              TextFormField(
                initialValue: _cliente['numero'],
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Número'),
                onSaved: (value) => _cliente['numero'] = value,
              ),
              TextFormField(
                initialValue: _cliente['cidade'],
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Cidade'),
                onSaved: (value) => _cliente['cidade'] = value,
              ),
              EstadoDropdown(
                estadoSelecionado: _estadoSelecionado,
                enabled: _isEditing,
                onChanged: (String? newValue) {
                  setState(() {
                    _estadoSelecionado = newValue;
                    _cliente['estado'] = newValue;
                  });
                },
              ), // Use the EstadoDropdown widget
              SizedBox(height: 20),
              _isEditing
                  ? ElevatedButton(
                      onPressed: _saveCliente,
                      child: Text('Salvar'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: Text('Editar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
