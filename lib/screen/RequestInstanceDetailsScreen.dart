import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/widget/StepDetailsWidget.dart';
import 'package:cse_bpm_project/widget/StepInfoWidget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RequestInstanceDetailsScreen extends StatefulWidget {
  final RequestInstance requestInstance;
  final bool isStudent;
  Function update;

  RequestInstanceDetailsScreen(
      {Key key, @required this.requestInstance, this.isStudent, this.update})
      : super(key: key);

  @override
  _RequestInstanceDetailsScreenState createState() =>
      _RequestInstanceDetailsScreenState(requestInstance);
}

class _RequestInstanceDetailsScreenState
    extends State<RequestInstanceDetailsScreen>
    with SingleTickerProviderStateMixin {
  RequestInstance _requestInstance;

  _RequestInstanceDetailsScreenState(this._requestInstance);

  TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = new TabController(
        vsync: this,
        length: _requestInstance.numOfSteps,
        initialIndex: _requestInstance.currentStepIndex - 1);
  }

  @override
  Widget build(BuildContext context) {
    int _numOfStep = _requestInstance.numOfSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết yêu cầu'),
        titleSpacing: 0,
        bottomOpacity: 1,
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: MyColors.blue,
          unselectedLabelColor: MyColors.mediumGray,
          tabs: List<Widget>.generate(
              _numOfStep, (index) => Tab(text: 'Bước ${index + 1}')),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: List<Widget>.generate(
          _numOfStep,
          (index) => index == 0
              ? StepInfoWidget(
                  requestInstance: _requestInstance,
                  isStudent: widget.isStudent,
                  numOfSteps: _requestInstance.numOfSteps,
                  update: (data) {
                    widget.update(data);
                  },
                )
              : StepDetailsWidget(
                  requestInstance: _requestInstance,
                  tabIndex: index,
                  numOfSteps: _numOfStep,
                  update: (data) {
                    widget.update(data);
                  },
                ),
        ),
      ),
    );
  }
}
