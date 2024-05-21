import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi/routes.dart';
class ScaffoldBase extends StatefulWidget {
  final Widget body;
  final String title;
  final bool showProfileIcon;

  const ScaffoldBase({
    required this.body,
    required this.title,
    this.showProfileIcon = true,
  });

  @override
  _ScaffoldBaseState createState() => _ScaffoldBaseState();
}

class _ScaffoldBaseState extends State<ScaffoldBase> {
  late String _title;
  bool _isLoggedIn = false;
  late String _username;

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
      _username = prefs.getString('login') ?? "ABF Informática";
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
        actions: widget.showProfileIcon && _isLoggedIn
            ? [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.person, size: 40),
                  onSelected: (String result) async {
                    if (result == 'logout') {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('jwt_token');
                      Get.offAllNamed(Routes.login);
                    } else if (result == 'profile') {
                      // Navigate to the profile page
                      // You can replace this with the actual route for your profile page
                      // Get.toNamed(Routes.profile);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Text('Meu perfil'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: widget.body,
    );
  }
}
