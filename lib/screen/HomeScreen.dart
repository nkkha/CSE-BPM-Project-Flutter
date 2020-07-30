import 'package:cse_bpm_project/fragment/ChatFragment.dart';
import 'package:cse_bpm_project/fragment/RequestFragment.dart';
import 'package:cse_bpm_project/fragment/SettingsFragment.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';

class HomeScreen extends StatefulWidget {
  final bool isCreatedNew;
  const HomeScreen({Key key, this.isCreatedNew}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AfterLayoutMixin<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    RequestFragment(),
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

  @override
  void afterFirstLayout(BuildContext context) {
//    if (widget.isCreatedNew) {
//      final snackBar = SnackBar(
//        content: Text(
//          'Tạo yêu cầu thành công!',
//          style: TextStyle(fontSize: 14, color: MyColors.white),
//        ),
//        backgroundColor: MyColors.black,
//      );
//      _scaffoldKey.currentState.showSnackBar(snackBar);
//    }
  }
}
