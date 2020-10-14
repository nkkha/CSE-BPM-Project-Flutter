import 'package:cse_bpm_project/secretary/SecretaryScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
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
  int currentStepIndex = 0;

  var webService = WebService();

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
          (index) => CreateStepWidget(tabIndex: index, requestID: widget.requestID, update: (data, stepIndex) {
            if (data < _numOfSteps) {
              tabController.animateTo(data);
            } else if (data == _numOfSteps) {
              webService.patchRequestNumOfSteps(widget.requestID, stepIndex + 1, (isSuccessful) {
                if (isSuccessful) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SecretaryScreen(isCreatedNew: true)),
                        (Route<dynamic> route) => false,
                  );
                }
              });
            }
          })
        ),
      ),
    );
  }
}
