import 'package:cse_bpm_project/screen/CreateRequestScreen.dart';
import 'package:cse_bpm_project/secretary/SecretaryRequestScreen.dart';
import 'package:flutter/material.dart';

class SecretaryHomeFragment extends StatefulWidget {
  const SecretaryHomeFragment({Key key}) : super(key: key);

  @override
  _SecretaryHomeFragmentState createState() => _SecretaryHomeFragmentState();
}

class _SecretaryHomeFragmentState extends State<SecretaryHomeFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Quy trình',
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
                MaterialPageRoute(
                    builder: (context) => CreateRequestScreen()),
              );
            },
          ),
        ],
      ),
      body: SecretaryRequestScreen(),
    );
  }
}
