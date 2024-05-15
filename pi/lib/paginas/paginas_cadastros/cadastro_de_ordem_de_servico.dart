import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pi/url.dart';


class CadastroDeOrdemDeServico extends StatefulWidget {
  const CadastroDeOrdemDeServico({Key? key}) : super(key: key);

  @override
  _CadastroDeOrdemDeServico createState() => _CadastroDeOrdemDeServico();
}
class _CadastroDeOrdemDeServico extends State<CadastroDeOrdemDeServico>{

   final _formKey = GlobalKey<FormState>();

  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _produtoExtraController = TextEditingController();
  final TextEditingController _relatorioTecnicoController = TextEditingController();
  final TextEditingController _custoTotalController = TextEditingController();

  String? _clienteSelecionado;
  String? _tecnicoSelecionado;
 
  @override
  void dispose() {
      _statusController.dispose();
      _descricaoController.dispose();
      _produtoExtraController.dispose();
      _relatorioTecnicoController.dispose();
      _custoTotalController.dispose();
      
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
   Future<http.Response> cadastrarOrdem() {
    final FuncionarioCadastro = {
      'ordemDeServicoDTO': {
      }
    };
    
    return http.post(
      Uri.parse(BackendUrls().getCadastrarOrdemAtendente()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(FuncionarioCadastro),
    );
   }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}