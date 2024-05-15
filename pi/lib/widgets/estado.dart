import 'package:flutter/material.dart';

class EstadoDropdown extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  final String? estadoSelecionado;

  const EstadoDropdown({
    Key? key,
    required this.onChanged,
    required this.estadoSelecionado,
  }) : super(key: key);

  @override
  _EstadoDropdownState createState() => _EstadoDropdownState();
}

class _EstadoDropdownState extends State<EstadoDropdown> {
  final List<String> estados = [
    'AC - Acre',
    'AL - Alagoas',
    'AP - Amapá',
    'AM - Amazonas',
    'BA - Bahia',
    'CE - Ceará',
    'DF - Distrito Federal',
    'ES - Espírito Santo',
    'GO - Goiás',
    'MA - Maranhão',
    'MT - Mato Grosso',
    'MS - Mato Grosso do Sul',
    'MG - Minas Gerais',
    'PA - Pará',
    'PB - Paraíba',
    'PR - Paraná',
    'PE - Pernambuco',
    'PI - Piauí',
    'RJ - Rio de Janeiro',
    'RN - Rio Grande do Norte',
    'RS - Rio Grande do Sul',
    'RO - Rondônia',
    'RR - Roraima',
    'SC - Santa Catarina',
    'SP - São Paulo',
    'SE - Sergipe',
    'TO - Tocantins',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.estadoSelecionado,
      onChanged: widget.onChanged,
      items: estados.map<DropdownMenuItem<String>>((estado) {
        return DropdownMenuItem<String>(
          value: estado,
          child: Text(estado),
        );
      }).toList(),
      decoration: InputDecoration(labelText: 'Estado'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, escolha um estado';
        }
        return null;
      },
    );
  }
}
