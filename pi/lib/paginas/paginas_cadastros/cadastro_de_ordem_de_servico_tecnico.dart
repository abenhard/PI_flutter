import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pi/widgets/cadastro/search_cliente.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pi/widgets/tipo_servico.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:pi/widgets/textFormFieldGenerico.dart';
import 'package:pi/widgets/statusEnum.dart';
import 'package:pi/url.dart';

class CadastroDeOrdemDeServicoTecnico extends StatefulWidget {
  const CadastroDeOrdemDeServicoTecnico({Key? key}) : super(key: key);

  @override
  _CadastroDeOrdemDeServicoTecnico createState() =>
      _CadastroDeOrdemDeServicoTecnico();
}

class _CadastroDeOrdemDeServicoTecnico
    extends State<CadastroDeOrdemDeServicoTecnico> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _relatorioTecnicoController =
      TextEditingController();
  final TextEditingController _produtoExtraController =
      TextEditingController();
  String? _clienteSelecionado;
  String? _tipoServicoSelecionado;
  DateTime? _dataPrevisao;
  Position? _currentPosition;
  List<File> _selectedFiles = [];
  Future<http.Response>? _futureResponse;

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
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _dataPrevisao) {
      setState(() {
        _dataPrevisao = picked;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')),
      );
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    print('Botao apertado');
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('Form validated');
      await _getCurrentLocation();
      setState(() {
        _futureResponse = cadastrarOrdem();
      });
    } else {
      print('Form validation failed');
    }
  }

  Future<http.Response> cadastrarOrdem() async {
    print('Sending request to backend');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String dataPrevisaoFormatted =
        _dataPrevisao != null ? dateFormat.format(_dataPrevisao!) : '';

    final ordemDeServicoTecnicoDTO = {
      'clienteCPF': _clienteSelecionado ?? '',
      'funcionariologin': '',
      'status': status.Aberta.toString(),
      'tipo_servico': _tipoServicoSelecionado ?? '',
      'descricao_problema': _descricaoController.text,
      'relatorio_tecnico': _relatorioTecnicoController.text,
      'produto_extra': _produtoExtraController.text,
      'data_previsao': dataPrevisaoFormatted,
      'localizacao': _currentPosition != null
          ? '${_currentPosition!.latitude},${_currentPosition!.longitude}'
          : ''
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(BackendUrls().postOrdemServicoTecnico()),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll(ordemDeServicoTecnicoDTO.map((key, value) =>
          MapEntry(key, value)));

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
    final List<String> options = ['Camera', 'Gallery'];
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Image Source'),
          children: options.map((option) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, option);
              },
              child: Text(option),
            );
          }).toList(),
        );
      },
    ).then((selectedOption) async {
      if (selectedOption != null) {
        XFile? pickedFile;
        if (selectedOption == 'Camera') {
          pickedFile = await picker.pickImage(source: ImageSource.camera);
        } else {
          pickedFile = await picker.pickImage(source: ImageSource.gallery);
        }
        if (pickedFile != null) {
          final path = pickedFile.path;
          setState(() {
            _selectedFiles.add(File(path));
          });
        }
      }
    });
  }

  Widget _buildImagePreview(File imageFile) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(8.0),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: FileImage(imageFile),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.cancel, color: Colors.red),
            onPressed: () {
              setState(() {
                _selectedFiles.remove(imageFile);
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Ordem de Serviço',
      body: FutureBuilder<http.Response>(
        future: _futureResponse,
        builder:
            (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'CADASTRANDO ORDEM DE SERVIÇO',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return _buildErrorScreen();
            } else if (snapshot.hasData) {
              return _buildResponseScreen(snapshot.data!);
            }
          }
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            SearchClientes(onClienteSelected: (cpf) {
              setState(() {
                _clienteSelecionado = cpf;
              });
            }),
            const SizedBox(height: 20),
            TextFormFieldGenerico(
              controller:  _descricaoController,
              label:  'Descrição',
              validationMessage:  'Digite uma breve descrição do problema relatado pelo cliente.',
              keyboardType: TextInputType.text,
              
            ),
            const SizedBox(height: 20),
            TipoServicoDropdown(
              onChanged: (valorSelecionado) {
                setState(() {
                  _tipoServicoSelecionado = valorSelecionado;
                });
              },
              tipoServicoSelecionado: _tipoServicoSelecionado,
              enabled: true,
            ),
            const SizedBox(height: 20),
            TextFormFieldGenerico(
              controller: _relatorioTecnicoController,
              label:'Relatório Técnico',
              validationMessage:'Digite os principais quais problemas encontrados e ação necessária para o conserto.',
            ),
            const SizedBox(height: 20),
            TextFormFieldGenerico(
              controller: _produtoExtraController,
              label:'Produto Extra',
              validationMessage:'Digite se necessário, qual(s) produto(s) necessário(s) para o conserto.',
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                _dataPrevisao == null
                    ? 'Nenhuma data selecionada'
                    : 'Data prevista para entrega: ${_dataPrevisao!.toLocal().toString().split(' ')[0]}',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectImages,
              child: const Text('Selecionar Imagens'),
            ),
            const SizedBox(height: 20),
            Wrap(
              children: _selectedFiles.map((file) => _buildImagePreview(file)).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Cadastrar Ordem de Serviço'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseScreen(http.Response response) {
    if (response.statusCode == 200) {
      return _buildSuccessScreen();
    } else {
      return _buildErrorScreen(response.body);
    }
  }

  Widget _buildSuccessScreen() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context);
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 100),
          SizedBox(height: 20),
          Text(
            'ORDEM DE SERVIÇO CADASTRADA COM SUCESSO',
            style: TextStyle(fontSize: 18, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen([String? message]) {
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _futureResponse = null;
      });
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 100),
          SizedBox(height: 20),
          Text(
            'FALHA AO CADASTRAR ORDEM DE SERVIÇO',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
