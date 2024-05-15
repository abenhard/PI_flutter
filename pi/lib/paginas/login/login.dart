import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pi/routes.dart';
import 'package:pi/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String initialRoute = Routes.login;
  bool isLoading = false;

  Future<void> _login() async {
    var url = Uri.parse(BackendUrls().getLogin());

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; 
      });

      String login = _loginController.text.trim();
      String password = _passwordController.text.trim();

      try {
        var response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'login': login,
            'senha': password,
          }),
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          String token = response.body;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);

          if (JwtDecoder.isExpired(token)) {
            _scaffoldKey.currentState?.showSnackBar(
              const SnackBar(content: Text('Sessão expirada. Logar novamente.')),
            );
          } else {
            Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
            String autoridade = decodedToken['ROLE'];

            String? username = decodedToken['login'];
            await prefs.setString('login', username ?? '');

            switch (autoridade) {
              case 'ADMIN':
                setState(() {
                  initialRoute = Routes.adminTelaInicial;
                });
                break;
              case 'TECNICO':
                setState(() {
                  initialRoute = Routes.tecnicoTelaInicial;
                });
                break;
              case 'ATENDENTE':
                setState(() {
                  initialRoute = Routes.atendenteTelaInicial;
                });
                break;
              default:
                _scaffoldKey.currentState?.showSnackBar(
                  const SnackBar(content: Text('No valid ROLE found')),
                );
            }

            // Após definir a nova rota inicial, navegue para ela
            Navigator.pushReplacementNamed(context, initialRoute);
          }
        } else {
          _scaffoldKey.currentState?.showSnackBar(
            SnackBar(content: Text('Login failed: ${response.statusCode}')),
          );
        }
      } catch (error) {
        if (!mounted) return;

        print('Error: $error');
        _scaffoldKey.currentState?.showSnackBar(
          SnackBar(content: Text('An error occurred')),
        );
      } finally {
        setState(() {
          isLoading = false; // Desativar indicador de progresso
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Image.asset('assets/imagens/logo.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextFormField(
                    controller: _loginController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Login Incorreto';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Login',
                        hintText: 'Digite seu Login'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 20),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Senha Incorreta';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Senha',
                        hintText: 'Digite sua senha'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    print('Tela Esqueceu a Senha');
                  },
                  child: const Text('Esqueci a senha',
                      style: TextStyle(color: Colors.blue, fontSize: 18)),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isLoading ? null : _login, // Desativar o botão durante o carregamento
                  child: isLoading
                      ? CircularProgressIndicator() // Mostrar indicador de progresso
                      : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
