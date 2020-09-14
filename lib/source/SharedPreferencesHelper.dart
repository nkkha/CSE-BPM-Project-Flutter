import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

  static Future<int> getRoleId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt('roleId') ?? null;
  }

  static Future<int> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt('userId') ?? null;
  }
}