import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

import '../WebViewPage.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'CSE BPM App',
              style: TextStyle(
                  color: MyColors.brand,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
            SizedBox(height: 12),
            Text(
              'Version Number: 1.0.1',
              style: TextStyle(color: MyColors.darkGray, fontSize: 16),
            ),
            SizedBox(height: 1),
            Text(
              '© 2021 Kha Nguyen',
              style: TextStyle(color: MyColors.darkGray, fontSize: 16),
            ),
            SizedBox(height: 5),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => WebViewPage())),
              child: Text(
                'Privacy Policy Notice',
                style: TextStyle(
                    color: MyColors.darkGray,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
