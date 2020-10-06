import 'dart:async';
import 'package:cse_bpm_project/model/Role.dart';
import 'package:cse_bpm_project/model/StepInputField.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/services.dart';

import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

// ignore: must_be_immutable
class CreateStepWidget extends StatefulWidget {
  final String requestID;

  CreateStepWidget({Key key, this.requestID}) : super(key: key);

  @override
  _CreateStepWidgetState createState() => _CreateStepWidgetState();
}

class _CreateStepWidgetState extends State<CreateStepWidget>
    with AutomaticKeepAliveClientMixin<CreateStepWidget> {
  @override
  bool get wantKeepAlive => true;

  var webService = WebService();

  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _stepIndexController = new TextEditingController();
  FocusNode _myFocusNode1 = new FocusNode();
  FocusNode _myFocusNode2 = new FocusNode();

  List<StepInputField> listStepInputField = new List();
  List<Role> _dropdownItems = new List();
  List<DropdownMenuItem<Role>> _dropdownMenuItems;
  Role _selectedItem;
  bool isCreated = false;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _myFocusNode1.addListener(_onOnFocusNodeEvent);
    _myFocusNode2.addListener(_onOnFocusNodeEvent);

    getListRole();
  }

  void getListRole() async {
    _dropdownItems.clear();
    _dropdownItems = await webService.getRole();

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
    _descriptionController.dispose();
    _stepIndexController.dispose();
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  @override
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
                  controller: _descriptionController,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                    errorText: snapshot.hasError ? snapshot.error : null,
                    labelText: 'Mô tả',
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
              padding: const EdgeInsets.all(8.0),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: StreamBuilder(
                // stream: authBloc.passStream,
                builder: (context, snapshot) => TextField(
                  focusNode: _myFocusNode2,
                  controller: _stepIndexController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  textInputAction: TextInputAction.done,
                  // On
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                    errorText: snapshot.hasError ? snapshot.error : null,
                    labelText: 'Chỉ số bước',
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
            Column(
              children: List<Widget>.generate(listStepInputField.length,
                  (index) => createStepInputFieldWidget(index)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 155,
                    child: RaisedButton(
                      onPressed: () {
                        StepInputField stepInputField = new StepInputField(
                            id: null, inputFieldID: 1, stepID: 1, title: "");
                        setState(() {
                          listStepInputField.add(stepInputField);
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
                          Icon(Icons.add, size: 36),
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
                    width: 155,
                    child: RaisedButton(
                      onPressed: () {
                        StepInputField stepInputField = new StepInputField(
                            id: null, inputFieldID: 2, stepID: 1, title: "");
                        setState(() {
                          listStepInputField.add(stepInputField);
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
                            size: 36,
                          ),
                          Text(
                            ' Tải tệp lên',
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
                          onPressed: _onSaveClicked,
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

  Widget createStepInputFieldWidget(int index) {
    TextEditingController _textController = new TextEditingController();
    _textController.text = listStepInputField[index].title;
    _textController.addListener(() {
      listStepInputField[index].title = _textController.text;
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 0, 16),
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
                  labelText: listStepInputField[index].inputFieldID == 1
                      ? 'Tiêu đề câu hỏi'
                      : 'Tiêu đề tải tệp lên',
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
                  listStepInputField.removeAt(index);
                });
              }),
        ],
      ),
    );
  }

  Future<void> _onSaveClicked() async {
    webService.postCreateStep(
        widget.requestID,
        _descriptionController.text,
        _selectedItem.id,
        int.parse(_stepIndexController.text),
        (data) => update(data));
  }

  void update(int stepID) {
    if (stepID != null) {
      createStepInputField(stepID);
    } else {
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

  void createStepInputField(stepID) {
    for (StepInputField stepInputField in listStepInputField) {
      webService.postCreateStepInputField(stepID, null, stepInputField.inputFieldID, stepInputField.title, (data) => updateIF(data));
    }
  }

  void updateIF(bool isSuccessful) {
    if (isSuccessful) {
      count++;
      if (count == listStepInputField.length) {
        setState(() {
          isCreated = true;
          Flushbar(
            icon:
            Image.asset('images/ic-check-circle.png', width: 24, height: 24),
            message: 'Thành công!',
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(8),
            borderRadius: 8,
          )..show(context);
        });
      }
    } else {
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
