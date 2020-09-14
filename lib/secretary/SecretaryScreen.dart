import 'package:cse_bpm_project/fragment/ChatFragment.dart';
import 'package:cse_bpm_project/fragment/SettingsFragment.dart';
import 'package:cse_bpm_project/secretary/SecretaryHomeFragment.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

class SecretaryScreen extends StatefulWidget {
  const SecretaryScreen({Key key}) : super(key: key);

  @override
  _SecretaryScreenState createState() => _SecretaryScreenState();
}

class _SecretaryScreenState extends State<SecretaryScreen> {
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
            title: Text('Trang chủ'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/ic-chat-24.png',
              color: _selectedIndex == 1 ? MyColors.brand : MyColors.mediumGray,
            ),
            title: Text('Chat'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/ic-settings-24.png',
              color: _selectedIndex == 2 ? MyColors.brand : MyColors.mediumGray,
            ),
            title: Text('Cài đặt'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: MyColors.brand,
        onTap: _onItemTapped,
      ),
    );
  }
}
