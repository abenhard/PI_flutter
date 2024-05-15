import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi/routes.dart';

class ScaffoldBase extends StatefulWidget {
  final Widget body;
  final String title;
  final bool mostrarIcone;

  ScaffoldBase({required this.body, required this.title, this.mostrarIcone = true});

  @override
  _ScaffoldBaseState createState() => _ScaffoldBaseState();
}

class _ScaffoldBaseState extends State<ScaffoldBase> {
  late String _title;
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _checkLoggedInStatus();
  }

  Future<void> _checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('jwt_token') != null;
    });
  }
  void updateTitle(String newTitle) {
    setState(() {
      _title = newTitle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: widget.mostrarIcone
     && _isLoggedIn ? [
          IconButton(
            iconSize: 40,
            icon: const Icon(Icons.person),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_token');
              
              Get.offAllNamed(Routes.login);
            },
          ),
        ] : null,
      ),
      body: widget.body,
    );
  }
}
