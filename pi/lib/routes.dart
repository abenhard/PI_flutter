import 'package:get/get.dart';
import 'package:pi/paginas/login/login.dart';
import 'package:pi/paginas/paginas_cadastros/cadastro_de_cliente.dart';
import 'package:pi/paginas/paginas_cadastros/cadastro_de_funcionario.dart';
import 'package:pi/paginas/paginas_cadastros/cadastro_de_ordem_de_servico.dart';
import 'package:pi/paginas/paginas_consultas/consulta_de_cliente.dart';
import 'package:pi/paginas/paginas_consultas/consulta_de_funcionario.dart';
import 'package:pi/paginas/paginas_consultas/consulta_de_ordem_de_servico.dart';
import 'package:pi/paginas/paginas_inicias/admin_tela_inicial.dart';
import 'package:pi/paginas/paginas_inicias/atendente_tela_inicial.dart';
import 'package:pi/paginas/paginas_inicias/tecnico_tela_inicial.dart';

class Routes {
  static const String login = '/login';
  static const String adminTelaInicial = '/admin_tela_inicial';
  static const String tecnicoTelaInicial = '/tecnico_tela_inicial';
  static const String atendenteTelaInicial = '/atendente_tela_inicial';
  static const String consultaDeCliente = '/consulta_de_cliente';
  static const String consultaDeFuncionario = '/consulta_de_funcionario';
  static const String consultaDeOrdemDeServico = '/consulta_de_ordem_de_servico';
  static const String cadastroDeCliente = '/cadastro_de_cliente';
  static const String cadastroDeFuncionario = '/cadastro_de_funcionario';
  static const String cadastroDeOrdemDeServico = '/cadastro_de_ordem_de_servico';

  static final List<GetPage> pages = [
    GetPage(name: login, page: () => Login()),
    GetPage(name: adminTelaInicial, page: () => AdminTelaInicial()),
    GetPage(name: tecnicoTelaInicial, page: () => TecnicoTelaInicial()),
    GetPage(name: atendenteTelaInicial, page: () => AtendenteTelaInicial()),
    GetPage(name: consultaDeCliente, page: () => ConsultaDeCliente()),
    GetPage(name: consultaDeFuncionario, page: () => ConsultaDeFuncionario()),
    GetPage(name: consultaDeOrdemDeServico, page: () => ConsultaDeOrdemDeServico()),
    GetPage(name: cadastroDeCliente, page: () => CadastroDeCliente()),
    GetPage(name: cadastroDeFuncionario, page: () => CadastroDeFuncionario()),
    GetPage(name: cadastroDeOrdemDeServico, page: () => CadastroDeOrdemDeServico()),
  ];
}
