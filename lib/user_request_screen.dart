import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class UserRequestScreen extends StatefulWidget {
  @override
  _UserRequestScreenState createState() => _UserRequestScreenState();
}

class _UserRequestScreenState extends State<UserRequestScreen> {
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
        title: Text('Your Request'),
        backgroundColor: Color(0xff3277D8),
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
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Request ID: ${requestList[index].id}, User ID: ${requestList[index].userID}'),
          subtitle: Text('Content: ${requestList[index].content}, Status: ${requestList[index].status}'),
        );
      },
      itemCount: requestList.length,
    );
  }
}