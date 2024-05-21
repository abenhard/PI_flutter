import 'package:flutter/material.dart';


class TipoServicoDropdown extends StatefulWidget{
  final ValueChanged<String?> onChanged;
  final String? tipoServicoSelecionado;

  const TipoServicoDropdown({
    Key? key,
    required this.onChanged,
    required this.tipoServicoSelecionado,
  }) : super(key: key);

  @override
  _TipoServicoDropdownState createState() => _TipoServicoDropdownState();

}
class _TipoServicoDropdownState extends State<TipoServicoDropdown>{

  final List<String> tipoServicos = [
    'Manutenção',
    'Formatação',
    'Limpeza',
    'Instalação de Software',
    'Instalação de Hardware',
    'Outros'
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.tipoServicoSelecionado,
      onChanged: widget.onChanged,
      items: tipoServicos.map<DropdownMenuItem<String>>((tipoServico) {
        return DropdownMenuItem<String>(
          value: tipoServico,
          child: Text(tipoServico),
        );
      }).toList(),
      decoration: InputDecoration(labelText: 'Tipo de Serviço'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, escolha um Tipo de Serviço';
        }
        return null;
      },
    );
  }
}