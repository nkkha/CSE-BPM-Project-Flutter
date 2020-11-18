import 'package:cse_bpm_project/fragment/ChatFragment.dart';
import 'package:cse_bpm_project/fragment/RequestInstanceFragment.dart';
import 'package:cse_bpm_project/fragment/SettingsFragment.dart';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flushbar/flushbar.dart';

import 'RequestInstanceDetailsScreen.dart';

// ignore: must_be_immutable
class StudentScreen extends StatefulWidget {
  bool isCreatedNew = false;
  RequestInstance requestInstance;

  StudentScreen({Key key, this.isCreatedNew, this.requestInstance})
      : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen>
    with AfterLayoutMixin<StudentScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    RequestInstanceFragment(),
    // ChatFragment(),
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
      key: _scaffoldKey,
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
            title: Container(height: 0.0),
            // title: Text('Trang chủ'),
          ),
          // BottomNavigationBarItem(
          //   icon: Image.asset(
          //     'images/ic-chat-24.png',
          //     color: _selectedIndex == 1 ? MyColors.brand : MyColors.mediumGray,
          //   ),
          //   title: Text('Chat'),
          // ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/ic-settings-24.png',
              color: _selectedIndex == 1 ? MyColors.brand : MyColors.mediumGray,
            ),
            title: Container(height: 0.0),
            // title: Text('Cài đặt'),
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
    if (widget.requestInstance != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RequestInstanceDetailsScreen(
                requestInstance: widget.requestInstance,
                isStudent: false,
              )));
    }

    if (widget.isCreatedNew != null) {
      if (widget.isCreatedNew) {
        Flushbar(
          icon:
              Image.asset('images/ic-check-circle.png', width: 24, height: 24),
          message: 'Tạo yêu cầu thành công!',
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(8),
          borderRadius: 8,
        )..show(context);
        widget.isCreatedNew = false;
      }
    }
  }
}
