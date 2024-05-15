import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pi/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScaffoldBase extends StatefulWidget{
  final Widget body;
  final String title;

  ScaffoldBase({required this.body, required this.title});
  
  @override
   _ScaffoldBase createState()=> _ScaffoldBase();
  
}

class _ScaffoldBase extends State<ScaffoldBase>{
  late String _title;

  @override void initState() {
    super.initState();
    _title = widget.title;
  }

  Future<String> getUsername() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('login');
    return username ?? "ABF Informática";
  }

  void updateTitle(String newtitle){
    setState(() {
      _title = newtitle;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: getUsername(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              return Text(_title);
            }
          },
      ),
      actions: [
          IconButton(
            iconSize: 40,
            icon: const Icon(Icons.person),
            onPressed: () async {             
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_token'); 
              Get.offAllNamed(Routes.login);
            }
          ),
        ],
      ),
      body: widget.body,
    );
  }
}