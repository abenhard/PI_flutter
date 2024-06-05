import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pi/factories/botao_factory.dart';
import 'package:pi/paginas/pagina_detalhes/ordem_detalhe.dart';
import 'package:pi/url.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pi/routes.dart';
import 'package:pi/main.dart';

class TecnicoTelaInicial extends StatefulWidget {
  const TecnicoTelaInicial({Key? key}) : super(key: key);

  @override
  _TecnicoTelaInicialState createState() => _TecnicoTelaInicialState();
}

class _TecnicoTelaInicialState extends State<TecnicoTelaInicial> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> allOrders = [];
  List<dynamic> filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route as PageRoute<dynamic>);
    }
  }

  @override
  void dispose() {
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchOrders();
    super.didPopNext();
  }

  Future<void> _fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse('${BackendUrls().getOrdemServicoTecnico()}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        allOrders = json.decode(response.body);
        filteredOrders = allOrders;
      });
    } else {
      // Handle error
      throw Exception('Failed to load orders');
    }
  }

  void _filterOrders(String searchTerm) {
    setState(() {
      filteredOrders = allOrders.where((order) {
        final clienteNome = order['clienteNome']?.toLowerCase() ?? '';
        
        final clienteCpf = order['clienteCPF']?.toLowerCase() ?? '';
        return clienteNome.contains(searchTerm.toLowerCase()) || clienteCpf.contains(searchTerm.toLowerCase());
      }).toList();
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Todas'),
              onTap: () {
                setState(() {
                  filteredOrders = allOrders;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Abertas'),
              onTap: () {
                setState(() {
                  filteredOrders = allOrders.where((order) => order['status']?.toLowerCase() == 'aberta').toList();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Em Espera'),
              onTap: () {
                setState(() {
                  filteredOrders = allOrders.where((order) => order['status']?.toLowerCase() == 'em espera').toList();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Técnico',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por Nome ou CPF',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterOrders,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: _showFilterOptions,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                final clienteNome = order['clienteNome'] ?? 'Nome desconhecido';
                final tipoServico = order['tipo_servico'] ?? 'Tipo de serviço desconhecido';
                final dataCriacao = order['data_criacao'] ?? 'Data de criação desconhecida';
                final descricaoProblema = order['descricao_problema'] ?? 'Descrição desconhecida';
                final status = order['status'] ?? 'Status desconhecido';
                final List<String> imageUrls = order['imageUrls'] != null ? List<String>.from(order['imageUrls']) : [];

                
                // Format the date
                final formattedDate = dataCriacao != 'Data de criação desconhecida'
                    ? DateFormat('dd-MM-yyyy').format(DateTime.parse(dataCriacao))
                    : dataCriacao;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    title: Text(clienteNome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo de Serviço: $tipoServico'),
                        Text('Data de Criação: $formattedDate'),
                        Text('Descrição: $descricaoProblema'),
                        Text('Status: $status')
                      ],
                    ),
                    onTap: () {
                      Get.to(() => OrdemDetalhes(ordem: order, imageUrls: imageUrls,));
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BotaoFactory(
                  texto: 'Cadastrar Ordem de Serviço',
                  onPressed: () {
                    Get.toNamed(Routes.cadastroDeOrdemDeServicoTecnico);
                  },
                  corBotao: Colors.lightBlue,
                ),
                SizedBox(height: 20),
                BotaoFactory(
                  texto: 'Cadastrar Cliente',
                  onPressed: () {
                    Get.toNamed(Routes.cadastroDeCliente);
                  },
                  corBotao: Colors.lightBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}