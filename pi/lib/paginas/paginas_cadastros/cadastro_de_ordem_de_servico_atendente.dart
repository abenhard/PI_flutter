import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pi/widgets/tipo_servico.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi/url.dart';
import 'package:pi/widgets/cadastro/search_cliente.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:pi/widgets//cadastro/tecnico_dropdown.dart';
import 'package:pi/widgets/textFormFieldGenerico.dart';
import 'package:pi/widgets/statusEnum.dart';

class CadastroDeOrdemDeServicoAtendente extends StatefulWidget {
  const CadastroDeOrdemDeServicoAtendente({Key? key}) : super(key: key);

  @override
  _CadastroDeOrdemDeServicoAtendente createState() => _CadastroDeOrdemDeServicoAtendente();
}

class _CadastroDeOrdemDeServicoAtendente extends State<CadastroDeOrdemDeServicoAtendente> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  String? _clienteSelecionado;
  String? _tecnicoSelecionado;
  String? _tipoServicoSelecionado;
  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var response = await cadastrarOrdem();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ordem de serviço cadastrada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${response.body}')),
        );
      }
    }
  }
Future<http.Response> cadastrarOrdem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');


    final ordemDeServicoAtendenteDTO = {
        'clienteCPF': _clienteSelecionado,
        'funcionariologin': _tecnicoSelecionado,
        'status': status.Aberta.toString(),
        'tipo_servico': _tipoServicoSelecionado,
        'descricao_problema': _descricaoController.text
    };

    return http.post(
      Uri.parse(BackendUrls().getCadastrarOrdemAtendente()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',  
      },
      body: jsonEncode(ordemDeServicoAtendenteDTO),
    );
}

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Cadastro de Ordem de Serviço',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SearchClientes(
                onClienteSelected: (cpf) {
                setState(() {
                  _clienteSelecionado = cpf;
                });
              }),
              const SizedBox(height: 20),
              TecnicoDropdown(
                isEditing: true,
                onTecnicoSelected: (String tecnico) {
                  setState(() {
                    _tecnicoSelecionado = tecnico;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormFieldGenerico(
                controller:_descricaoController,
                label:'Descrição',
                validationMessage:'Por favor, digite uma breve descrição do problema relatado pelo cliente.',
              ),
              TipoServicoDropdown(
                onChanged: (valorSelecionado){
                  setState(() {
                    _tipoServicoSelecionado = valorSelecionado;
                  });
                }, 
                tipoServicoSelecionado: _tipoServicoSelecionado,
                enabled: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Cadastrar Ordem de Serviço'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
