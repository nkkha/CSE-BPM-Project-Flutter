import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/login_screen.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/create_request_screen.dart';
import 'package:cse_bpm_project/user_request_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color(0xff3277D8),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_to_home_screen),
            onPressed: () => _onLogOutClicked(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(
                    'Your Request',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserRequestScreen()));
              },
            ),
            Divider(),
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(
                    'Create Request',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateRequestScreen()));
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Future<void> _onLogOutClicked() async {

    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbUser/Logout',
    );

    if (response.statusCode == 200) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      throw Exception('Failed to logout.');
    }
  }
}
