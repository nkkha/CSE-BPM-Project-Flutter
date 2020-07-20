import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/model/RequestNVQS.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class StudentRequestScreen extends StatefulWidget {
  @override
  _StudentRequestScreenState createState() => _StudentRequestScreenState();
}

class _StudentRequestScreenState extends State<StudentRequestScreen> {
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
        title: Text('Yêu cầu của sinh viên'),
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
  final response = await http.get('http://nkkha.somee.com/odata/tbRequestNVQS');

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

class RequestList extends StatelessWidget {
  final List<RequestNVQS> requestList;
  const RequestList({Key key, this.requestList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Thông tin yêu cầu",
                      textAlign: TextAlign.center,
                    ),
                    content: Container(
                      height: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Họ và tên: ${requestList[index].studentName}"),
                          Text("MSSV: ${requestList[index].id}"),
                          Text("Email: ${requestList[index].email}"),
                          Text("Phone: ${requestList[index].phone}"),
                          Text(
                              "Nội dung yêu cầu: ${requestList[index].content}"),
                          Text("Trạng thái: Thư ký khoa xét duyệt"),
                        ],
                      ),
                    ),
                    actions: [
                      FlatButton(
                        child: Text("Từ chối"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text("Phê duyệt"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    'Mã yêu cầu: ${requestList[index].id}',
                  ),
                  subtitle: Text('''Nội dung: ${requestList[index].content}
Trạng thái: Thư ký khoa đang xét duyệt.'''),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: requestList.length,
    );
  }
}
