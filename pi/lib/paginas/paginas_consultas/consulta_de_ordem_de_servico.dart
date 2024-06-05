import 'package:flutter/material.dart';
import 'package:pi/widgets/ordem_de_servico_list.dart';
import 'package:pi/url.dart';
import 'package:pi/routes.dart';

class ConsultaDeOrdemDeServico extends StatelessWidget {
  const ConsultaDeOrdemDeServico({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrdemDeServicoList(
      title: 'Consulta de Ordem de Serviço',
      backendUrl: BackendUrls().getOrdem(),
      cadastroRoute: Routes.cadastroDeOrdemDeServicoAtendente,
    );
  }
}
