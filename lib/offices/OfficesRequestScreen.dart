import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/model/StepInstance.dart';
import 'package:cse_bpm_project/widget/NoRequestInstanceWidget.dart';
import 'package:cse_bpm_project/offices/OfficesStudentRequestInstanceListWidget.dart';

class OfficesRequestScreen extends StatefulWidget {
  final int roleID;

  const OfficesRequestScreen({Key key, this.roleID}) : super(key: key);
  @override
  _OfficesRequestScreenState createState() => _OfficesRequestScreenState();
}

class _OfficesRequestScreenState extends State<OfficesRequestScreen> {
  Future<List<StepInstance>> _futureListStepInstance;
  Future<List<RequestInstance>> _futureListRequestInstance;
  String query = "";

  @override
  void initState() {
    super.initState();
    _futureListStepInstance = fetchListStepInstance(widget.roleID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yêu cầu cần xử lý'),
      ),
      body: FutureBuilder<List<StepInstance>>(
        future: _futureListStepInstance,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int index = 0;
            for (StepInstance stepInstance in snapshot.data) {
              if (index == 0) {
                query += "\$filter=id eq ${stepInstance.requestInstanceID}";
                index++;
              } else {
                query += " or id eq ${stepInstance.requestInstanceID}";
              }
            }
            _futureListRequestInstance = fetchListRequestInstance(query);
            return FutureBuilder<List<RequestInstance>>(
                future: _futureListRequestInstance,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length > 0) {
                      return OfficesStudentRequestInstanceListWidget(requestList: snapshot.data);
                    } else {
                      return NoRequestInstanceWidget(false);
                    }
                  } else if (snapshot.hasError) {
                    return Center(child: Text("${snapshot.error} request"));
                  }
                  return Center(child: CircularProgressIndicator());
                });
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

Future<List<RequestInstance>> fetchListRequestInstance(String query) async {
  List<RequestInstance> listRequestInstance = new List();
  if (query.isNotEmpty) {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbRequestInstance/GetRequestInstance?$query');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      listRequestInstance = new List();
      for (Map i in data) {
        listRequestInstance.add(RequestInstance.fromJson(i));
      }
      return listRequestInstance;
    } else {
      throw Exception('Failed to load');
    }
  }
  return listRequestInstance;
}

Future<List<StepInstance>> fetchListStepInstance(int roleID) async {
  final response = await http.get(
      'http://nkkha.somee.com/odata/tbStepInstance/GetStepInstanceDetails?\$filter=Status eq \'active\' and ApproverRoleID eq $roleID');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['value'];
    List<StepInstance> listStepInstance = new List();
    for (Map i in data) {
      listStepInstance.add(StepInstance.fromJson(i));
    }
    return listStepInstance;
  } else {
    throw Exception('Failed to load');
  }
}

//class RequestList extends StatelessWidget {
//  final List<Request> requestList;
//
//  const RequestList({Key key, this.requestList}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return ListView.builder(
//      itemBuilder: (context, index) {
//        return Padding(
//          padding: const EdgeInsets.symmetric(horizontal: 20),
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.start,
//            children: <Widget>[
//              SizedBox(
//                height: 30,
//              ),
//              Container(
//                padding: const EdgeInsets.all(8.0),
//                child: Card(
//                  child: InkWell(
//                    onTap: () {
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) =>
//                                  OfficesStudentRequestInstanceScreen(
//                                    requestID: requestList[index].id,
//                                  )));
//                    },
//                    child: Row(
//                      children: [
//                        Expanded(
//                          child: Padding(
//                            padding: const EdgeInsets.symmetric(
//                                vertical: 24, horizontal: 16),
//                            child: Text(
//                              "${requestList[index].description}",
//                              style: TextStyle(
//                                  fontSize: 16,
//                                  color: MyColors.darkGray,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                          ),
//                        ),
//                        Container(
//                          margin: const EdgeInsets.only(right: 16.0),
//                          decoration: BoxDecoration(
//                              color: MyColors.red, shape: BoxShape.circle),
//                          child: Padding(
//                            padding: const EdgeInsets.all(12),
//                            child: Text(
//                              "3",
//                              style: TextStyle(
//                                  fontSize: 16,
//                                  color: MyColors.white,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                          ),
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//              ),
//            ],
//          ),
//        );
//      },
//      itemCount: requestList.length,
//    );
//  }
//}
