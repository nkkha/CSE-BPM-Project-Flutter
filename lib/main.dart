import 'package:cse_bpm_project/screen/login/LoginScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    return MaterialApp(
      title: 'CSE BPM Project',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      theme: ThemeData(
        primaryColor: MyColors.white,
        primaryColorDark: MyColors.lightGray,
        appBarTheme: AppBarTheme(elevation: 1, centerTitle: false),
        scaffoldBackgroundColor: MyColors.white,
      ),
    );
  }
}
