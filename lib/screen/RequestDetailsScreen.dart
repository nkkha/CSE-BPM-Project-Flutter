import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/widget/StepDetailsWidget.dart';
import 'package:cse_bpm_project/widget/StepInfoWidget.dart';
import 'package:flutter/material.dart';

class RequestDetailsScreen extends StatefulWidget {
  final RequestInstance requestInstance;

  RequestDetailsScreen({Key key, @required this.requestInstance})
      : super(key: key);

  @override
  _RequestDetailsScreenState createState() =>
      _RequestDetailsScreenState(requestInstance);
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final RequestInstance _requestInstance;

  _RequestDetailsScreenState(this._requestInstance);

  final int _numOfStep = 3;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _numOfStep,
      initialIndex: 0,
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
          children: List<Widget>.generate(
            _numOfStep,
            (index) => index == 0
                ? StepInfoWidget(requestInstance: _requestInstance)
                : StepDetailsWidget(index: index),
          ),
        ),
      ),
    );
  }
}
