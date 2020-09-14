import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:cse_bpm_project/model/Request.dart';
import 'package:cse_bpm_project/secretary/SecretaryRequestInstanceScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';

class SecretaryRequestScreen extends StatefulWidget {
  @override
  _SecretaryRequestScreenState createState() => _SecretaryRequestScreenState();
}

class _SecretaryRequestScreenState extends State<SecretaryRequestScreen> {
  Future<List<Request>> futureListRequest;

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
      body: FutureBuilder<List<Request>>(
        future: futureListRequest,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RequestList(requestList: snapshot.data);
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

Future<List<Request>> fetchListRequest() async {
  final response = await http.get('http://nkkha.somee.com/odata/tbRequest');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['value'];
    List<Request> listRequest = new List();
    for (Map i in data) {
      listRequest.add(Request.fromJson(i));
    }
    return listRequest;
  } else {
    throw Exception('Failed to load');
  }
}

class RequestList extends StatelessWidget {
  final List<Request> requestList;

  const RequestList({Key key, this.requestList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    side: BorderSide(width: 2, color: Colors.green),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SecretaryRequestInstanceScreen(
                                    requestID: requestList[index].id,
                                  )));
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 24, horizontal: 16),
                            child: Text(
                              "${requestList[index].description}",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: MyColors.darkGray,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 16.0),
                          decoration: BoxDecoration(
                              color: MyColors.red, shape: BoxShape.circle),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              "3",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: MyColors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: requestList.length,
    );
  }
}
