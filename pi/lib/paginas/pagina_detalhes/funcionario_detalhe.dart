import 'package:flutter/material.dart';
import 'package:pi/widgets/scaffold_base.dart';

class FuncionarioDetalhes extends StatelessWidget {
  final Map<String, dynamic> funcionario;

  const FuncionarioDetalhes({required this.funcionario, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldBase(
      title: 'Detalhes do Funcionário',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Nome: ${funcionario['pessoa']['nome']}'),
            Text('Cargo: ${funcionario['funcionario']['cargo']['nome']}'),
            Text('CPF: ${funcionario['pessoa']['cpf']}'),
            Text('Email: ${funcionario['pessoa']['email']}'),
            Text('Whatsapp: ${funcionario['pessoa']['whatsapp']}'),
            // Add more fields as necessary
          ],
        ),
      ),
    );
  }
}