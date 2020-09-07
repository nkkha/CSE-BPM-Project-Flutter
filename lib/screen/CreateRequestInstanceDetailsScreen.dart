import 'dart:async';
import 'dart:convert';

import 'package:cse_bpm_project/screen/HomeScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateRequestInstanceDetailsScreen extends StatefulWidget {
  final int requestID;

  const CreateRequestInstanceDetailsScreen({Key key, this.requestID})
      : super(key: key);

  @override
  _CreateRequestInstanceDetailsScreenState createState() =>
      _CreateRequestInstanceDetailsScreenState();
}

class _CreateRequestInstanceDetailsScreenState
    extends State<CreateRequestInstanceDetailsScreen> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _idController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _contentController = new TextEditingController();
  FocusNode _myFocusNode1 = new FocusNode();
  FocusNode _myFocusNode2 = new FocusNode();
  FocusNode _myFocusNode3 = new FocusNode();
  FocusNode _myFocusNode4 = new FocusNode();
  FocusNode _myFocusNode5 = new FocusNode();

  @override
  void initState() {
    super.initState();
    _myFocusNode1 = new FocusNode();
    _myFocusNode2 = new FocusNode();
    _myFocusNode3 = new FocusNode();
    _myFocusNode4 = new FocusNode();
    _myFocusNode5 = new FocusNode();
    _myFocusNode1.addListener(_onOnFocusNodeEvent);
    _myFocusNode2.addListener(_onOnFocusNodeEvent);
    _myFocusNode3.addListener(_onOnFocusNodeEvent);
    _myFocusNode4.addListener(_onOnFocusNodeEvent);
    _myFocusNode5.addListener(_onOnFocusNodeEvent);
  }

  @override
  void dispose() {
    super.dispose();
    _myFocusNode1.dispose();
    _myFocusNode2.dispose();
    _myFocusNode3.dispose();
    _myFocusNode4.dispose();
    _myFocusNode5.dispose();
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin yêu cầu'),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Text(
                    'Sinh viên vui lòng điền đầy đủ các thông tin sau:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xff606470),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: StreamBuilder(
                    // stream: authBloc.nameStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode1,
                      controller: _nameController,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Họ và tên',
                        labelStyle: TextStyle(
                            color: _myFocusNode1.hasFocus
                                ? MyColors.lightBrand
                                : MyColors.mediumGray),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColors.lightGray, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: MyColors.lightBrand, width: 2.0),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  // stream: authBloc.phoneStream,
                  builder: (context, snapshot) => TextField(
                    focusNode: _myFocusNode2,
                    controller: _idController,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      errorText: snapshot.hasError ? snapshot.error : null,
                      labelText: 'MSSV',
                      labelStyle: TextStyle(
                          color: _myFocusNode2.hasFocus
                              ? MyColors.lightBrand
                              : MyColors.mediumGray),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.lightGray, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.lightBrand, width: 2.0),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: StreamBuilder(
                    // stream: authBloc.emailStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode3,
                      controller: _emailController,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            color: _myFocusNode3.hasFocus
                                ? MyColors.lightBrand
                                : MyColors.mediumGray),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColors.lightGray, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: MyColors.lightBrand, width: 2.0),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  // stream: authBloc.passStream,
                  builder: (context, snapshot) => TextField(
                    focusNode: _myFocusNode4,
                    controller: _phoneController,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      errorText: snapshot.hasError ? snapshot.error : null,
                      labelText: 'Số điện thoại',
                      labelStyle: TextStyle(
                          color: _myFocusNode4.hasFocus
                              ? MyColors.lightBrand
                              : MyColors.mediumGray),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.lightGray, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.lightBrand, width: 2.0),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: StreamBuilder(
                    // stream: authBloc.passStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode5,
                      controller: _contentController,
                      maxLines: 3,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Nội dung',
                        labelStyle: TextStyle(
                            color: _myFocusNode5.hasFocus
                                ? MyColors.lightBrand
                                : MyColors.mediumGray),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColors.lightGray, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: MyColors.lightBrand, width: 2.0),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: RaisedButton(
                      onPressed: _onSubmitRequest,
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      color: Color(0xff3277D8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmitRequest() async {
    String content = _contentController.text;
    String name = _nameController.text;
    String id = _idController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbRequestInstance',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "UserID": "$userId",
        "RequestID": "${widget.requestID}",
        "DefaultContent": "$content",
        "CurrentStepIndex": "1",
        "Status": "new"
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(isCreatedNew: true)),
        (Route<dynamic> route) => false,
      );
    } else {
      throw Exception('Failed to create request.');
    }
  }
}
