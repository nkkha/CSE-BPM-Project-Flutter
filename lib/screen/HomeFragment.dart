import 'package:cse_bpm_project/screen/CreateRequest.dart';
import 'package:cse_bpm_project/screen/UserRequest.dart';
import 'package:flutter/material.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({Key key}) : super(key: key);
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Trang chủ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset(
              'images/ic-toolbar-new.png',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateRequestScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(
                    'Yêu cầu của bạn',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserRequestScreen()));
              },
            ),
            Divider(),
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(
                    'Thực hiện yêu cầu',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateRequestScreen()));
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
