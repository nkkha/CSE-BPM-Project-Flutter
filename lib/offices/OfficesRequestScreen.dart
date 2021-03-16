import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/source/MyColors.dart';
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

  var _searchEdit = new TextEditingController();
  bool _isSearch = true;
  String _searchText = "";
  List<RequestInstance> _searchListItems;
  List<RequestInstance> listRequestInstance;

  @override
  void initState() {
    super.initState();
    _futureListStepInstance = fetchListStepInstance(widget.roleID);
  }

  _OfficesRequestScreenState() {
    _searchEdit.addListener(() {
      if (_searchEdit.text.isEmpty) {
        setState(() {
          _isSearch = true;
          _searchText = "";
        });
      } else {
        setState(() {
          _isSearch = false;
          _searchText = _searchEdit.text;
        });
      }
    });
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
                      listRequestInstance = [];
                      listRequestInstance = snapshot.data;
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            OfficesStudentRequestInstanceListWidget(
                                requestInstanceList: listRequestInstance)
                            // _searchBox(),
                            // _isSearch
                            //     ? OfficesStudentRequestInstanceListWidget(
                            //     requestInstanceList: listRequestInstance)
                            //     : _searchListView(),
                          ],
                        ),
                      );
                    } else {
                      return NoRequestInstanceWidget(isStudent: false);
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

  Widget _searchBox() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(width: 1.0, color: MyColors.lightGray),
          borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _searchEdit,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          hintText: "Tìm kiếm",
          hintStyle: TextStyle(color: MyColors.mediumGray),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _searchListView() {
    _searchListItems = [];
    for (int i = 0; i < listRequestInstance.length; i++) {
      var item = listRequestInstance[i];

      if (item.id
          .toString()
          .toLowerCase()
          .contains(_searchText.toLowerCase())) {
        _searchListItems.add(item);
      }
    }
    return OfficesStudentRequestInstanceListWidget(requestInstanceList: _searchListItems);
  }

  Future<List<RequestInstance>> fetchListRequestInstance(String query) async {
    List<RequestInstance> listRequestInstance = [];
    if (query.isNotEmpty) {
      final response = await http.get(
          'http://nkkha.somee.com/odata/tbRequestInstance/GetRequestInstance?$query');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['value'];
        for (Map i in data) {
          if (!RequestInstance.fromJson(i).status.contains('failed')) {
            listRequestInstance.add(RequestInstance.fromJson(i));
          }
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
      List<StepInstance> listStepInstance = [];
      for (Map i in data) {
        listStepInstance.add(StepInstance.fromJson(i));
      }
      return listStepInstance;
    } else {
      throw Exception('Failed to load');
    }
  }
}
