import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/excel/CreateExcelFileScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/secretary/SecretaryRequestInstanceListWidget.dart';
import 'package:cse_bpm_project/widget/NoRequestInstanceWidget.dart';
import 'package:flutter/material.dart';

class SecretaryRequestInstanceScreen extends StatefulWidget {
  final int requestID;

  const SecretaryRequestInstanceScreen({Key key, this.requestID})
      : super(key: key);

  @override
  _SecretaryRequestInstanceScreenState createState() =>
      _SecretaryRequestInstanceScreenState();
}

class _SecretaryRequestInstanceScreenState
    extends State<SecretaryRequestInstanceScreen> {
  Future<List<RequestInstance>> futureListRequestInstance;
  bool _noRequest = false;
  bool _haveData = false;

  var _searchEdit = new TextEditingController();
  bool _isSearch = true;
  String _searchText = "";
  List<RequestInstance> _searchListItems;
  List<RequestInstance> listRequestInstance;

  @override
  void initState() {
    super.initState();
    futureListRequestInstance = fetchListRequestInstance();
  }

  _SecretaryRequestInstanceScreenState() {
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
        title: Text(
          'Yêu cầu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: <Widget>[
          _haveData
              ? IconButton(
                  icon: Icon(Icons.print_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CreateExcelFileScreen(list: listRequestInstance)),
                    );
                  },
                )
              : Container(),
        ],
      ),
      body: FutureBuilder<List<RequestInstance>>(
        future: futureListRequestInstance,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_noRequest)
              return Center(child: NoRequestInstanceWidget(isStudent: false));
            listRequestInstance = [];
            listRequestInstance = snapshot.data;
            return Column(
              children: [
                _searchBox(),
                Divider(thickness: 1, height: 1),
                _isSearch
                    ? SecretaryRequestInstanceListWidget(
                        requestInstanceList: snapshot.data,
                      )
                    : _searchListView(),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
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
    return SecretaryRequestInstanceListWidget(
        requestInstanceList: _searchListItems);
  }

  Future<List<RequestInstance>> fetchListRequestInstance() async {
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbRequestInstance/GetRequestInstanceDetails?\$filter=requestID eq ${widget.requestID}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<RequestInstance> listRequest = [];
      for (Map i in data) {
        listRequest.add(RequestInstance.fromJson(i));
      }
      if (listRequest.length == 0)
        _noRequest = true;
      else {
        setState(() {
          _haveData = true;
        });
      }
      ;
      return listRequest;
    } else {
      throw Exception('Failed to load');
    }
  }
}
