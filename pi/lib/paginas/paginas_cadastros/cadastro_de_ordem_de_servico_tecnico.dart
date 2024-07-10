import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  bool _isLoading = false;
  String? _submitStatusMessage;
  bool _isSubmitSuccess = false;

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
        const SnackBar(content: Text('Serviço de localização está desativado, por favor reative.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sem permissão de localização, por favor mude as permissões.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Permissão de localização negada permanentemente, por favor mude as permissões.')),
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _getCurrentLocation();
      setState(() {
        _isLoading = true;
        _submitStatusMessage = null;
      });
      final response = await cadastrarOrdem();
      setState(() {
        _isLoading = false;
        _isSubmitSuccess = response.statusCode == 200;
        _submitStatusMessage = _isSubmitSuccess
            ? 'Ordem de serviço cadastrada com sucesso!'
            : 'Erro ao cadastrar ordem de serviço: ${response.body}';
      });
    }
  }

  Future<http.Response> cadastrarOrdem() async {
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

  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final image = img.decodeImage(file.readAsBytesSync());
    final compressedImage = img.encodeJpg(image!, quality: 85);
    final compressedFile = File('$path/${file.uri.pathSegments.last}');
    await compressedFile.writeAsBytes(compressedImage);
    return compressedFile;
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
          final compressedFile = await compressImage(File(path));
          setState(() {
            _selectedFiles.add(compressedFile);
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
      body: _isLoading
          ? Center(
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
            )
          : _submitStatusMessage != null
              ? Center(
                  child: Container(
                    color: _isSubmitSuccess ? Colors.green : Colors.red,
                    child: Center(
                      child: Text(
                        _submitStatusMessage!,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Padding(
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
              },
            ),
            const SizedBox(height: 20),
            TextFormFieldGenerico(
              controller: _descricaoController,
              label: 'Descrição',
              validationMessage:
                  'Digite uma breve descrição do problema relatado pelo cliente.',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            TipoServicoDropdown(
              enabled: true,
              tipoServicoSelecionado: _tipoServicoSelecionado,
              onChanged: (valorSelecionado) {
                setState(() {
                  _tipoServicoSelecionado = valorSelecionado;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(_dataPrevisao == null
                  ? 'Selecionar Data de Previsão'
                  : 'Data Selecionada: ${DateFormat('dd/MM/yyyy').format(_dataPrevisao!)}'),
            ),
            const SizedBox(height: 20),
            TextFormFieldGenerico(
              controller: _produtoExtraController,
              label: 'Produto Extra',
              validationMessage: 'Digite o produto utilizado ou necessário.',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            TextFormFieldGenerico(
              controller: _relatorioTecnicoController,
              label: 'Relatório Técnico',
              validationMessage: 'Digite o relatorio técnico.',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _selectImages,
              child: const Text('Adicionar Fotos'),
            ),
            const SizedBox(height: 20),
            Wrap(
              children: _selectedFiles.map(_buildImagePreview).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Cadastrar Ordem'),
            ),
          ],
        ),
      ),
    );
  }
}
