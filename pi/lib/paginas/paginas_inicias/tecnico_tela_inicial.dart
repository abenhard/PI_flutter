import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pi/widgets/ordem_de_servico_list.dart';
import 'package:pi/url.dart';
import 'package:pi/routes.dart';
import 'package:pi/factories/botao_factory.dart';

class TecnicoTelaInicial extends StatelessWidget {
  const TecnicoTelaInicial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrdemDeServicoList(
      title: 'Técnico',
      backendUrl: BackendUrls().getOrdemServicoTecnico(),
      cadastroRoute: Routes.cadastroDeOrdemDeServicoTecnico,
      additionalButtons: [ // Pass the additional buttons
        BotaoFactory(
          texto: 'Cadastrar Cliente',
          onPressed: () {
            Get.toNamed(Routes.cadastroDeCliente);
          },
          corBotao: Colors.lightBlue,
        ),
      ],
    );
  }
}
