import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CartaoOrdemDeServico extends StatelessWidget{
  
  String numeroOrdem ='';
  String nomeCliente='';
  String tipoServico='';
  DateTime dataPrevisaoEntrega =DateTime.now();
  String status ='';
  
  CartaoOrdemDeServico({super.key, 
  required String numeroOrdem, required String nomeCliente,required String tipoServico, 
  required String status, required DateTime dataPrevisaoEntrega}){
    this.numeroOrdem = numeroOrdem;
    this.nomeCliente = nomeCliente;
    this.tipoServico = tipoServico;
    this.status = status;
    this.dataPrevisaoEntrega = dataPrevisaoEntrega;
  }
  

  @override
  Widget build(BuildContext context) {
    return Card(
       clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            debugPrint('Card tapped.');
          },
          child: const SizedBox(
            child: Column(
              children: [
              ],
            ),
          ),
        )
    );
  }}