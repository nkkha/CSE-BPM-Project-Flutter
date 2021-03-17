import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:cse_bpm_project/model/DropdownOption.dart';
import 'package:cse_bpm_project/model/InputField.dart';
import 'package:cse_bpm_project/model/Request.dart';
import 'package:cse_bpm_project/screen/CreateStepScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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
  TextEditingController _idController = new TextEditingController();
  FocusNode _myFocusNode1 = new FocusNode();
  FocusNode _myFocusNode2 = new FocusNode();
  FocusNode _myFocusNode3 = new FocusNode();
  FocusNode _myFocusNode4 = new FocusNode();

  DateTime startDate, dueDate;
  TimeOfDay startTime, dueTime;
  final DateFormat formatterDateTime = DateFormat('yyyy-MM-ddThh:mm:ss+07:00');
  final DateFormat formatterDate = DateFormat('yyyy-MM-dd');

  var webService = WebService();

  List<InputField> listInputField = [];

  // List<List<DropdownOption>> listDropdownOptions = [];
  HashMap hashMapDropdownOptions = new HashMap<int, List<DropdownOption>>();
  ProgressDialog pr;
  int count = 0;
  int countIF = 0;
  bool isValid = false;
  bool isValidDateRange = true;

  @override
  void initState() {
    super.initState();
    _myFocusNode1 = new FocusNode();
    _myFocusNode2 = new FocusNode();
    _myFocusNode3 = new FocusNode();
    _myFocusNode4 = new FocusNode();
    _myFocusNode1.addListener(_onOnFocusNodeEvent);
    _myFocusNode2.addListener(_onOnFocusNodeEvent);
    _myFocusNode3.addListener(_onOnFocusNodeEvent);
    _myFocusNode4.addListener(_onOnFocusNodeEvent);

    DateTime dt = DateTime.now();
    startDate = new DateTime(dt.year, dt.month, dt.day, 0, 0, 0, 0, 0);
    dueDate = startDate;
    startTime = new TimeOfDay(hour: 8, minute: 0);
    dueTime = new TimeOfDay(hour: 23, minute: 59);
  }

  @override
  void dispose() {
    super.dispose();
    _myFocusNode1.dispose();
    _myFocusNode2.dispose();
    _myFocusNode3.dispose();
    _myFocusNode4.dispose();
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
        title: Text('Tạo quy trình'),
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
                  padding: const EdgeInsets.only(bottom: 20),
                  child: StreamBuilder(
                    // stream: authBloc.nameStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode4,
                      controller: _idController,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Mã quy trình *',
                        labelStyle: TextStyle(
                            color: _myFocusNode4.hasFocus
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
                StreamBuilder(
                  // stream: authBloc.nameStream,
                  builder: (context, snapshot) => TextField(
                    focusNode: _myFocusNode1,
                    controller: _nameController,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      errorText: snapshot.hasError ? snapshot.error : null,
                      labelText: 'Tên quy trình *',
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
                        borderSide:
                            BorderSide(color: MyColors.lightBrand, width: 2.0),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: StreamBuilder(
                    // stream: authBloc.phoneStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode2,
                      controller: _descriptionController,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      // keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      maxLines: null,
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Mô tả *',
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
                          borderSide: BorderSide(
                              color: MyColors.lightBrand, width: 2.0),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
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
                          "${startDate.day}/${formatTime(startDate.month)}/${formatTime(startDate.year)}",
                          style: TextStyle(fontSize: 18, color: MyColors.blue),
                        ),
                        onTap: () => _pickDateStart(),
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
                        onTap: () => _pickTimeStart(),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
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
                          "${dueDate.day}/${formatTime(dueDate.month)}/${formatTime(dueDate.year)}",
                          style: TextStyle(fontSize: 18, color: MyColors.blue),
                        ),
                        onTap: () => _pickDateEnd(),
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
                        onTap: () => _pickTimeEnd(),
                      ),
                    ],
                  ),
                ),
                !isValidDateRange
                    ? Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Thời gian không hợp lệ.',
                            style: TextStyle(color: MyColors.red),
                          ),
                        ),
                      )
                    : SizedBox(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: StreamBuilder(
                    // stream: authBloc.passStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode3,
                      controller: _numStepsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Số bước *',
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
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 130,
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
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 130,
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
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 130,
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
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 130,
                        height: 52,
                        child: RaisedButton(
                          onPressed: () {
                            int key = countIF++;
                            InputField inputField =
                                new InputField(inputFieldTypeID: 4, id: key);
                            setState(() {
                              listInputField.add(inputField);
                              List<DropdownOption> dropdownOptions = [];
                              dropdownOptions.add(
                                  new DropdownOption(content: "Tùy chọn 1"));
                              if (!hashMapDropdownOptions.containsKey(key)) {
                                hashMapDropdownOptions.putIfAbsent(
                                    key, () => dropdownOptions);
                              }
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
                                ' Menu',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: SizedBox(
                    width: 120,
                    height: 52,
                    child: RaisedButton(
                      onPressed: _onContinueBtn,
                      child: Text(
                        'Tiếp tục',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      color: Color(0xff3277D8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
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

  Widget createInputFieldWidget(int index) {
    TextEditingController _textController = new TextEditingController();
    _textController.text = listInputField[index].title;
    _textController.addListener(() {
      listInputField[index].title = _textController.text;
    });

    int key;
    String title = "";
    switch (listInputField[index].inputFieldTypeID) {
      case 1:
        title = "Tiêu đề câu hỏi *";
        break;
      case 2:
        title = "Tiêu đề hình ảnh *";
        break;
      case 3:
        title = "Tiêu đề tài liệu *";
        break;
      case 4:
        title = "Tiêu đề menu *";
        key = listInputField[index].id;
        break;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
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
              IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() {
                      if (listInputField[index].inputFieldTypeID == 4) {
                        hashMapDropdownOptions.remove(key);
                      }
                      listInputField.removeAt(index);
                    });
                  }),
            ],
          ),
        ),
        hashMapDropdownOptions.length > 0 &&
                listInputField[index].inputFieldTypeID == 4
            ? Column(
                children: List<Widget>.generate(
                    hashMapDropdownOptions[key].length,
                    (index) => createDropdownOptionWidget(
                            index,
                            hashMapDropdownOptions[key][index],
                            (content) => hashMapDropdownOptions[key][index]
                                .content = content, (delete) {
                          if (delete) {
                            setState(() {
                              hashMapDropdownOptions[key].removeAt(index);
                            });
                          }
                        }, (add) {
                          if (add) {
                            setState(() {
                              hashMapDropdownOptions[key].add(new DropdownOption(
                                  content:
                                      "Tùy chọn ${hashMapDropdownOptions[key].length + 1}"));
                            });
                          }
                        })),
              )
            : Container(),
      ],
    );
  }

  Widget createDropdownOptionWidget(int index, DropdownOption dropdownOption,
      Function updateContent, Function delete, Function add) {
    TextEditingController _textController = new TextEditingController();
    _textController.text = dropdownOption.content;
    _textController.addListener(() {
      dropdownOption.content = _textController.text;
      updateContent(dropdownOption.content);
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
                  labelText: "Tùy chọn ${index + 1}",
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
          index != 0
              ? IconButton(
                  icon: Icon(Icons.highlight_off),
                  onPressed: () {
                    delete(true);
                  })
              : IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () {
                    add(true);
                  }),
        ],
      ),
    );
  }

  Future<void> _onContinueBtn() async {
    if (validate()) {
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: true);
      pr.update(message: "Đang xử lý...");
      await pr.show();

      String name = _nameController.text;
      String description = _descriptionController.text;
      DateTime currentDateTime = DateTime.now();
      String createdTime = formatterDateTime.format(currentDateTime);
      String startDateStr = formatterDate.format(startDate) +
          'T' +
          formatTime(startTime.hour) +
          ':' +
          formatTime(startTime.minute) +
          ':00+07:00';
      String dueDateStr = formatterDate.format(dueDate) +
          'T' +
          formatTime(dueTime.hour) +
          ':' +
          formatTime(dueTime.minute) +
          ':00+07:00';
      int numOfSteps = int.parse(_numStepsController.text);
      String keyword = _idController.text;

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
            "CreatedTime": createdTime,
            "StartDate": startDateStr,
            "DueDate": dueDateStr,
            "NumOfSteps": '$numOfSteps',
            "Keyword": keyword
          }),
        );

        if (response.statusCode == 200) {
          Request request = Request.fromJson(jsonDecode(response.body));
          if (listInputField.length > 0) {
            int index = 0;
            for (InputField inputField in listInputField) {
              index++;
              webService.postCreateInputField(
                  null,
                  request.id,
                  inputField.inputFieldTypeID,
                  inputField.title,
                  index,
                  (data) => update(data, numOfSteps, request.id));
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
          await pr.hide();
          Flushbar(
            icon: Image.asset('images/icons8-exclamation-mark-48.png',
                width: 24, height: 24),
            message: 'Mã quy trình đã tồn tại!',
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          )..show(context);
        }
      }
    } else {
      Flushbar(
        icon: Image.asset('images/icons8-exclamation-mark-48.png',
            width: 24, height: 24),
        message: 'Vui lòng điền đầy đủ thông tin!',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      )..show(context);
    }
  }

  bool validate() {
    if (listInputField.length > 0) {
      for (InputField ip in listInputField) {
        if (ip.title == null || ip.title == "") return false;
      }
    }
    if (_idController.text == "" ||
        _nameController.text == "" ||
        _descriptionController.text == "" ||
        _numStepsController.text == "" ||
        !isValidDateRange) return false;
    return true;
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

  void _pickDateStart() async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: startDate,
    );

    if (date != null) {
      setState(() {
        startDate = date;
        checkValidDateRange();
      });
    }
  }

  void _pickDateEnd() async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: dueDate,
    );

    if (date != null) {
      setState(() {
        dueDate = date;
        checkValidDateRange();
      });
    }
  }

  void _pickTimeStart() async {
    TimeOfDay time =
        await showTimePicker(context: context, initialTime: startTime);

    if (time != null)
      setState(() {
        startTime = time;
        checkValidDateRange();
      });
  }

  void _pickTimeEnd() async {
    TimeOfDay time =
        await showTimePicker(context: context, initialTime: dueTime);

    if (time != null)
      setState(() {
        dueTime = time;
        checkValidDateRange();
      });
  }

  void checkValidDateRange() {
    if (startDate.compareTo(dueDate) == 0) {
      if (toDouble(startTime) < toDouble(dueTime))
        isValidDateRange = true;
      else
        isValidDateRange = false;
    } else if (startDate.compareTo(dueDate) > 0)
      isValidDateRange = false;
    else
      isValidDateRange = true;
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;
}
