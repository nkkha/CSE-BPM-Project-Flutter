import 'package:cse_bpm_project/secretary/SecretaryScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/widget/CreateStepWidget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CreateStepScreen extends StatefulWidget {
  final int requestID;
  final int numOfSteps;

  CreateStepScreen({Key key, @required this.requestID, this.numOfSteps}) : super(key: key);

  @override
  _CreateStepScreenState createState() => _CreateStepScreenState();
}

class _CreateStepScreenState extends State<CreateStepScreen> with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(vsync: this, length: widget.numOfSteps, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    int _numOfSteps = widget.numOfSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo các bước'),
        titleSpacing: 0,
        bottomOpacity: 1,
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: MyColors.blue,
          unselectedLabelColor: MyColors.mediumGray,
          tabs: List<Widget>.generate(
              _numOfSteps, (index) => Tab(text: 'Bước ${index + 1}')),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: List<Widget>.generate(
          _numOfSteps,
          (index) => CreateStepWidget(index: index, requestID: widget.requestID, update: (data) {
            if (data < _numOfSteps) {
              tabController.animateTo(data);
            } else if (data == _numOfSteps) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => SecretaryScreen(isCreatedNew: true)),
                    (Route<dynamic> route) => false,
              );
            }
          })
        ),
      ),
    );
  }
}
