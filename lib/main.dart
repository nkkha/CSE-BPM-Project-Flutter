import 'package:cse_bpm_project/screen/HomeScreen.dart';
import 'package:cse_bpm_project/screen/login/Login.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSE BPM Project',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      theme: ThemeData(
        primaryColor: MyColors.white,
        primaryColorDark: MyColors.lightGray,
        appBarTheme: AppBarTheme(
          elevation: 1,
        ),
      ),
    );
  }
}
