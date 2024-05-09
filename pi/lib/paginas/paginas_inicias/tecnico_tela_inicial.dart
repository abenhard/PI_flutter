import 'package:flutter/material.dart';
import 'package:pi/factories/botao_factory.dart';
// ignore: unused_import
import 'package:pi/factories/cartao_ordem_de_servico.dart';

class TecnicoTelaInicial extends StatelessWidget{
 const  TecnicoTelaInicial({super.key});

static const List<String> entries = <String>['A', 'B', 'C','D','E'];
static const List<int> colorCodes = <int>[600, 500, 100,150,600];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      title: const Text('Técnico'),
      actions: [
            IconButton(
              iconSize: 40,
              icon: Icon(Icons.person),
              onPressed: () {
                print('Botão de menu');
              },
            ),
          ]
    ),
    body: 
       Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 15,),
            Container(
              height: 500,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder( 
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: entries.length,
                  itemBuilder: (BuildContext context, int index) {
                     return Container(
                        height: 170,
                        color: Colors.amber[colorCodes[index]],
                        child: Center(child: Text('Entry ${entries[index]}')),
                  );
                 }
                  ),
              ),
            ),
            const SizedBox(height: 70,),
            BotaoFactory(
              texto: 'Cadastro de Ordem de Serviço', 
              onPressed: (){print('Cadastro de Ordem de Serviço');}, 
              corBotao:  Color.fromARGB(255, 27, 119, 194),
            )
          ],
        ),),
    );
  }
}