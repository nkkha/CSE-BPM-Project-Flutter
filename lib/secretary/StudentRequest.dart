import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class StudentRequestScreen extends StatefulWidget {
  @override
  _StudentRequestScreenState createState() => _StudentRequestScreenState();
}

class _StudentRequestScreenState extends State<StudentRequestScreen> {
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
        title: Text('Yêu cầu của sinh viên'),
      ),
      body: Center(
        child: FutureBuilder<List<RequestInstance>>(
          future: futureListRequest,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return RequestInstanceList(requestInstanceList: snapshot.data);
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
  final response = await http.get('http://nkkha.somee.com/odata/tbRequestInstance');

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

class RequestInstanceList extends StatelessWidget {
  final List<RequestInstance> requestInstanceList;
  const RequestInstanceList({Key key, this.requestInstanceList}) : super(key: key);

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
                          Text("Họ và tên: ${requestInstanceList[index].userName}"),
                          Text("MSSV: ${requestInstanceList[index].id}"),
                          Text("Email: ${requestInstanceList[index].email}"),
                          Text("Phone: ${requestInstanceList[index].phone}"),
                          Text(
                              "Nội dung yêu cầu: ${requestInstanceList[index].defaultContent}"),
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
                    'Mã yêu cầu: ${requestInstanceList[index].id}',
                  ),
                  subtitle: Text('''Nội dung: ${requestInstanceList[index].defaultContent}
Trạng thái: Thư ký khoa đang xét duyệt.'''),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: requestInstanceList.length,
    );
  }
}
