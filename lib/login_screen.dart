import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/falcuty/falcuty_screen.dart';
import 'package:cse_bpm_project/secretary/secret_home.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/home_screen.dart';
import 'package:cse_bpm_project/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _userController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              Container(
                height: 150,
                width: 150,
                child: Image.asset('images/logo-cse.png'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 22, color: Color(0xff333333)),
                ),
              ),
              Text(
                'Login to continue using CSE Project',
                style: TextStyle(fontSize: 16, color: Color(0xff606470)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                child: TextField(
                  controller: _userController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Container(
                      width: 50,
                      child: Image.asset('images/ic_user.png'),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xffCED0D2), width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _passController,
                obscureText: true,
                style: TextStyle(fontSize: 18, color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Container(
                    width: 50,
                    child: Image.asset('images/ic_lock.png'),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints.loose(Size(double.infinity, 40)),
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(fontSize: 16, color: Color(0xff606470)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: RaisedButton(
                    onPressed: _onLoginClicked,
                    child: Text(
                      'Log In',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    color: Color(0xff3277D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: RichText(
                  text: TextSpan(
                    text: 'New user? ',
                    style: TextStyle(color: Color(0xff606470), fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'Sign up for a new account',
                        style: TextStyle(
                          color: Color(0xff327798),
                          fontSize: 16,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen()));
                          },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLoginClicked() async {
    String userName = _userController.text;
    String pass = _passController.text;

    var resBody = {};
    resBody["UserName"] = "$userName";
    resBody["Password"] = "$pass";
    var user = {};
    user["user"] = resBody;
    String str = json.encode(user);
    print(str);

    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbUser/Login',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: str,
    );

    if (response.statusCode == 200) {
      if (userName.contains("sv")) {
        Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else if (userName.contains("tk")){
        Navigator.push(
          context, MaterialPageRoute(builder: (context) => SecretaryHomeScreen()));
      } else if (userName.contains("bcn")){
        Navigator.push(
          context, MaterialPageRoute(builder: (context) => FalcutyHomeScreen()));
      }
      // _getUserRole();
      
    } else {
      throw Exception('Failed to login.');
    }
  }

  // void _getUserRole() {}
}
