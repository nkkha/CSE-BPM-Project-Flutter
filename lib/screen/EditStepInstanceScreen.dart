import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/Status.dart';
import 'package:cse_bpm_project/model/StepInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

// ignore: must_be_immutable
class EditStepInstanceScreen extends StatefulWidget {
  Function(StepInstance) passData;
  final int roleId;
  final StepInstance stepInstance;

  EditStepInstanceScreen({Key key, this.roleId, this.stepInstance, this.passData})
      : super(key: key);

  @override
  _EditStepInstanceScreenState createState() =>
      _EditStepInstanceScreenState(stepInstance);
}

class _EditStepInstanceScreenState extends State<EditStepInstanceScreen> {
  StepInstance _stepInstance;

  _EditStepInstanceScreenState(this._stepInstance);

  TextEditingController _messageController = new TextEditingController();
  FocusNode _myFocusNode = new FocusNode();

  List<Status> _dropdownItems = [
    Status(1, "Active"),
    Status(2, "Done"),
    Status(3, "Failed"),
  ];

  List<DropdownMenuItem<Status>> _dropdownMenuItems;
  Status _selectedItem;
  bool _isStatusChanged = false;
  bool _isTextChanged = false;

  @override
  void initState() {
    super.initState();
    _myFocusNode = new FocusNode();
    _myFocusNode.addListener(_onOnFocusNodeEvent);

    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);

    switch (_stepInstance.status) {
      case 'active':
        _selectedItem = _dropdownMenuItems[0].value;
        break;
      case 'done':
        _selectedItem = _dropdownMenuItems[1].value;
        break;
      case 'failed':
        _selectedItem = _dropdownMenuItems[2].value;
        break;
    }

    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_messageController.text != "") {
      _isTextChanged = true;
    } else {
      _isTextChanged = false;
    }
    setState(() {});
  }

  List<DropdownMenuItem<Status>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<Status>> items = List();
    for (Status listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  @override
  void dispose() {
    super.dispose();
    _myFocusNode.dispose();
    _messageController.dispose();
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (_selectedItem.id) {
      case 1:
        statusColor = MyColors.amber;
        break;
      case 2:
        statusColor = MyColors.green;
        break;
      case 3:
        statusColor = MyColors.red;
        break;
    }

    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chi tiết bước'),
          titleSpacing: 0,
          bottomOpacity: 1,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(
                      "Thông tin chi tiết",
                      style: TextStyle(
                          fontSize: 20,
                          color: MyColors.darkGray,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Text(
                    "Nội dung: ${_stepInstance.description}",
                    style: TextStyle(fontSize: 16, color: MyColors.darkGray),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Text(
                    "Nơi xử lý: ...",
                    style: TextStyle(fontSize: 16, color: MyColors.darkGray),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Trạng thái: ",
                        style:
                            TextStyle(fontSize: 16, color: MyColors.darkGray),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Container(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: statusColor,
                              border: Border.all()),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                                value: _selectedItem,
                                items: _dropdownMenuItems,
                                onChanged: (value) {
                                  _checkEditStatus(value);
                                }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: StreamBuilder(
                    // stream: authBloc.passStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode,
                      controller: _messageController,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Ghi chú',
                        labelStyle: TextStyle(
                            color: _myFocusNode.hasFocus
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
                  child: Center(
                    child: SizedBox(
                      width: 128,
                      height: 52,
                      child: RaisedButton(
                        onPressed: _isStatusChanged || _isTextChanged
                            ? _onSaveClicked
                            : () {},
                        child: Text(
                          'Lưu',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        color: _isStatusChanged || _isTextChanged
                            ? Color(0xff3277D8)
                            : MyColors.lightGray,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
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

  void _checkEditStatus(Status status) {
    if (status.name.toLowerCase() == (_stepInstance.status)) {
      _selectedItem = status;
      _isStatusChanged = false;
    } else {
      _selectedItem = status;
      _isStatusChanged = true;
    }
    setState(() {});
  }

  Future<void> _onSaveClicked() async {
    var resBody = {};
    resBody["Status"] = _selectedItem.name.toLowerCase();
    resBody["ResponseMessage"] = _messageController.text;
    String str = json.encode(resBody);

    final http.Response response = await http.patch(
      'http://nkkha.somee.com/odata/tbStepInstance(${_stepInstance.id})',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: str,
    );

    if (response.statusCode == 200) {
      Flushbar(
        icon: Image.asset('images/ic-check-circle.png', width: 24, height: 24),
        message: 'Cập nhật thành công!',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      )..show(context);
      _stepInstance.status = _selectedItem.name.toLowerCase();
      _stepInstance.responseMessage = _messageController.text;
      widget.passData(_stepInstance);
    } else {
      Flushbar(
        icon: Image.asset('images/icons8-cross-mark-48.png',
            width: 24, height: 24),
        message: 'Cập nhật thất bại!',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      )..show(context);
    }
  }
}
