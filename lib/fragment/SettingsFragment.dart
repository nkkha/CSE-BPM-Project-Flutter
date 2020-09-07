import 'dart:async';
import 'package:cse_bpm_project/screen/login/LoginScreen.dart';
import 'package:http/http.dart' as http;
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsFragment extends StatelessWidget {
  const SettingsFragment({Key key}) : super(key: key);

  Widget _buildRowSetting(
      String imgUrl, String title, int index, BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
                child: Image.asset(
                  '$imgUrl',
                  color: MyColors.mediumGray,
                  width: 24,
                  height: 24,
                ),
              ),
              Text(
                '$title',
                style: TextStyle(
                  color: MyColors.darkGray,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onTap: index == 4 ? () => _onLogOutClicked(context) : () => {},
        ),
        Padding(
          padding: const EdgeInsets.only(left: 72),
          child: Divider(
            height: 1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          _buildRowSetting(
              'images/ic-notifications-24.png', 'Thông báo', 1, context),
          _buildRowSetting(
              'images/ic-security-24.png', 'Chính sách bảo mật', 2, context),
          _buildRowSetting('images/ic-help-24.png', 'Trợ giúp', 3, context),
          _buildRowSetting('images/logout.png', 'Đăng xuất', 4, context),
        ],
      ),
    );
  }

  Future<void> _onLogOutClicked(BuildContext context) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbUser/Logout',
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('userId', null);
      prefs.setInt('roleId', null);
      prefs.setBool('isLogin', false);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      throw Exception('Failed to logout.');
    }
  }
}
