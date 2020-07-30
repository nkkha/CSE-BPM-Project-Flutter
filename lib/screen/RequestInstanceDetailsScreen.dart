import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/widget/StepDetailsWidget.dart';
import 'package:cse_bpm_project/widget/StepInfoWidget.dart';
import 'package:flutter/material.dart';

class RequestInstanceDetailsScreen extends StatefulWidget {
  final RequestInstance requestInstance;

  RequestInstanceDetailsScreen({Key key, @required this.requestInstance})
      : super(key: key);

  @override
  _RequestInstanceDetailsScreenState createState() =>
      _RequestInstanceDetailsScreenState(requestInstance);
}

class _RequestInstanceDetailsScreenState extends State<RequestInstanceDetailsScreen> {
  final RequestInstance _requestInstance;

  _RequestInstanceDetailsScreenState(this._requestInstance);

  @override
  Widget build(BuildContext context) {
    int _numOfStep = _requestInstance.numOfSteps;

    return DefaultTabController(
      length: _numOfStep,
      initialIndex: _requestInstance.currentStepIndex - 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chi tiết yêu cầu'),
          titleSpacing: 0,
          bottomOpacity: 1,
          bottom: TabBar(
            labelColor: MyColors.blue,
            unselectedLabelColor: MyColors.mediumGray,
            tabs: List<Widget>.generate(
                _numOfStep, (index) => Tab(text: 'Bước ${index + 1}')),
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: List<Widget>.generate(
            _numOfStep,
            (index) => index == 0
                ? StepInfoWidget(requestInstance: _requestInstance)
                : StepDetailsWidget(stepIndex: _requestInstance.currentStepIndex, tabIndex: index),
          ),
        ),
      ),
    );
  }
}
