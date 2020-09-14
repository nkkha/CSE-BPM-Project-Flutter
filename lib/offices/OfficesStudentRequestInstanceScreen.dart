import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/secretary/StudentRequestInstanceListWidget.dart';
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
  bool _noRequest = false;
  final List<RequestInstance> _requestInstanceList;

  _OfficesStudentRequestInstanceScreenState(this._requestInstanceList);

  @override
  void initState() {
    super.initState();
//    futureListRequest = fetchListRequest();
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
          ? StudentRequestInstanceListWidget(
              requestList: _requestInstanceList,
            )
          : NoRequestInstanceWidget(false),
    );
  }

  Future<List<RequestInstance>> fetchListRequest() async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbRequestInstance/GetRequestInstance?\$filter=requestid eq');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<RequestInstance> listRequest = new List();
      for (Map i in data) {
        listRequest.add(RequestInstance.fromJson(i));
      }
      if (listRequest.length == 0) _noRequest = true;
      return listRequest;
    } else {
      throw Exception('Failed to load');
    }
  }
}
