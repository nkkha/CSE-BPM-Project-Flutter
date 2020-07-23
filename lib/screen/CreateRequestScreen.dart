import 'dart:async';
import 'dart:convert';

import 'package:cse_bpm_project/model/Request.dart';
import 'package:cse_bpm_project/widget/NoRequestWidget.dart';
import 'package:cse_bpm_project/widget/RequestListWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateRequestScreen extends StatefulWidget {
  @override
  _CreateRequestScreenState createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  Future<List<Request>> futureListRequest;
  bool _noRequest = false;

  @override
  void initState() {
    super.initState();
    futureListRequest = fetchListRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo yêu cầu'),
        titleSpacing: 0,
      ),
      body: Center(
        child: FutureBuilder<List<Request>>(
          future: futureListRequest,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (_noRequest) return NoRequestWidget();
              return RequestListWidget(requestList: snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<List<Request>> fetchListRequest() async {
    final response =
        await http.get('http://nkkha.somee.com/odata/tbRequest');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<Request> listRequest = new List();
      for (Map i in data) {
        listRequest.add(Request.fromJson(i));
      }
      if (listRequest.length == 0) _noRequest = true;
      return listRequest;
    } else {
      throw Exception('Failed to load');
    }
  }
}
