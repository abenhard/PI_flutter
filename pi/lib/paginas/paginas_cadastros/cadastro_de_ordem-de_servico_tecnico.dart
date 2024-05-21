import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pi/widgets/tipo_servico.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi/url.dart';
import 'package:pi/widgets/cadastro/buscar_cliente.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:pi/widgets/cadastro/tecnico_dropdown.dart';
import 'package:pi/widgets/textFormFieldGenerico.dart';
import 'package:pi/widgets/statusEnum.dart';

class CadastroDeOrdemDeServicoTecnico extends StatefulWidget {
  const CadastroDeOrdemDeServicoTecnico({Key? key}) : super(key: key);

  @override
  _CadastroDeOrdemDeServicoTecnico createState() => _CadastroDeOrdemDeServicoTecnico();
}

class _CadastroDeOrdemDeServicoTecnico extends State<CadastroDeOrdemDeServicoTecnico> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _relatorioTecnicoController = TextEditingController();
  final TextEditingController _produtoExtraController = TextEditingController();
  String? _clienteSelecionado;
  String? _tecnicoSelecionado;
  String? _tipoServicoSelecionado;
  DateTime? _dataPrevisao;
  Position? _currentPosition;
  List<File> _selectedFiles = [];

  @override
  void dispose() {
    _descricaoController.dispose();
    _relatorioTecnicoController.dispose();
    _produtoExtraController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dataPrevisao)
      setState(() {
        _dataPrevisao = picked;
      });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, don't continue
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, don't continue
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _getCurrentLocation();  // Ensure location is fetched before submitting
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

    final ordemDeServicoTecnicoDTO = {
      'clienteCPF': _clienteSelecionado ?? '',
      'funcionariologin': _tecnicoSelecionado ?? '',
      'status': status.Aberta.toString(),
      'tipo_servico': _tipoServicoSelecionado ?? '',
      'descricao_problema': _descricaoController.text,
      'relatorio_tecnico': _relatorioTecnicoController.text,
      'produto_extra': _produtoExtraController.text,
      'data_previsao': _dataPrevisao?.toIso8601String() ?? '',
      'localizacao': _currentPosition != null ? '${_currentPosition!.latitude},${_currentPosition!.longitude}' : ''
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(BackendUrls().getCadastrarOrdemTecnico()),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll(ordemDeServicoTecnicoDTO.map((key, value) => MapEntry(key, value ?? '')));

    for (var file in _selectedFiles) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'fotos',
          file.path,
        ),
      );
    }

    var response = await request.send();
    return http.Response.fromStream(response);
  }

  Future<void> _selectImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedFiles = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
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
              BuscarCliente(
                onClienteSelecionado: (String cliente) {
                  setState(() {
                    _clienteSelecionado = cliente;
                  });
                },
              ),
              const SizedBox(height: 20),
              TecnicoDropdown(
                onTecnicoSelected: (String tecnico) {
                  setState(() {
                    _tecnicoSelecionado = tecnico;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormFieldGenerico(
                _descricaoController,
                'Descrição',
                'Por favor, digite uma breve descrição do problema relatado pelo cliente.',
              ),
              TipoServicoDropdown(
                onChanged: (valorSelecionado) {
                  setState(() {
                    _tipoServicoSelecionado = valorSelecionado;
                  });
                },
                tipoServicoSelecionado: _tipoServicoSelecionado,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(_dataPrevisao == null
                    ? 'Nenhuma data selecionada'
                    : 'Data prevista: ${_dataPrevisao!.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ElevatedButton(
                onPressed: _selectImages,
                child: const Text('Selecionar Imagens'),
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
