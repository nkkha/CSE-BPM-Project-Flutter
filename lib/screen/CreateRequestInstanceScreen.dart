import 'dart:async';
import 'dart:convert';

import 'package:cse_bpm_project/model/Request.dart';
import 'package:cse_bpm_project/widget/NoRequestWidget.dart';
import 'package:cse_bpm_project/widget/RequestListWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateRequestInstanceScreen extends StatefulWidget {
  final bool isStudent;
  CreateRequestInstanceScreen({this.isStudent});

  @override
  _CreateRequestInstanceScreenState createState() => _CreateRequestInstanceScreenState();
}

class _CreateRequestInstanceScreenState extends State<CreateRequestInstanceScreen> {

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
              if (_noRequest) return NoRequestWidget(isStudent: widget.isStudent);
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
