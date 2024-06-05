import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pi/widgets/textFormFieldGenerico.dart';
import 'package:pi/widgets/tipo_servico.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:pi/url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrdemDetalhes extends StatefulWidget {
  final dynamic ordem;
  final List<dynamic> imageUrls;

  OrdemDetalhes({Key? key, required this.ordem, required this.imageUrls}) : super(key: key);

  @override
  _OrdemDetalhesState createState() => _OrdemDetalhesState();
}

class _OrdemDetalhesState extends State<OrdemDetalhes> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  late TextEditingController _descricaoController;
  late TextEditingController _produtoExtraController;
  late TextEditingController _clienteNomeController;
  String? _tipoServicoSelecionado;
  DateTime? _dataPrevisao;
  List<File> _selectedFiles = [];
  List<String> _imageUrls = [];
  String? _token;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.ordem['descricao_problema']);
    _produtoExtraController = TextEditingController(text: widget.ordem['produto_extra']);
    _clienteNomeController = TextEditingController(text: widget.ordem['clienteNome']);
    _tipoServicoSelecionado = widget.ordem['tipo_servico'];
    _dataPrevisao = widget.ordem['data_previsao'] != null ? DateTime.parse(widget.ordem['data_previsao']) : null;
    _imageUrls = List<String>.from(widget.imageUrls);
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('jwt_token');
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataPrevisao ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _dataPrevisao) {
      setState(() {
        _dataPrevisao = picked;
      });
    }
  }

  Future<void> _updateOrdem() async {
    if (_formKey.currentState!.validate()) {
      if (_token == null) {
        print('JWT token is null');
        return;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${BackendUrls().updateOrdemServicoTecnico()}'),
      )
        ..headers['Authorization'] = 'Bearer $_token'
        ..fields['clienteNome'] = _clienteNomeController.text
        ..fields['tipo_servico'] = _tipoServicoSelecionado ?? ''
        ..fields['descricao_problema'] = _descricaoController.text
        ..fields['produto_extra'] = _produtoExtraController.text
        ..fields['data_previsao'] = _dataPrevisao?.toIso8601String() ?? '';

      for (var file in _selectedFiles) {
        request.files.add(await http.MultipartFile.fromPath('fotos', file.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        Get.back(result: true);
      } else {
        throw Exception('Failed to update order');
      }
    }
  }

  Future<void> _selectImages() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    if (_token == null) {
      print('JWT token is null');
      return;
    }

    final response = await http.delete(
      Uri.parse('${BackendUrls().deleteImage()}'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'imageUrl': imageUrl}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _imageUrls.remove(imageUrl);
      });
    } else {
      throw Exception('Failed to delete image');
    }
  }

  Future<ImageProvider> _fetchImageWithToken(String imageUrl) async {
    if (_token == null) {
      print('JWT token is null');
      throw Exception('JWT token is null');
    }

    final response = await http.get(
      Uri.parse(imageUrl),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return NetworkImage(imageUrl);
    } else {
      throw Exception('Failed to load image');
    }
  }

  Widget _buildNetworkImagePreview(String imageUrl) {
    return FutureBuilder<ImageProvider>(
      future: _fetchImageWithToken(imageUrl),
      builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: EdgeInsets.all(8.0),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[300],
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            margin: EdgeInsets.all(8.0),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[300],
            ),
            child: Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          );
        } else {
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.all(8.0),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: snapshot.data!,
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
                    _deleteImage(imageUrl);
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildFileImagePreview(File imageFile) {
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
      title: 'Detalhes da Ordem',
      body: _token == null
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  TextFormFieldGenerico(
                    controller: _clienteNomeController,
                    label: 'Nome do Cliente',
                    validationMessage: 'Por favor, insira o nome do cliente',
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 16.0),
                  TextFormFieldGenerico(
                    controller: _descricaoController,
                    label: 'Descrição do Problema',
                    validationMessage: 'Por favor, insira a descrição do problema',
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 16.0),
                  TipoServicoDropdown(
                    tipoServicoSelecionado: _tipoServicoSelecionado,
                    enabled: _isEditing,
                    onChanged: _isEditing
                        ? (newValue) {
                            setState(() {
                              _tipoServicoSelecionado = newValue;
                            });
                          }
                        : (newValue){} ,              
                  ),
                  SizedBox(height: 16.0),
                  TextFormFieldGenerico(
                    controller: _produtoExtraController,
                    label: 'Produto Extra',
                    validationMessage: 'Por favor, insira o produto extra',
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 16.0),
                  ListTile(
                    title: Text('Data de Previsão'),
                    subtitle: Text(
                      _dataPrevisao != null ? DateFormat('dd-MM-yyyy').format(_dataPrevisao!) : 'Nenhuma data selecionada',
                    ),
                    trailing: _isEditing ? Icon(Icons.calendar_today) : null,
                    onTap: _isEditing ? () => _selectDate(context) : null,
                  ),
                  SizedBox(height: 16.0),
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: _selectImages,
                      child: Text('Selecionar Imagens'),
                    ),
                  SizedBox(height: 16.0),
                  Wrap(
                    children: [
                      ..._imageUrls.map((imageUrl) => _buildNetworkImagePreview(imageUrl)).toList(),
                      ..._selectedFiles.map((file) => _buildFileImagePreview(file)).toList(),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: _updateOrdem,
                      child: Text('Salvar'),
                    ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    child: Text(_isEditing ? 'Cancelar' : 'Editar'),
                  ),
                ],
              ),
            ),
    );
  }
}
