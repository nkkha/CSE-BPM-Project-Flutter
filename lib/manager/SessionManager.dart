import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _singleton = SessionManager._internal();

  factory SessionManager() {
    return _singleton;
  }

  SessionManager._internal();

  final String _logIn = 'isLogged';

  Future<void> setLogIn(bool isLogged) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(this._logIn, isLogged);
  }

  Future<bool> isLogged() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    bool isLogged;
    isLogged = pref.getBool(this._logIn) ?? false;
    return isLogged;
  }
}