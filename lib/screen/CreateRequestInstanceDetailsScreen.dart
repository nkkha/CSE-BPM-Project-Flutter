import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'package:cse_bpm_project/model/InputField.dart';
import 'package:cse_bpm_project/model/InputFieldInstance.dart';
import 'package:cse_bpm_project/model/Request.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';

import 'package:cse_bpm_project/screen/StudentScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateRequestInstanceDetailsScreen extends StatefulWidget {
  final Request request;

  const CreateRequestInstanceDetailsScreen({Key key, this.request})
      : super(key: key);

  @override
  _CreateRequestInstanceDetailsScreenState createState() =>
      _CreateRequestInstanceDetailsScreenState();
}

class _CreateRequestInstanceDetailsScreenState
    extends State<CreateRequestInstanceDetailsScreen> {
  var webService = WebService();
  final DateFormat formatterDateTime = DateFormat('yyyy-MM-ddThh:mm:ss');
  ProgressDialog pr;
  int count = 0;

  List<InputField> listInputField = new List();
  List<InputFieldInstance> listInputFieldInstance = new List();

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

  HashMap listImage = new HashMap<int, File>();

  _imgFromCamera(Function updateImage) async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    updateImage(image);
  }

  _imgFromGallery(Function updateImage) async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    updateImage(image);
  }

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

    getListInputField();
  }

  void getListInputField() async {
    listInputField.clear();
    listInputField = await webService.getListInputField(widget.request.id);

    if (listInputField != null) {
      for (InputField inputField in listInputField) {
        listInputFieldInstance.add(new InputFieldInstance(
            inputFieldID: inputField.id,
            inputFieldTypeID: inputField.inputFieldTypeID,
            title: inputField.title));
      }
      setState(() {});
    }
  }

  void _showPicker(BuildContext context, Function updateImage) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery((data) {
                          updateImage(data);
                        });
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera((data) {
                        updateImage(data);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
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
    String startDate = DateFormat('kk:mm · dd/MM ').format(DateTime.parse(widget.request.startDate));
    String dueDate = DateFormat('kk:mm · dd/MM').format(DateTime.parse(widget.request.dueDate));

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                  child: Row(
                    children: [
                      Text(
                        'Tên yêu cầu: ' ,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(' ${widget.request.description}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic
                        ),
                      )
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                //   child: Text(
                //     'Thời gian: $startDate đến $dueDate',
                //     style: TextStyle(
                //       fontSize: 16,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                  child: Text(
                    'Sinh viên vui lòng điền đầy đủ các thông tin sau:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                //   child: StreamBuilder(
                //     // stream: authBloc.nameStream,
                //     builder: (context, snapshot) => TextField(
                //       focusNode: _myFocusNode1,
                //       controller: _nameController,
                //       style: TextStyle(fontSize: 18, color: Colors.black),
                //       decoration: InputDecoration(
                //         errorText: snapshot.hasError ? snapshot.error : null,
                //         labelText: 'Họ và tên',
                //         labelStyle: TextStyle(
                //             color: _myFocusNode1.hasFocus
                //                 ? MyColors.lightBrand
                //                 : MyColors.mediumGray),
                //         border: OutlineInputBorder(
                //           borderSide:
                //               BorderSide(color: MyColors.lightGray, width: 1),
                //           borderRadius: BorderRadius.all(Radius.circular(6)),
                //         ),
                //         focusedBorder: OutlineInputBorder(
                //           borderSide: BorderSide(
                //               color: MyColors.lightBrand, width: 2.0),
                //           borderRadius: BorderRadius.circular(6.0),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // StreamBuilder(
                //   // stream: authBloc.phoneStream,
                //   builder: (context, snapshot) => TextField(
                //     focusNode: _myFocusNode2,
                //     controller: _idController,
                //     style: TextStyle(fontSize: 18, color: Colors.black),
                //     decoration: InputDecoration(
                //       errorText: snapshot.hasError ? snapshot.error : null,
                //       labelText: 'Mssv',
                //       labelStyle: TextStyle(
                //           color: _myFocusNode2.hasFocus
                //               ? MyColors.lightBrand
                //               : MyColors.mediumGray),
                //       border: OutlineInputBorder(
                //         borderSide:
                //             BorderSide(color: MyColors.lightGray, width: 1),
                //         borderRadius: BorderRadius.all(Radius.circular(6)),
                //       ),
                //       focusedBorder: OutlineInputBorder(
                //         borderSide:
                //             BorderSide(color: MyColors.lightBrand, width: 2.0),
                //         borderRadius: BorderRadius.circular(6.0),
                //       ),
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                //   child: StreamBuilder(
                //     // stream: authBloc.emailStream,
                //     builder: (context, snapshot) => TextField(
                //       focusNode: _myFocusNode3,
                //       controller: _emailController,
                //       style: TextStyle(fontSize: 18, color: Colors.black),
                //       decoration: InputDecoration(
                //         errorText: snapshot.hasError ? snapshot.error : null,
                //         labelText: 'Email',
                //         labelStyle: TextStyle(
                //             color: _myFocusNode3.hasFocus
                //                 ? MyColors.lightBrand
                //                 : MyColors.mediumGray),
                //         border: OutlineInputBorder(
                //           borderSide:
                //               BorderSide(color: MyColors.lightGray, width: 1),
                //           borderRadius: BorderRadius.all(Radius.circular(6)),
                //         ),
                //         focusedBorder: OutlineInputBorder(
                //           borderSide: BorderSide(
                //               color: MyColors.lightBrand, width: 2.0),
                //           borderRadius: BorderRadius.circular(6.0),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // StreamBuilder(
                //   // stream: authBloc.passStream,
                //   builder: (context, snapshot) => TextField(
                //     focusNode: _myFocusNode4,
                //     controller: _phoneController,
                //     style: TextStyle(fontSize: 18, color: Colors.black),
                //     decoration: InputDecoration(
                //       errorText: snapshot.hasError ? snapshot.error : null,
                //       labelText: 'Số điện thoại',
                //       labelStyle: TextStyle(
                //           color: _myFocusNode4.hasFocus
                //               ? MyColors.lightBrand
                //               : MyColors.mediumGray),
                //       border: OutlineInputBorder(
                //         borderSide:
                //             BorderSide(color: MyColors.lightGray, width: 1),
                //         borderRadius: BorderRadius.all(Radius.circular(6)),
                //       ),
                //       focusedBorder: OutlineInputBorder(
                //         borderSide:
                //             BorderSide(color: MyColors.lightBrand, width: 2.0),
                //         borderRadius: BorderRadius.circular(6.0),
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                  child: StreamBuilder(
                    // stream: authBloc.passStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode5,
                      controller: _contentController,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 16, color: Colors.black),
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
                listInputFieldInstance.length > 0
                    ? Column(
                        children: List<Widget>.generate(
                            listInputFieldInstance.length,
                            (index) => createInputFieldInstanceWidget(index)),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: RaisedButton(
                      onPressed: _onSubmitRequest,
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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

  Widget createInputFieldInstanceWidget(int index) {
    switch (listInputFieldInstance[index].inputFieldTypeID) {
      case 1:
        return createTextFieldWidget(index);
        break;
      case 2:
        return createImageFieldWidget(index);
        break;
      case 3:
        return createUploadFileFieldWidget(index);
        break;
    }
    return Container();
  }

  Widget createTextFieldWidget(int index) {
    TextEditingController _textController = new TextEditingController();
    _textController.text = listInputFieldInstance[index].textAnswer;
    _textController.addListener(() {
      listInputFieldInstance[index].textAnswer = _textController.text;
    });

    String label = "Trả lời";

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              listInputFieldInstance[index].title,
              style: TextStyle(fontSize: 16),
            ),
          ),
          StreamBuilder(
            // stream: authBloc.passStream,
            builder: (context, snapshot) => TextField(
              controller: _textController,
              textInputAction: TextInputAction.done,
              style: TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                errorText: snapshot.hasError ? snapshot.error : null,
                labelText: label,
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
        ],
      ),
    );
  }

  Widget createImageFieldWidget(int index) {
    final int key = listInputFieldInstance[index].id;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Text(
            '${listInputFieldInstance[index].title}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(width: 10, height: 10),
          listImage[key] == null
              ? IconButton(
                  onPressed: () {
                    _showPicker(context, (data) {
                      setState(() {
                        File _image = data;
                        if (listImage.containsKey(key)) {
                          listImage.update(key, (value) => _image);
                        } else {
                          listImage.putIfAbsent(key, () => _image);
                        }
                      });
                    });
                  },
                  icon: Icon(Icons.add_a_photo, size: 36))
              : GestureDetector(
                  onTap: () {
                    _showPicker(context, (data) {
                      setState(() {
                        File _image = data;
                        if (listImage.containsKey(key)) {
                          listImage.update(key, (value) => _image);
                        } else {
                          listImage.putIfAbsent(key, () => _image);
                        }
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.file(listImage[key]),
                  ),
                ),
        ],
      ),
    );
  }

  Widget createUploadFileFieldWidget(int index) {
    return Container();
  }

  Future<void> _onSubmitRequest() async {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.update(message: "Đang xử lý...");
    await pr.show();
    String content = _contentController.text;
    // String name = _nameController.text;
    // String id = _idController.text;
    // String email = _emailController.text;
    // String phone = _phoneController.text;
    String createdDate = formatterDateTime.format(DateTime.now()) + '\-07:00';

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbRequestInstance',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "UserID": "$userId",
        "RequestID": "${widget.request.id}",
        "DefaultContent": "$content",
        "CurrentStepIndex": "1",
        "Status": "new",
        "CreatedDate": createdDate
      }),
    );

    if (response.statusCode == 200) {
      RequestInstance requestInstance = RequestInstance.fromJson(jsonDecode(response.body));
      if (listInputFieldInstance.length > 0) {
        for (InputFieldInstance inputFieldInstance in listInputFieldInstance) {
          switch (inputFieldInstance.inputFieldTypeID) {
            case 1:
              webService.postCreateInputTextFieldInstance(null, requestInstance.id, inputFieldInstance.inputFieldID, inputFieldInstance.textAnswer, (data) => update(data));
              break;
            case 2:
              webService.postCreateInputImageFieldInstance((data) => update(data));
              break;
            case 3:
              webService.postCreateInputFileFieldInstance((data) => update(data));
              break;
          }
        }
      }
    } else {
      await pr.hide();
      Flushbar(
        icon:
        Image.asset('images/ic-failed.png', width: 24, height: 24),
        message: 'Thất bại!',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      )..show(context);
      throw Exception('Failed to create request instance.');
    }
  }

  void update(bool isSuccessful) async {
    if (isSuccessful) {
      count++;
      if (count == listInputFieldInstance.length) {
        await pr.hide();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => StudentScreen(isCreatedNew: true)),
              (Route<dynamic> route) => false,
        );
      }
    } else {
      await pr.hide();
      Flushbar(
        icon:
        Image.asset('images/ic-failed.png', width: 24, height: 24),
        message: 'Thất bại!',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      )..show(context);
    }
  }
}
