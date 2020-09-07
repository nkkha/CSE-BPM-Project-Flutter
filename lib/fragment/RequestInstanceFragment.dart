import 'dart:async';
import 'dart:convert';

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/screen/CreateRequestScreen.dart';
import 'package:cse_bpm_project/widget/NoRequestInstanceWidget.dart';
import 'package:cse_bpm_project/widget/RequestInstanceListWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestInstanceFragment extends StatefulWidget {
  const RequestInstanceFragment({Key key}) : super(key: key);

  @override
  _RequestInstanceFragmentState createState() => _RequestInstanceFragmentState();
}

class _RequestInstanceFragmentState extends State<RequestInstanceFragment> {
  Future<List<RequestInstance>> futureListRequest;
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
      body: FutureBuilder<List<RequestInstance>>(
        future: futureListRequest,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_noRequest) return Center(child: NoRequestInstanceWidget(true));
            return RequestInstanceListWidget(requestList: snapshot.data);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List<RequestInstance>> fetchListRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    final response = await http.get('http://nkkha.somee.com/odata/tbRequestInstance/GetRequestInstance?\$filter=userid eq $userId');

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
