import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/model/InputField.dart';
import 'package:cse_bpm_project/model/Request.dart';
import 'package:cse_bpm_project/screen/CreateStepScreen.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({Key key}) : super(key: key);

  @override
  _CreateRequestScreenState createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _numStepsController = new TextEditingController();
  FocusNode _myFocusNode1 = new FocusNode();
  FocusNode _myFocusNode2 = new FocusNode();
  FocusNode _myFocusNode3 = new FocusNode();

  DateTime startDate, dueDate;
  TimeOfDay startTime, dueTime;
  final DateFormat formatterDateTime = DateFormat('yyyy-MM-ddThh:mm:ss');
  final DateFormat formatterDate = DateFormat('yyyy-MM-dd');

  var webService = WebService();

  List<InputField> listInputField = new List();
  ProgressDialog pr;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _myFocusNode1 = new FocusNode();
    _myFocusNode2 = new FocusNode();
    _myFocusNode3 = new FocusNode();
    _myFocusNode1.addListener(_onOnFocusNodeEvent);
    _myFocusNode2.addListener(_onOnFocusNodeEvent);
    _myFocusNode3.addListener(_onOnFocusNodeEvent);

    startDate = DateTime.now();
    dueDate = DateTime.now();
    startTime = TimeOfDay.now();
    dueTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    super.dispose();
    _myFocusNode1.dispose();
    _myFocusNode2.dispose();
    _myFocusNode3.dispose();
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
        title: Text('Tạo yêu cầu'),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: StreamBuilder(
                    // stream: authBloc.nameStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode1,
                      controller: _nameController,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Tên yêu cầu',
                        labelStyle: TextStyle(
                            color: _myFocusNode1.hasFocus
                                ? MyColors.lightBrand
                                : MyColors.mediumGray),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: MyColors.mediumGray, width: 1),
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
                  padding: const EdgeInsets.only(bottom: 32),
                  child: StreamBuilder(
                    // stream: authBloc.phoneStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode2,
                      controller: _descriptionController,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Mô tả',
                        labelStyle: TextStyle(
                            color: _myFocusNode2.hasFocus
                                ? MyColors.lightBrand
                                : MyColors.mediumGray),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColors.mediumGray, width: 1),
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
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: MyColors.mediumGray)),
                  child: Row(
                    children: [
                      Text(
                        "Thời gian bắt đầu: ",
                        style:
                            TextStyle(fontSize: 18, color: MyColors.mediumGray),
                      ),
                      InkWell(
                        child: Text(
                          "${startDate.year}/${formatTime(startDate.month)}/${formatTime(startDate.day)}",
                          style: TextStyle(fontSize: 18, color: MyColors.blue),
                        ),
                        onTap: () => _pickDate(true),
                      ),
                      Text(
                        " - ",
                        style:
                            TextStyle(fontSize: 18, color: MyColors.mediumGray),
                      ),
                      InkWell(
                        child: Text(
                          "${formatTime(startTime.hour)}:${formatTime(startTime.minute)}",
                          style: TextStyle(fontSize: 18, color: MyColors.blue),
                        ),
                        onTap: () => _pickTime(true),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: MyColors.mediumGray)),
                  child: Row(
                    children: [
                      Text(
                        "Thời gian kết thúc: ",
                        style:
                            TextStyle(fontSize: 18, color: MyColors.mediumGray),
                      ),
                      InkWell(
                        child: Text(
                          "${dueDate.year}/${formatTime(dueDate.month)}/${formatTime(dueDate.day)}",
                          style: TextStyle(fontSize: 18, color: MyColors.blue),
                        ),
                        onTap: () => _pickDate(false),
                      ),
                      Text(
                        " - ",
                        style:
                            TextStyle(fontSize: 18, color: MyColors.mediumGray),
                      ),
                      InkWell(
                        child: Text(
                          "${formatTime(dueTime.hour)}:${formatTime(dueTime.minute)}",
                          style: TextStyle(fontSize: 18, color: MyColors.blue),
                        ),
                        onTap: () => _pickTime(false),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: StreamBuilder(
                    // stream: authBloc.passStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode3,
                      controller: _numStepsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      // Only numbers                      style: TextStyle(fontSize: 18, color: Colors.black),
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Số bước',
                        labelStyle: TextStyle(
                            color: _myFocusNode3.hasFocus
                                ? MyColors.lightBrand
                                : MyColors.mediumGray),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColors.mediumGray, width: 1),
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
                Column(
                  children: List<Widget>.generate(listInputField.length,
                          (index) => createInputFieldWidget(index)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 110,
                        child: RaisedButton(
                          onPressed: () {
                            InputField inputField = new InputField(inputFieldTypeID: 1);
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
                        child: RaisedButton(
                          onPressed: () {
                            InputField inputField = new InputField(inputFieldTypeID: 2);
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
                        child: RaisedButton(
                          onPressed: () {
                            InputField inputField = new InputField(inputFieldTypeID: 3);
                            setState(() {
                              listInputField.add(inputField );
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
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 52,
                        child: RaisedButton(
                          onPressed: _onContinueBtn,
                          child: Text(
                            'Tiếp tục',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          color: Color(0xff3277D8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.only(bottom: 32),
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

  Future<void> _onContinueBtn() async {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.update(message: "Đang xử lý...");
    await pr.show();

    String name = _nameController.text;
    String description = _descriptionController.text;
    DateTime currentDateTime = DateTime.now();
    String createdTime = formatterDateTime.format(currentDateTime) + '\-07:00';
    String startDateStr = formatterDate.format(startDate) +
        'T' +
        formatTime(startTime.hour) +
        ':' +
        formatTime(startTime.minute) +
        ':00-07:00';
    String dueDateStr = formatterDate.format(dueDate) +
        'T' +
        formatTime(dueTime.hour) +
        ':' +
        formatTime(dueTime.minute) +
        ':00-07:00';
    int numOfSteps = int.parse(_numStepsController.text);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    if (userId != 0) {
      final http.Response response = await http.post(
        'http://nkkha.somee.com/odata/tbRequest',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "Name": name,
          "Description": description,
          "Status": 'active',
          "CreatorID": '$userId',
          "CreatedTime": '$createdTime',
          "StartDate": '$startDateStr',
          "DueDate": '$dueDateStr',
          "NumOfSteps": '$numOfSteps'
        }),
      );

      if (response.statusCode == 200) {
        Request request = Request.fromJson(jsonDecode(response.body));
        if (listInputField.length > 0) {
          for (InputField inputField in listInputField) {
            webService.postCreateInputField(null, request.id, inputField.inputFieldTypeID, inputField.title, (data) => update(data, numOfSteps, request.id));
          }
        } else {
          await pr.hide();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateStepScreen(
                  numOfSteps: numOfSteps,
                  requestID: request.id,
                )),
          );
        }
      } else {
        throw Exception('Failed to create request.');
      }
    }
  }

  void update(bool isSuccessful, int numOfSteps, int requestID) async {
    if (isSuccessful) {
      count++;
      if (count == listInputField.length) {
        await pr.hide();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateStepScreen(
                numOfSteps: numOfSteps,
                requestID: requestID,
              )),
        );
      }
    }
  }

  String formatTime(int num) {
    return num < 10 ? '0$num' : num.toString();
  }

  _pickDate(bool isStart) async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: startDate,
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          startDate = date;
        } else {
          dueDate = date;
        }
      });
    }
  }

  _pickTime(bool isStart) async {
    TimeOfDay time =
        await showTimePicker(context: context, initialTime: startTime);

    if (time != null)
      setState(() {
        if (isStart) {
          startTime = time;
        } else {
          dueTime = time;
        }
      });
  }
}
