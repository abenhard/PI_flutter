import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pi/url.dart';
import 'package:pi/widgets/scaffold_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pi/routes.dart';

class TecnicoTelaInicial extends StatefulWidget {
  const TecnicoTelaInicial({Key? key}) : super(key: key);

  @override
  _TecnicoTelaInicialState createState() => _TecnicoTelaInicialState();
}

class _TecnicoTelaInicialState extends State<TecnicoTelaInicial> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> allOrders = [];
  List<dynamic> filteredOrders = [];
  String _searchTerm = '';
  String? _username;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('login');
    if (username != null) {
      setState(() {
        _username = username;
      });
      await _fetchOrders();
    }
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
    _searchTerm = searchTerm;
    filteredOrders = allOrders.where((order) {
      final clienteNome = order['clienteNome'].toLowerCase();
      final clienteCpf = order['clienteCpf'].toLowerCase();
      return clienteNome.contains(searchTerm.toLowerCase()) || clienteCpf.contains(searchTerm.toLowerCase());
    }).toList();
  });
}


  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Técnico',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por Nome ou CPF',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterOrders,
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Abertas'),
              Tab(text: 'Em Espera'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList('aberta'),
                _buildOrderList('em espera'),
              ],
            ),
          ),
        ],
      ),
    );
  }
Widget _buildOrderList(String status) {
  List<dynamic> orders = filteredOrders.where((order) => order['status'] == status).toList();

  return ListView.builder(
    itemCount: orders.length,
    itemBuilder: (context, index) {
      final order = orders[index];
      return Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: ListTile(
          title: Text(order['clienteNome']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tipo de Serviço: ${order['tipoServico']}'),
              Text('Data de Criação: ${order['dataCriacao']}'),
              Text('Descrição: ${order['descricaoProblema']}'),
            ],
          ),
          onTap: () {
            // Navegar para a tela da ordem
          },
        ),
      );
    },
  );
}


}