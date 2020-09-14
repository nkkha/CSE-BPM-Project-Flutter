import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/secretary/SecretaryRequestInstanceListWidget.dart';
import 'package:cse_bpm_project/widget/NoRequestInstanceWidget.dart';
import 'package:flutter/material.dart';

class SecretaryRequestInstanceScreen extends StatefulWidget {
  final int requestID;

  const SecretaryRequestInstanceScreen({Key key, this.requestID})
      : super(key: key);

  @override
  _SecretaryRequestInstanceScreenState createState() =>
      _SecretaryRequestInstanceScreenState(requestID);
}

class _SecretaryRequestInstanceScreenState
    extends State<SecretaryRequestInstanceScreen> {
  Future<List<RequestInstance>> futureListRequest;
  bool _noRequest = false;
  final int _requestID;

  _SecretaryRequestInstanceScreenState(this._requestID);

  @override
  void initState() {
    super.initState();
    futureListRequest = fetchListRequest();
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
      body: FutureBuilder<List<RequestInstance>>(
        future: futureListRequest,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_noRequest)
              return Center(child: NoRequestInstanceWidget(false));
            return SecretaryRequestInstanceListWidget(
              requestList: snapshot.data,
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List<RequestInstance>> fetchListRequest() async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbRequestInstance/GetRequestInstance?\$filter=requestid eq $_requestID');

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
