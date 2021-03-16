import 'package:after_layout/after_layout.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cse_bpm_project/fragment/ChatFragment.dart';
import 'package:cse_bpm_project/fragment/SettingsFragment.dart';
import 'package:cse_bpm_project/secretary/SecretaryHomeFragment.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DeanScreen extends StatefulWidget {
  bool isCreatedNew = false;

  DeanScreen({Key key, this.isCreatedNew}) : super(key: key);

  @override
  _DeanScreenState createState() => _DeanScreenState();
}

class _DeanScreenState extends State<DeanScreen>
    with AfterLayoutMixin<DeanScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    SecretaryHomeFragment(),
    ChatFragment(),
    SettingsFragment(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0 ? MyColors.brand : MyColors.mediumGray,
            ),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/ic-chat-24.png',
              color: _selectedIndex == 1 ? MyColors.brand : MyColors.mediumGray,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/ic-settings-24.png',
              color: _selectedIndex == 2 ? MyColors.brand : MyColors.mediumGray,
            ),
            label: 'Cài đặt',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: MyColors.brand,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (widget.isCreatedNew != null) {
      if (widget.isCreatedNew) {
        Flushbar(
          icon:
              Image.asset('images/ic-check-circle.png', width: 24, height: 24),
          message: 'Tạo quy trình thành công!',
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
        )..show(context);
        widget.isCreatedNew = false;
      }
    }
  }
}
