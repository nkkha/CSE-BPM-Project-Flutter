import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/secretary/SecretaryRequestInstanceListWidget.dart';
import 'package:cse_bpm_project/widget/NoRequestInstanceWidget.dart';
import 'package:flutter/material.dart';

class OfficesStudentRequestInstanceScreen extends StatefulWidget {
  final List<RequestInstance> requestInstanceList;

  const OfficesStudentRequestInstanceScreen({Key key, this.requestInstanceList})
      : super(key: key);

  @override
  _OfficesStudentRequestInstanceScreenState createState() =>
      _OfficesStudentRequestInstanceScreenState(requestInstanceList);
}

class _OfficesStudentRequestInstanceScreenState
    extends State<OfficesStudentRequestInstanceScreen> {
  Future<List<RequestInstance>> futureListRequest;
  final List<RequestInstance> _requestInstanceList;

  _OfficesStudentRequestInstanceScreenState(this._requestInstanceList);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yêu cầu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _requestInstanceList.length > 0
          ? SecretaryRequestInstanceListWidget(
              requestInstanceList: _requestInstanceList,
            )
          : NoRequestInstanceWidget(isStudent: false),
    );
  }
}
