import 'dart:async';
import 'dart:convert';

import 'package:cse_bpm_project/model/RequestNVQS.dart';
import 'package:cse_bpm_project/screen/CreateRequestScreen.dart';
import 'package:cse_bpm_project/widget/NoRequestWidget.dart';
import 'package:cse_bpm_project/widget/UserRequestListWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RequestFragment extends StatefulWidget {
  const RequestFragment({Key key}) : super(key: key);

  @override
  _RequestFragmentState createState() => _RequestFragmentState();
}

class _RequestFragmentState extends State<RequestFragment> {
  Future<List<RequestNVQS>> futureListRequest;
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
        automaticallyImplyLeading: false,
        title: Text(
          'Yêu cầu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset(
              'images/ic-toolbar-new.png',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateRequestScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<RequestNVQS>>(
          future: futureListRequest,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (_noRequest) return NoRequestWidget();
              return UserRequestListWidget(requestList: snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<List<RequestNVQS>> fetchListRequest() async {
    final response =
        await http.get('http://nkkha.somee.com/odata/tbRequestNVQS');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<RequestNVQS> listRequest = new List();
      for (Map i in data) {
        listRequest.add(RequestNVQS.fromJson(i));
      }
      if (listRequest.length == 0) _noRequest = true;
      return listRequest;
    } else {
      throw Exception('Failed to load');
    }
  }
}
