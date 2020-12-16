import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/model/UserRole.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/offices/OfficesScreen.dart';
import 'package:cse_bpm_project/model/User.dart';
import 'package:cse_bpm_project/screen/RequestInstanceDetailsScreen.dart';
import 'package:cse_bpm_project/screen/StudentScreen.dart';
import 'package:cse_bpm_project/secretary/SecretaryScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  // final GlobalKey<NavigatorState> navigatorKey;

  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var webService = new WebService();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TextEditingController _userController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  FocusNode _myFocusNode1 = new FocusNode();
  FocusNode _myFocusNode2 = new FocusNode();

  ProgressDialog progressDialog;
  int _roleId;
  bool _isClicked = false;
  RequestInstance _requestInstance;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        if (message.containsKey('data')) {
          final RequestInstance data = RequestInstance.fromJson(
              jsonDecode(message['data']['requestInstance']));
          print(data);
          if (!RequestInstanceDetailsScreen.isWorking) {
            _showAlertDialog(data);
          }
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _requestInstance = RequestInstance.fromJson(
            jsonDecode(message['data']['requestInstance']));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        if (message.containsKey('data')) {
          final RequestInstance data = RequestInstance.fromJson(
              jsonDecode(message['data']['requestInstance']));
          MyApp.navigatorKey.currentState.push(MaterialPageRoute(
              builder: (context) => RequestInstanceDetailsScreen(
                    requestInstance: data,
                    isStudent: false,
                  )));
        }
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _roleId = null;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      progressDialog = ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: true);
      progressDialog.update(message: "Vui lòng đợi...");
      await progressDialog.show();
      getSharedPrefs();
    });

    _myFocusNode1 = new FocusNode();
    _myFocusNode2 = new FocusNode();
    _myFocusNode1.addListener(_onOnFocusNodeEvent);
    _myFocusNode2.addListener(_onOnFocusNodeEvent);
  }

  _showAlertDialog(RequestInstance requestInstance) {
    TextEditingController messageController = new TextEditingController();
    BuildContext context = MyApp.navigatorKey.currentContext;
    Alert(context: context, title: "Yêu cầu được cập nhật", buttons: [
      DialogButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          "Thoát",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      DialogButton(
        onPressed: () {
          Navigator.pop(context);
          MyApp.navigatorKey.currentState.push(MaterialPageRoute(
              builder: (context) => RequestInstanceDetailsScreen(
                    requestInstance: requestInstance,
                    isStudent: false,
                  )));
        },
        child: Text(
          "Mở",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ]).show();
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _roleId = prefs.getInt("roleId");
    new Timer(const Duration(milliseconds: 500), () {
      progressDialog.hide();
      if (_roleId != null) {
        getHomeScreen(_roleId);
      }
    });
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
                    'Đăng nhập',
                    style: TextStyle(fontSize: 22, color: MyColors.black),
                  ),
                ),
                Text(
                  'Đăng nhập để sử dụng ứng dụng',
                  style: TextStyle(fontSize: 16, color: MyColors.mediumGray),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                  child: TextField(
                    focusNode: _myFocusNode1,
                    controller: _userController,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Tên đăng nhập',
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
                    labelText: 'Mật khẩu',
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
                      'Quên mật khẩu?',
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
                      onPressed: !_isClicked ? _onLoginClicked : () {},
                      child: Text(
                        'Đăng nhập',
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
                    text: 'Người dùng mới? ',
                    style: TextStyle(color: MyColors.darkGray, fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'Đăng ký tài khoản',
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
    resBody["UserName"] = userName;
    resBody["Password"] = pass;
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
      UserRole userRole = UserRole.fromJson(data[0]);

      // Save data to shared preferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('userId', userRole.userId);
      prefs.setInt('roleId', userRole.roleId);
      prefs.setBool('isLogin', true);

      if (userRole.roleId == 1) {
        _firebaseMessaging.getToken().then((String token) {
          assert(token != null);
          print("Token: $token");
          prefs.setString('deviceToken', token);
          webService.postDeviceToken(userRole.userId, token, true);
          // print(_homeScreenText);
        });
      }

      await pr.hide();
      switch (userRole.roleId) {
        case 1:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      StudentScreen(requestInstance: _requestInstance)));
          break;
        case 2:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => SecretaryScreen(selectedIndex: 0, roleID: userRole.roleId)));
          break;
        case 3:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SecretaryScreen(selectedIndex: 0, roleID: userRole.roleId)));
          break;
        default:
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => OfficesScreen(roleID: userRole.roleId)));
          break;
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

  void getHomeScreen(int roleId) {
    switch (roleId) {
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => StudentScreen(requestInstance: _requestInstance)));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SecretaryScreen(selectedIndex: 0, roleID: roleId)));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SecretaryScreen(selectedIndex: 0, roleID: roleId)));
        break;
      default:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => OfficesScreen(
                      roleID: _roleId,
                    )));
        break;
    }
  }
}
