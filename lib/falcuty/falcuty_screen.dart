import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class FalcutyHomeScreen extends StatefulWidget {
  @override
  _FalcutyHomeScreenState createState() => _FalcutyHomeScreenState();
}

class _FalcutyHomeScreenState extends State<FalcutyHomeScreen> {
  Future<List<RequestNVQS>> futureListRequest;

  @override
  void initState() {
    super.initState();
    futureListRequest = fetchListRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Request'),
        backgroundColor: Color(0xff3277D8),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: FutureBuilder<List<RequestNVQS>>(
          future: futureListRequest,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return RequestList(requestList: snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
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
    return listRequest;
  } else {
    throw Exception('Failed to load');
  }
}

class RequestNVQS {
  final int id;
  final String content;
  final int userID;
  final String status;

  RequestNVQS({this.id, this.content, this.userID, this.status});

  factory RequestNVQS.fromJson(Map<String, dynamic> json) {
    return RequestNVQS(
      id: json['ID'],
      content: json['Content'],
      userID: json['UserID'],
      status: json['Status'],
    );
  }
}

class RequestList extends StatelessWidget {
  final List<RequestNVQS> requestList;
  const RequestList({Key key, this.requestList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<RequestNVQS> newRequestList = new List();

    for(RequestNVQS requestNVQS in requestList) {
      if (requestNVQS.status.contains("BCN")) {
        newRequestList.add(requestNVQS);
      }
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Request ID: ${newRequestList[index].id}, User ID: ${newRequestList[index].userID}'),
          subtitle: Text('Content: ${newRequestList[index].content}, Status: ${newRequestList[index].status}'),
        );
      },
      itemCount: newRequestList.length,
    );
  }
}