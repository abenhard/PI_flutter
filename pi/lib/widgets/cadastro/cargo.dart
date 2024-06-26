import 'package:flutter/material.dart';

class CargoDropdown extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  final String? cargoSelecionado;
  final bool enabled;

  const CargoDropdown({
    Key? key,
    required this.onChanged,
    required this.cargoSelecionado,
    required this.enabled,
  }) : super(key: key);

  @override
  _CargoDropdownState createState() => _CargoDropdownState();
}

class _CargoDropdownState extends State<CargoDropdown> {
  final List<String> cargos = [
    'ADMIN',
    'TECNICO',
    'ATENDENTE'
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.cargoSelecionado,
      onChanged: widget.enabled ? widget.onChanged : null,
      items: cargos.map((cargo) {
        return DropdownMenuItem<String>(
          value: cargo,
          child: Text(cargo),
        );
      }).toList(),
      decoration: InputDecoration(labelText: 'Cargo'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, escolha um cargo';
        }
        return null;
      },
    );
  }
}
