import 'package:flutter/material.dart';

class StepDetailsWidget extends StatefulWidget {
  final int index;

  const StepDetailsWidget({Key key, this.index}) : super(key: key);

  @override
  _StepDetailsWidgetState createState() => _StepDetailsWidgetState();
}

class _StepDetailsWidgetState extends State<StepDetailsWidget> {
  Widget build(BuildContext context) {
    return Center(child: Text('HelloWorld ${widget.index + 1}'));
  }
}
