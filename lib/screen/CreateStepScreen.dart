import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/widget/CreateStepWidget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CreateStepScreen extends StatefulWidget {
  final String requestID;
  final int numOfSteps;

  CreateStepScreen({Key key, @required this.requestID, this.numOfSteps}) : super(key: key);

  @override
  _CreateStepScreenState createState() => _CreateStepScreenState();
}

class _CreateStepScreenState extends State<CreateStepScreen> {
  @override
  Widget build(BuildContext context) {
    int _numOfSteps = widget.numOfSteps;

    return DefaultTabController(
      length: _numOfSteps,
      initialIndex: 0,
      child: Center(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Tạo các bước'),
            titleSpacing: 0,
            bottomOpacity: 1,
            bottom: TabBar(
              isScrollable: true,
              labelColor: MyColors.blue,
              unselectedLabelColor: MyColors.mediumGray,
              tabs: List<Widget>.generate(
                  _numOfSteps, (index) => Tab(text: 'Bước ${index + 1}')),
            ),
          ),
          body: TabBarView(
            children: List<Widget>.generate(
              _numOfSteps,
              (index) => CreateStepWidget(requestID: widget.requestID,)
            ),
          ),
        ),
      ),
    );
  }
}
