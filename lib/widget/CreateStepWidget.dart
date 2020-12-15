import 'dart:async';
import 'package:cse_bpm_project/model/Role.dart';
import 'package:cse_bpm_project/model/InputField.dart';
import 'package:cse_bpm_project/source/SharedPreferencesHelper.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/services.dart';

import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CreateStepWidget extends StatefulWidget {
  final int tabIndex;
  final int requestID;
  Function update;

  CreateStepWidget({Key key, this.tabIndex, this.requestID, this.update})
      : super(key: key);

  @override
  _CreateStepWidgetState createState() => _CreateStepWidgetState();
}

class _CreateStepWidgetState extends State<CreateStepWidget>
    with AutomaticKeepAliveClientMixin<CreateStepWidget> {
  @override
  bool get wantKeepAlive => true;

  var webService = WebService();

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  FocusNode _myFocusNode1 = new FocusNode();
  FocusNode _myFocusNode2 = new FocusNode();

  ProgressDialog pr;
  List<InputField> listInputField = new List();
  List<Role> _dropdownItems = new List();
  List<DropdownMenuItem<Role>> _dropdownMenuItems;
  Role _selectedItem;
  bool isCreated = false;
  int count = 0;
  bool isParallelStep = false;

  @override
  void initState() {
    super.initState();
    _myFocusNode1.addListener(_onOnFocusNodeEvent);
    _myFocusNode2.addListener(_onOnFocusNodeEvent);

    getListRole();
  }

  void getListRole() async {
    _dropdownItems.clear();
    _dropdownItems = await webService.getListRole();

    if (_dropdownItems != null) {
      setState(() {
        _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
        _selectedItem = _dropdownMenuItems[0].value;
      });
    }
  }

  List<DropdownMenuItem<Role>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<Role>> items = List();
    for (Role listItem in listItems) {
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
    _myFocusNode1.dispose();
    _myFocusNode2.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: StreamBuilder(
                // stream: authBloc.passStream,
                builder: (context, snapshot) => TextField(
                  focusNode: _myFocusNode1,
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                    errorText: snapshot.hasError ? snapshot.error : null,
                    labelText: 'Tên bước',
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
                      borderSide:
                          BorderSide(color: MyColors.lightBrand, width: 2.0),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: StreamBuilder(
                // stream: authBloc.passStream,
                builder: (context, snapshot) => TextField(
                  focusNode: _myFocusNode2,
                  controller: _descriptionController,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                    errorText: snapshot.hasError ? snapshot.error : null,
                    labelText: 'Mô tả',
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
              child: Row(
                children: [
                  Text(
                    "Người xử lý: ",
                    style: TextStyle(fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Container(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all()),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                            value: _selectedItem,
                            items: _dropdownMenuItems,
                            onChanged: (value) {
                              setState(() {
                                _selectedItem = value;
                              });
                            }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            widget.tabIndex != 0
                ? Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: isParallelStep,
                          onChanged: (bool value) {
                            setState(() {
                              isParallelStep = value;
                            });
                          },
                        ),
                        Text("Song song với bước trước?", style: TextStyle(fontSize: 16),),
                      ],
                    ),
                )
                : Container(),
            Column(
              children: List<Widget>.generate(listInputField.length,
                  (index) => createInputFieldWidget(index)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 110,
                    height: 52,
                    child: RaisedButton(
                      onPressed: () {
                        InputField inputField =
                            new InputField(inputFieldTypeID: 1);
                        setState(() {
                          listInputField.add(inputField);
                        });
                      },
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: MyColors.mediumGray)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 24),
                          Text(
                            ' Câu hỏi',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 52,
                    child: RaisedButton(
                      onPressed: () {
                        InputField inputField =
                            new InputField(inputFieldTypeID: 2);
                        setState(() {
                          listInputField.add(inputField);
                        });
                      },
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: MyColors.mediumGray)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 24,
                          ),
                          Text(
                            ' Hình ảnh',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 110,
                    height: 52,
                    child: RaisedButton(
                      onPressed: () {
                        InputField inputField =
                            new InputField(inputFieldTypeID: 3);
                        setState(() {
                          listInputField.add(inputField);
                        });
                      },
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: MyColors.mediumGray)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 24,
                          ),
                          Text(
                            ' Tài liệu',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Center(
                child: SizedBox(
                  width: 128,
                  height: 52,
                  child: !isCreated
                      ? RaisedButton(
                          onPressed: _onContinueClicked,
                          child: Text(
                            'Tiếp tục',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          color: MyColors.lightBrand,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                        )
                      : Image.asset('images/ok.png', width: 48, height: 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createInputFieldWidget(int index) {
    TextEditingController _textController = new TextEditingController();
    _textController.text = listInputField[index].title;
    _textController.addListener(() {
      listInputField[index].title = _textController.text;
    });

    String title = "";
    switch (listInputField[index].inputFieldTypeID) {
      case 2:
        title = "Tiêu đề hình ảnh";
        break;
      case 3:
        title = "Tiêu đề tài liệu";
        break;
      default:
        title = "Tiêu đề câu hỏi";
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 32, left: 8),
      child: Row(
        children: [
          Expanded(
            child: StreamBuilder(
              // stream: authBloc.passStream,
              builder: (context, snapshot) => TextField(
                controller: _textController,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                  errorText: snapshot.hasError ? snapshot.error : null,
                  labelText: title,
//              labelStyle: TextStyle(
//                  color: _myFocusNode.hasFocus
//                      ? MyColors.lightBrand
//                      : MyColors.mediumGray),
                  labelStyle: TextStyle(color: MyColors.mediumGray),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.lightGray, width: 1),
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
          ),
          IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: () {
                setState(() {
                  listInputField.removeAt(index);
                });
              }),
        ],
      ),
    );
  }

  Future<void> _onContinueClicked() async {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.update(message: "Đang xử lý...");
    await pr.show();
    int stepIndex;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (widget.tabIndex == 0) {
      stepIndex = 1;
      prefs.setInt('currentStepIndex', stepIndex);
    } else {
      int currentStepIndex = await SharedPreferencesHelper.getCurrentStepIndex();
      if (currentStepIndex != null) {
        if (!isParallelStep) {
          stepIndex = currentStepIndex + 1;
          prefs.setInt('currentStepIndex', stepIndex);
        } else {
          stepIndex = currentStepIndex;
        }
      }
    }

    webService.postCreateStep(
        widget.requestID,
        _nameController.text,
        _descriptionController.text,
        _selectedItem.id,
        stepIndex,
        (data) => update(data, stepIndex));
  }

  void update(int stepID, int stepIndex) async {
    if (stepID != null) {
      if (listInputField.length > 0) {
        for (InputField inputField in listInputField) {
          webService.postCreateInputField(
              stepID,
              null,
              inputField.inputFieldTypeID,
              inputField.title,
              (data) => updateIF(data, stepIndex));
        }
      } else {
        await pr.hide();
        setState(() {
          isCreated = true;
          Flushbar(
            icon: Image.asset('images/ic-check-circle.png',
                width: 24, height: 24),
            message: 'Thành công!',
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(8),
            borderRadius: 8,
          )..show(context);
          Future.delayed(const Duration(milliseconds: 1000), () {
            widget.  update(widget.tabIndex + 1, stepIndex);
          });
        });
      }
    } else {
      await pr.hide();
      Flushbar(
        icon: Image.asset('images/icons8-cross-mark-48.png',
            width: 24, height: 24),
        message: 'Thất bại!',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      )..show(context);
    }
  }

  void updateIF(bool isSuccessful, int stepIndex) async {
    if (isSuccessful) {
      count++;
      if (count == listInputField.length) {
        await pr.hide();
        setState(() {
          isCreated = true;
          Flushbar(
            icon: Image.asset('images/ic-check-circle.png',
                width: 24, height: 24),
            message: 'Thành công!',
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(8),
            borderRadius: 8,
          )..show(context);
          Future.delayed(const Duration(milliseconds: 1000), () {
            widget.update(widget.tabIndex + 1, stepIndex);
          });
        });
      }
    } else {
      await pr.hide();
      Flushbar(
        icon: Image.asset('images/icons8-cross-mark-48.png',
            width: 24, height: 24),
        message: 'Thất bại!',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      )..show(context);
    }
  }
}
