import 'package:cse_bpm_project/login_screen.dart';
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
    );
  }
}
