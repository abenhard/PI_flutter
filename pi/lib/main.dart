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
  runApp(MaterialApp(
    home: MyApp(initialRoute: initialRoute),
  ));
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
      home: FutureBuilder<String>(
        future: getUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text(snapshot.data ?? "ABF Informática"),
              ),
              body: GetRouterOutlet(initialRoute: initialRoute),
            );
          }
        },
      ),
    );
  }

  Future<String> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('login');
    return username ?? "ABF Informática";
  }
}
