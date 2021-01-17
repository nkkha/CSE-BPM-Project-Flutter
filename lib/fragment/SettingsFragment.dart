import 'dart:async';
import 'package:cse_bpm_project/screen/login/CreateAccountScreen.dart';
import 'package:cse_bpm_project/screen/login/LoginScreen.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:http/http.dart' as http;
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsFragment extends StatefulWidget {
  final int roleID;

  const SettingsFragment({Key key, this.roleID}) : super(key: key);

  @override
  _SettingsFragmentState createState() => _SettingsFragmentState();
}

class _SettingsFragmentState extends State<SettingsFragment> {
  ProgressDialog pr;
  var webService = new WebService();

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
      body: widget.roleID == 3
          ? Column(
              children: <Widget>[
                _buildRowSetting(
                    'images/ic-notifications-24.png', 'Thông báo', 1, context),
                _buildRowSetting(
                    'images/ic_user_group_24.png', 'Tạo tài khoản', 5, context),
                _buildRowSetting('images/ic-security-24.png',
                    'Chính sách bảo mật', 2, context),
                _buildRowSetting(
                    'images/ic-help-24.png', 'Trợ giúp', 3, context),
                _buildRowSetting('images/logout.png', 'Đăng xuất', 4, context),
              ],
            )
          : Column(
              children: <Widget>[
                _buildRowSetting(
                    'images/ic-notifications-24.png', 'Thông báo', 1, context),
                _buildRowSetting('images/ic-security-24.png',
                    'Chính sách bảo mật', 2, context),
                _buildRowSetting(
                    'images/ic-help-24.png', 'Trợ giúp', 3, context),
                _buildRowSetting('images/logout.png', 'Đăng xuất', 4, context),
              ],
            ),
    );
  }

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
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onTap: () => _onRowClicked(context, index),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 72),
          child: Divider(thickness: 1, height: 1),
        ),
      ],
    );
  }

  void _onRowClicked(BuildContext context, int index) {
    switch (index) {
      case 4:
        _onLogOutClicked(context);
        break;
      case 5:
        _onCreateAccountClicked();
    }
  }

  Future<void> _onLogOutClicked(BuildContext context) async {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.update(message: "Đang xử lý...");
    await pr.show();

    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbUser/Logout',
    );

    if (response.statusCode == 200) {
      await pr.hide();
      final prefs = await SharedPreferences.getInstance();
      String deviceToken = prefs.getString('deviceToken');
      if (deviceToken != null) {
        webService.updateDeviceToken();
      }
      prefs.setInt('userId', null);
      prefs.setInt('roleId', null);
      prefs.setBool('isLogin', false);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      await pr.hide();
      throw Exception('Failed to logout.');
    }
  }

  void _onCreateAccountClicked() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateAccountScreen()));
  }
}
