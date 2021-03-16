import 'package:cse_bpm_project/source/MyColors.dart';

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/secretary/SecretaryRequestInstanceListWidget.dart';
import 'package:flutter/material.dart';

class DashboardRequestInstanceScreen extends StatefulWidget {
  final List<RequestInstance> listRequestInstance;

  const DashboardRequestInstanceScreen({Key key, this.listRequestInstance})
      : super(key: key);

  @override
  _DashboardRequestInstanceScreenState createState() =>
      _DashboardRequestInstanceScreenState();
}

class _DashboardRequestInstanceScreenState
    extends State<DashboardRequestInstanceScreen> {
  var _searchEdit = new TextEditingController();
  bool _isSearch = true;
  String _searchText = "";
  List<RequestInstance> _searchListItems;

  @override
  void initState() {
    super.initState();
  }

  _DashboardRequestInstanceScreenState() {
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
      ),
      body: Column(
        children: [
          _searchBox(),
          Divider(thickness: 1, height: 1),
          _isSearch
              ? SecretaryRequestInstanceListWidget(
                  requestInstanceList: widget.listRequestInstance,
                )
              : _searchListView(),
        ],
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
    for (int i = 0; i < widget.listRequestInstance.length; i++) {
      var item = widget.listRequestInstance[i];

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
}
