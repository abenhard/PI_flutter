import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BotaoFactory extends StatelessWidget{
  String texto='';
  VoidCallback onPressed = (){};
  Color  corBotao= Colors.white;
  
  BotaoFactory({super.key, required String texto, required VoidCallback onPressed, required Color corBotao}){
    this.texto = texto;
    this.onPressed = onPressed;
    this.corBotao = corBotao;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 320,
      decoration: BoxDecoration(
        color: corBotao,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          texto,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
