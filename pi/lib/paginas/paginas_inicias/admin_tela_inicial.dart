import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pi/factories/botao_factory.dart';
import 'package:pi/routes.dart';
import 'package:pi/widgets/scaffold_base.dart';

class AdminTelaInicial extends StatelessWidget {
  const AdminTelaInicial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Tela Inicial',
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
                onPressed: () {
                 
                  Get.toNamed(Routes.cadastroDeCliente);
                },
                corBotao: Color.fromARGB(255, 27, 119, 194),
              ),
              const SizedBox(height: 15,),
              BotaoFactory(
                texto: 'Cadastro de Funcionário',
                onPressed: () {
                  
                  Get.toNamed(Routes.cadastroDeFuncionario);
                },
                corBotao: Color.fromARGB(255, 27, 119, 194),
              ),
              const SizedBox(height: 15,),
              BotaoFactory(
                texto: 'Cadastro de Ordem de Serviço',
                onPressed: () {
                  
                  Get.toNamed(Routes.cadastroDeOrdemDeServicoAtendente);
                },
                corBotao: Color.fromARGB(255, 27, 119, 194),
              ),
              const SizedBox(height: 15,),
              BotaoFactory(
                texto: 'Gerar Relatório',
                onPressed: () {
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
