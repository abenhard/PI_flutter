import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pi/factories/botao_factory.dart';
import 'package:pi/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminTelaInicial extends StatelessWidget {
  const AdminTelaInicial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(
            iconSize: 40,
            icon: const Icon(Icons.person),
            onPressed: () async {
              // Clear token from SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_token');
              // Navigate to login screen
              Get.offAllNamed(Routes.login);
            }
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 55,),
              BotaoFactory(
                texto: 'Consulta de Cliente',
                onPressed: () {
                  Get.toNamed(Routes.consultaDeCliente);
                },
                corBotao: Colors.lightBlue,
              ),
              const SizedBox(height: 15,),
              BotaoFactory(
                texto: 'Consulta de Funcionário',
                onPressed: () {
                  Get.toNamed(Routes.consultaDeFuncionario);
                },
                corBotao: Colors.lightBlue,
              ),
              const SizedBox(height: 15,),
              BotaoFactory(
                texto: 'Consulta de Ordem de Serviço',
                onPressed: () {
                  Get.toNamed(Routes.consultaDeOrdemDeServico);
                },
                corBotao: Colors.lightBlue,
              ), 
              const SizedBox(height: 15,),
              BotaoFactory(
                texto: 'Cadastro de Cliente', 
                onPressed: (){
                  print('Cadastro de Cliente');
                  Get.toNamed(Routes.cadastroDeCliente);
                }, 
                corBotao: Color.fromARGB(255, 27, 119, 194),
              ),
              const SizedBox(height: 15,),
              BotaoFactory(
                texto: 'Cadastro de Funcionário', 
                onPressed: (){
                  print('Cadastro de Funcionário');
                  Get.toNamed(Routes.cadastroDeFuncionario);
                }, 
                corBotao: Color.fromARGB(255, 27, 119, 194),
              ),
              const SizedBox(height: 15,),
              BotaoFactory(
                texto: 'Cadastro de Ordem de Serviço', 
                onPressed: (){
                  print('Cadastro de Ordem de Serviço');
                  Get.toNamed(Routes.cadastroDeOrdemDeServico);
                }, 
                corBotao: Color.fromARGB(255, 27, 119, 194),
              ), 
              const SizedBox(height: 15,),
              BotaoFactory(
                texto: 'Gerar Relatório', 
                onPressed: (){
                  print('Gerar Relatório');
                }, 
                corBotao: Color.fromARGB(255, 235, 123, 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
