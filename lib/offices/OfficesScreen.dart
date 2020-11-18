import 'package:cse_bpm_project/fragment/ChatFragment.dart';
import 'package:cse_bpm_project/fragment/SettingsFragment.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

import 'OfficesHomeFragment.dart';

class OfficesScreen extends StatefulWidget {
  final int roleID;
  const OfficesScreen({Key key, this.roleID}) : super(key: key);

  @override
  _OfficesScreenState createState() => _OfficesScreenState();
}

class _OfficesScreenState extends State<OfficesScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      OfficesHomeFragment(roleID: widget.roleID),
      // ChatFragment(),
      SettingsFragment(),
    ];

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
            title: Container(height: 0),
          ),
          // BottomNavigationBarItem(
          //   icon: Image.asset(
          //     'images/ic-chat-24.png',
          //     color: _selectedIndex == 1 ? MyColors.brand : MyColors.mediumGray,
          //   ),
          //   title: Container(height: 0),
          // ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/ic-settings-24.png',
              color: _selectedIndex == 1 ? MyColors.brand : MyColors.mediumGray,
            ),
            title: Container(height: 0),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: MyColors.brand,
        onTap: _onItemTapped,
      ),
    );
  }
}
