import 'dart:async';
import 'dart:convert';

import 'package:cse_bpm_project/faculty/FacultyScreen.dart';
import 'package:cse_bpm_project/model/User.dart';
import 'package:cse_bpm_project/screen/HomeScreen.dart';
import 'package:cse_bpm_project/secretary/Secretary.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../source/MyColors.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isClicked = false;

  TextEditingController _userController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  FocusNode _myFocusNode1 = new FocusNode();
  FocusNode _myFocusNode2 = new FocusNode();

  @override
  void initState() {
    super.initState();
    _myFocusNode1 = new FocusNode();
    _myFocusNode2 = new FocusNode();
    _myFocusNode1.addListener(_onOnFocusNodeEvent);
    _myFocusNode2.addListener(_onOnFocusNodeEvent);
  }

  @override
  void dispose() {
    super.dispose();
    _myFocusNode1.dispose();
    _myFocusNode2.dispose();
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: 150,
                  width: 150,
                  child: Image.asset('images/logo-cse.png'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
                  child: Text(
                    'Welcome Back!',
                    style: TextStyle(fontSize: 22, color: MyColors.black),
                  ),
                ),
                Text(
                  'Login to continue using BPM Project',
                  style: TextStyle(fontSize: 16, color: MyColors.mediumGray),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                  child: TextField(
                    focusNode: _myFocusNode1,
                    controller: _userController,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                          color: _myFocusNode1.hasFocus
                              ? MyColors.lightBrand
                              : MyColors.mediumGray),
                      prefixIcon: Container(
                        width: 50,
                        child: Image.asset('images/ic_user.png'),
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.lightGray, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.lightBrand, width: 2.0),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                ),
                TextField(
                  focusNode: _myFocusNode2,
                  controller: _passController,
                  obscureText: true,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: _myFocusNode2.hasFocus
                            ? MyColors.lightBrand
                            : MyColors.mediumGray),
                    prefixIcon: Container(
                      width: 50,
                      child: Image.asset('images/ic_lock.png'),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: MyColors.lightGray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: MyColors.lightBrand, width: 2),
                      borderRadius: BorderRadius.circular(6.0),
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
                      style:
                          TextStyle(fontSize: 16, color: MyColors.mediumGray),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: RaisedButton(
                      onPressed: _isClicked == false ? _onLoginClicked : () {},
                      child: Text(
                        'Log In',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      color: MyColors.lightBrand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'New user? ',
                    style: TextStyle(color: MyColors.darkGray, fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'Sign up for a new account',
                        style: TextStyle(
                          color: MyColors.lightBrand,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLoginClicked() async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.update(message: "Đăng nhập...");

    await pr.show();

    _isClicked = true;
    String userName = _userController.text;
    String pass = _passController.text;

    var resBody = {};
    resBody["UserName"] = "$userName";
    resBody["Password"] = "$pass";
    var user = {};
    user["user"] = resBody;
    String str = json.encode(user);

    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbUser/Login',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: str,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      User user = User.fromJson(data[0]);

      // Save data to shared preferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('UserId', user.id);
      prefs.setInt('RoleId', user.roleId);

      await pr.hide();
      if (user.roleId == 1) // User is student
      {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else if (user.roleId == 2) // User is secretary
      {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SecretaryHomeScreen()));
      } else // User is faculty
      {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => FacultyHomeScreen()));
      }
    } else {
      _isClicked = false;
      final snackBar = SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error,
              color: MyColors.red,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('Username or password is incorrect!'),
            ),
          ],
        ),
      );
      await pr.hide();
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }
}
