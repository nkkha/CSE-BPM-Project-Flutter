import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/screen/CreateRequestInstanceScreen.dart';
import 'package:cse_bpm_project/widget/NoRequestInstanceWidget.dart';
import 'package:cse_bpm_project/widget/RequestInstanceListWidget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestInstanceFragment extends StatefulWidget {
  const RequestInstanceFragment({Key key}) : super(key: key);

  @override
  _RequestInstanceFragmentState createState() =>
      _RequestInstanceFragmentState();
}

class _RequestInstanceFragmentState extends State<RequestInstanceFragment> {
  Future<List<RequestInstance>> futureListRequestInstance;
  bool _noRequest = false;

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

  _RequestInstanceFragmentState() {
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
        automaticallyImplyLeading: false,
        title: Text(
          'Yêu cầu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset(
              'images/ic-toolbar-new.png',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateRequestInstanceScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<RequestInstance>>(
        future: futureListRequestInstance,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_noRequest)
              return Center(child: NoRequestInstanceWidget(isStudent: false));
            listRequestInstance = new List();
            listRequestInstance = snapshot.data;
            return Column(
              children: [
                _searchBox(),
                Divider(thickness: 1, height: 1),
                _isSearch
                    ? RequestInstanceListWidget(
                        requestInstanceList: listRequestInstance)
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
    _searchListItems = new List();
    for (int i = 0; i < listRequestInstance.length; i++) {
      var item = listRequestInstance[i];

      if (item.id
          .toString()
          .toLowerCase()
          .contains(_searchText.toLowerCase())) {
        _searchListItems.add(item);
      }
    }
    return RequestInstanceListWidget(requestInstanceList: _searchListItems);
  }

  Future<List<RequestInstance>> fetchListRequestInstance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    final response = await http.get(
        'http://nkkha.somee.com/odata/tbRequestInstance/GetRequestInstance?\$filter=userID eq $userId');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<RequestInstance> listRequest = new List();
      for (Map i in data) {
        listRequest.add(RequestInstance.fromJson(i));
      }
      if (listRequest.length == 0) _noRequest = true;
      return listRequest;
    } else {
      throw Exception('Failed to load');
    }
  }
}
