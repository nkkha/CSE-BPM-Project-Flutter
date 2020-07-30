import 'package:flutter/material.dart';

class StepDetailsWidget extends StatefulWidget {
  final int stepIndex;
  final int tabIndex;

  const StepDetailsWidget({Key key, this.stepIndex, this.tabIndex}) : super(key: key);

  @override
  _StepDetailsWidgetState createState() => _StepDetailsWidgetState();
}

class _StepDetailsWidgetState extends State<StepDetailsWidget> {
  Widget build(BuildContext context) {
    return Center(child: Text('${widget.tabIndex > widget.stepIndex - 1 ? 'Bước ${widget.stepIndex} chưa hoàn thành' : 'HelloWorld'}'));
  }
}
