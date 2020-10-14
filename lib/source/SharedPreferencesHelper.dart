import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class SharedPreferencesHelper {

  static Future<int> getRoleId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt('roleId') ?? null;
  }

  static Future<int> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt('userId') ?? null;
  }

  static Future<int> getCurrentStepIndex() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt('currentStepIndex') ?? null;
  }

  // String extension = p.extension(filePath).split('.').last;
}