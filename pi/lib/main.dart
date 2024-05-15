import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pi/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt_token');

  String initialRoute = Routes.login;

  if (token != null && !JwtDecoder.isExpired(token)) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    //prefs.setString('login', decodedToken['Login']);
    String userAuthority = decodedToken['ROLE'];
    switch (userAuthority) {
      case 'ADMIN':
        initialRoute = Routes.adminTelaInicial;
        break;
      case 'TECNICO':
        initialRoute = Routes.tecnicoTelaInicial;
        break;
      case 'ATENDENTE':
        initialRoute = Routes.atendenteTelaInicial;
        break;
      default:
        initialRoute = Routes.login;
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(useMaterial3: true),
      initialRoute: initialRoute,
      getPages: Routes.pages,
    );
  }
}
