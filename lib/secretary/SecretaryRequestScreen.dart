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

  var _searchEdit = new TextEditingController();
  bool _isSearch = true;
  String _searchText = "";
  List<Request> _searchListItems;
  List<Request> listRequest;

  @override
  void initState() {
    super.initState();
    futureListRequest = fetchListRequest();
  }

  _SecretaryRequestScreenState() {
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
        title: Text('Yêu cầu của sinh viên'),
      ),
      body: FutureBuilder<List<Request>>(
        future: futureListRequest,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            listRequest = new List();
            listRequest = snapshot.data;
              return Column(
                children: [
                  _searchBox(),
                  Divider(height: 1),
                  _isSearch
                      ? RequestList(requestList: listRequest)
                      : _searchListView(),
                ],
              );
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
    _searchListItems = new List();
    for (int i = 0; i < listRequest.length; i++) {
      var item = listRequest[i];

      if (item.description
          .toString()
          .toLowerCase()
          .contains(_searchText.toLowerCase())) {
        _searchListItems.add(item);
      }
    }
    return RequestList(requestList: _searchListItems);
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

class RequestList extends StatefulWidget {
  final List<Request> requestList;

  const RequestList({Key key, this.requestList}) : super(key: key);

  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10,
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
                                      requestID: widget.requestList[index].id,
                                    )));
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 16),
                              child: Text(
                                "${widget.requestList[index].description}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
        itemCount: widget.requestList.length,
      ),
    );
  }
}
