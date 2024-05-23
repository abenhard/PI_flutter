import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pi/widgets/tipo_servico.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi/url.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:pi/widgets/textFormFieldGenerico.dart';
import 'package:pi/widgets/statusEnum.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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
  final TextEditingController _searchController = TextEditingController();
  String? _clienteSelecionado;
  String? _tipoServicoSelecionado;
  DateTime? _dataPrevisao;
  Position? _currentPosition;
  List<File> _selectedFiles = [];
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    _relatorioTecnicoController.dispose();
    _produtoExtraController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
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
        const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
      );
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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

    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String dataPrevisaoFormatted = _dataPrevisao != null ? dateFormat.format(_dataPrevisao!) : '';

    final ordemDeServicoTecnicoDTO = {
      'clienteCPF': _clienteSelecionado ?? '',
      'funcionariologin': '',
      'status': status.Aberta.toString(),
      'tipo_servico': _tipoServicoSelecionado ?? '',
      'descricao_problema': _descricaoController.text,
      'relatorio_tecnico': _relatorioTecnicoController.text,
      'produto_extra': _produtoExtraController.text,
      'data_previsao': dataPrevisaoFormatted,
      'localizacao': _currentPosition != null ? '${_currentPosition!.latitude},${_currentPosition!.longitude}' : ''
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(BackendUrls().postOrdemServicoTecnico()),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll(ordemDeServicoTecnicoDTO.map((key, value) => MapEntry(key, value)));

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
    // Handle errors
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
                setState(() {
                  _clienteSelecionado = cliente['cpf'];
                  _searchResults = [];
                  _isSearching = false; // Close the search UI
                  _searchController.text = cliente['nome']; // Display selected client
                });
              },
            );
          },
        );
}


  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Ordem de Serviço',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar Cliente',
                  hintText: 'Digite o nome ou CPF',
                ),
                onChanged: _searchClientes,
              ),
              _buildSearchResults(),
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
                title: Text(
                  _dataPrevisao == null
                      ? 'Nenhuma data selecionada'
                      : 'Data prevista: ${_dataPrevisao!.toLocal().toString().split(' ')[0]}',
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
      ),
    );
  }
}
