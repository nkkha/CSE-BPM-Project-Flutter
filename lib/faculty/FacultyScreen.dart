import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class FacultyHomeScreen extends StatefulWidget {
  @override
  _FacultyHomeScreenState createState() => _FacultyHomeScreenState();
}

class _FacultyHomeScreenState extends State<FacultyHomeScreen> {
  Future<List<RequestInstance>> futureListRequest;

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
        child: FutureBuilder<List<RequestInstance>>(
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

Future<List<RequestInstance>> fetchListRequest() async {
  final response =
      await http.get('http://nkkha.somee.com/odata/tbRequestNVQS');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['value'];
    List<RequestInstance> listRequest = new List();
    for (Map i in data) {
      listRequest.add(RequestInstance.fromJson(i));
    }
    return listRequest;
  } else {
    throw Exception('Failed to load');
  }
}

class RequestList extends StatelessWidget {
  final List<RequestInstance> requestList;
  const RequestList({Key key, this.requestList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<RequestInstance> newRequestList = new List();

    for(RequestInstance request in requestList) {
      if (request.status.contains("BCN")) {
        newRequestList.add(request);
      }
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Request ID: ${newRequestList[index].id}, User ID: ${newRequestList[index].userID}'),
          subtitle: Text('Content: ${newRequestList[index].defaultContent}, Status: ${newRequestList[index].status}'),
        );
      },
      itemCount: newRequestList.length,
    );
  }
}