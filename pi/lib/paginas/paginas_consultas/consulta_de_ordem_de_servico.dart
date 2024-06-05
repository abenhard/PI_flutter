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
import 'package:pi/main.dart';  // Ensure to import the main file where routeObserver is defined

class ConsultaDeOrdemDeServico extends StatefulWidget {
  const ConsultaDeOrdemDeServico({Key? key}) : super(key: key);

  @override
  _ConsultaDeOrdemDeServicoState createState() => _ConsultaDeOrdemDeServicoState();
}

class _ConsultaDeOrdemDeServicoState extends State<ConsultaDeOrdemDeServico> with RouteAware {
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
      Uri.parse('${BackendUrls().getOrdem()}'),
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
        final clienteCPF = order['clienteCPF']?.toLowerCase() ?? '';
        final status = order['status']?.toLowerCase() ?? '';

        return clienteNome.contains(searchTerm.toLowerCase()) ||
               clienteCPF.contains(searchTerm.toLowerCase()) ||
               status.contains(searchTerm.toLowerCase());
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
      title: 'Consulta de Ordem de Serviço',
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
                      labelText: 'Buscar por Nome, CPF ou Status',
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
                final clienteCPF = order['clienteCPF'] ?? 'CPF desconhecido';           
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
                        Text('CPF: $clienteCPF'),               
                        Text('Tipo de Serviço: $tipoServico'),
                        Text('Data de Criação: $formattedDate'),
                        Text('Descrição: $descricaoProblema'),
                        Text('Status: $status'),
                      ],
                    ),
                    onTap: () {
                      Get.to(() => OrdemDetalhes(ordem: order, imageUrls: imageUrls));
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
                    Get.toNamed(Routes.cadastroDeOrdemDeServicoAtendente);
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
