import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

class RequestDetailsScreen extends StatefulWidget {
  final int numOfStep;

  RequestDetailsScreen({Key key, @required this.numOfStep}) : super(key: key);

  @override
  _RequestDetailsScreenState createState() =>
      _RequestDetailsScreenState(numOfStep);
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final int _numOfStep;

  _RequestDetailsScreenState(this._numOfStep);

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
                _numOfStep, (index) => Center(child: Text('HelloWorld ${index + 1}')))),
      ),
    );
  }
}
