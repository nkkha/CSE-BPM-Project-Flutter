import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:cse_bpm_project/model/NumOfRequestInstance.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:cse_bpm_project/widget/NoRequestWidget.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:cse_bpm_project/model/Request.dart';
import 'package:cse_bpm_project/secretary/SecretaryRequestInstanceScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:intl/intl.dart';

class SecretaryRequestScreen extends StatefulWidget {
  @override
  _SecretaryRequestScreenState createState() => _SecretaryRequestScreenState();
}

class _SecretaryRequestScreenState extends State<SecretaryRequestScreen> {
  Future<List<Request>> futureListRequest;
  Future<List<NumOfRequestInstance>> futureListNumOfRI;
  var webService = new WebService();

  var _searchEdit = new TextEditingController();
  bool _isSearch = true;
  String _searchText = "";
  List<Request> _searchListItems;
  List<Request> listRequest;
  HashMap hashMapNumOfRI;
  bool _noRequest = false;

  @override
  void initState() {
    super.initState();
    futureListRequest = fetchListRequest();
    futureListNumOfRI = webService.getListNumOfRequestInstance();
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
    return FutureBuilder<List<Request>>(
      future: futureListRequest,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (_noRequest) return NoRequestWidget(isStudent: false);
          listRequest = [];
          listRequest = snapshot.data;
          return FutureBuilder(
            future: futureListNumOfRI,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                hashMapNumOfRI = new HashMap<int, int>();
                for (NumOfRequestInstance num in snapshot.data) {
                  int id = num.requestID;
                  if (!hashMapNumOfRI.containsKey(id)) {
                    hashMapNumOfRI.putIfAbsent(
                        id, () => num.numOfRequestInstance);
                  }
                }
                return Column(
                  children: [
                    _searchBox(),
                    Divider(thickness: 1, height: 1),
                    _isSearch
                        ? RequestList(
                            requestList: listRequest,
                            hashMapNumOfRI: hashMapNumOfRI)
                        : _searchListView(),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(child: Text("${snapshot.error}"));
              }
              return Center(child: CircularProgressIndicator());
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        }
        return Center(child: CircularProgressIndicator());
      },
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
    for (int i = 0; i < listRequest.length; i++) {
      var item = listRequest[i];

      if (item.description
          .toString()
          .toLowerCase()
          .contains(_searchText.toLowerCase())) {
        _searchListItems.add(item);
      }
    }
    return RequestList(
        requestList: _searchListItems, hashMapNumOfRI: hashMapNumOfRI);
  }

  Future<List<Request>> fetchListRequest() async {
    final response = await http.get('http://nkkha.somee.com/odata/tbRequest');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<Request> listRequest = [];
      for (Map i in data) {
        listRequest.add(Request.fromJson(i));
      }
      if (listRequest.length == 0) _noRequest = true;
      return listRequest;
    } else {
      throw Exception('Failed to load');
    }
  }
}

class RequestList extends StatefulWidget {
  final List<Request> requestList;
  final HashMap hashMapNumOfRI;

  const RequestList({Key key, this.requestList, this.hashMapNumOfRI})
      : super(key: key);

  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          int num = 0;
          if (widget.hashMapNumOfRI != null) {
            if (widget.hashMapNumOfRI
                .containsKey(widget.requestList[index].id)) {
              num = widget.hashMapNumOfRI[widget.requestList[index].id];
            }
          }
          Request request = widget.requestList[index];
          String parsedStartDate = DateFormat('kk:mm - dd/MM')
              .format(DateTime.parse(request.startDate.substring(0, request.startDate.length - 6)));
          String parsedDueDate = DateFormat('kk:mm - dd/MM')
              .format(DateTime.parse(request.dueDate.substring(0, request.dueDate.length - 6)));
          return Padding(
            padding: index == 0 ? const EdgeInsets.fromLTRB(20, 10, 20, 0) : const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      // side: BorderSide(width: 2, color: MyColors.lightGray),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      "${widget.requestList[index].name}",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: MyColors.brand,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'Từ $parsedStartDate đến $parsedDueDate',
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          num > 0
                              ? Container(
                                  margin: const EdgeInsets.only(right: 16.0),
                                  decoration: BoxDecoration(
                                      color: MyColors.red,
                                      shape: BoxShape.circle),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      "$num",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: MyColors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : Container(),
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
