import 'package:flutter/material.dart';
import 'package:pi/factories/botao_factory.dart';
import 'package:pi/widgets/scaffold_base.dart';

class AtendenteTelaInicial extends StatelessWidget{
  const AtendenteTelaInicial({super.key});


  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Atendente',
    body: 
    SingleChildScrollView(
      child: Form(
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 55,),
            BotaoFactory(
              texto: 'Consultar de Cliente', 
              onPressed: (){print('Consultar de Cliente');}, 
              corBotao: Colors.lightBlue,
              ),
             
              const SizedBox(height: 15,),
              BotaoFactory(
              texto: 'Consultar de Ordem de Serviço', 
              onPressed: (){print('Consultar de Ordem de Serviço');}, 
              corBotao: Colors.lightBlue,
              ), 
              const SizedBox(height: 15,),
              BotaoFactory(
              texto: 'Cadastro de Cliente', 
              onPressed: (){print('Cadastro de Cliente');}, 
              corBotao: Color.fromARGB(255, 27, 119, 194),
              ),
              const SizedBox(height: 15,),
              BotaoFactory(
              texto: 'Cadastro de Ordem de Serviço', 
              onPressed: (){print('Cadastro de Ordem de Serviço');}, 
              corBotao:  Color.fromARGB(255, 27, 119, 194),
              )
          ],
        ),),
    ),
    ),
    );
  }
}