import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  TextEditingController _contentController = new TextEditingController();
  FocusNode _myFocusNode = new FocusNode();

  List<InputField> listInputField = new List();
  Future<List<InputField>> futureListIF;
  List<InputFieldInstance> listInputFieldInstance = new List();

  HashMap listImageFilePath = new HashMap<int, String>();
  HashMap listFilePath = new HashMap<int, String>();

  @override
  void initState() {
    super.initState();
    _myFocusNode = new FocusNode();
    _myFocusNode.addListener(_onOnFocusNodeEvent);

    futureListIF = webService.getListInputField(widget.request.id, null);
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

  void _imgFromCamera(Function updateImage) async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    updateImage(image.path);
  }

  void _imgFromGallery(Function updateImage) async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    updateImage(image.path);
  }

  // void _imgFromCamera(Function updateImage) async {
  //   // ignore: deprecated_member_use
  //   File image = await ImagePicker.pickImage(
  //       source: ImageSource.camera, imageQuality: 50);
  //   var bytes = image.readAsBytesSync();
  //   String imageB64 = base64Encode(bytes);
  //   updateImage(imageB64);
  // }
  //
  // void _imgFromGallery(Function updateImage) async {
  //   // ignore: deprecated_member_use
  //   File image = await ImagePicker.pickImage(
  //       source: ImageSource.gallery, imageQuality: 50);
  //   var bytes = image.readAsBytesSync();
  //   String imageB64 = base64Encode(bytes);
  //   updateImage(imageB64);
  // }

  void _showFilePicker(Function updateFile) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      PlatformFile platformFile = result.files.first;
      File file = File('${platformFile.path}');
      // var bytes = file.readAsBytesSync();
      // String fileB64 = base64Encode(bytes);
      updateFile(file.path, platformFile.name);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _myFocusNode.dispose();
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  @override
  Widget build(BuildContext context) {
    // String startDate = DateFormat('kk:mm · dd/MM ')
    //     .format(DateTime.parse(widget.request.startDate));
    // String dueDate = DateFormat('kk:mm · dd/MM')
    //     .format(DateTime.parse(widget.request.dueDate));

    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo yêu cầu'),
        titleSpacing: 0,
      ),
      body: FutureBuilder(
          future: futureListIF,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (listInputField.length == 0) {
                listInputField = snapshot.data;
                for (InputField inputField in listInputField) {
                  listInputFieldInstance.add(new InputFieldInstance(
                      inputFieldID: inputField.id,
                      inputFieldTypeID: inputField.inputFieldTypeID,
                      title: inputField.title));
                }
              }
              return SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 32, 0, 10),
                          child: Row(
                            children: [
                              Text(
                                'Tên yêu cầu: ',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                ' ${widget.request.name}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                          child: Text(
                            'Mô tả: ${widget.request.description}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                          child: Text(
                            'Sinh viên vui lòng điền đầy đủ các thông tin sau:',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                          child: StreamBuilder(
                            // stream: authBloc.passStream,
                            builder: (context, snapshot) => TextField(
                              focusNode: _myFocusNode,
                              controller: _contentController,
                              maxLines: 3,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                              decoration: InputDecoration(
                                errorText:
                                    snapshot.hasError ? snapshot.error : null,
                                labelText: 'Nội dung',
                                labelStyle: TextStyle(
                                    color: _myFocusNode.hasFocus
                                        ? MyColors.lightBrand
                                        : MyColors.mediumGray),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyColors.lightGray, width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
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
                                    (index) =>
                                        createInputFieldInstanceWidget(index)),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              color: Color(0xff3277D8),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(child: CircularProgressIndicator());
          }),
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
          listImageFilePath[key] == null
              ? IconButton(
                  onPressed: () {
                    _showPicker(context, (data) {
                      setState(() {
                        String filePath = data;
                        if (listImageFilePath.containsKey(key)) {
                          listImageFilePath.update(key, (value) => filePath);
                          listInputFieldInstance[index].fileContent = filePath;
                        } else {
                          listImageFilePath.putIfAbsent(key, () => filePath);
                          listInputFieldInstance[index].fileContent = filePath;
                        }
                      });
                    });
                  },
                  icon: Icon(Icons.add_a_photo, size: 36))
              : GestureDetector(
                  onTap: () {
                    _showPicker(context, (data) {
                      setState(() {
                        String filePath = data;
                        if (listImageFilePath.containsKey(key)) {
                          listImageFilePath.update(key, (value) => filePath);
                          listInputFieldInstance[index].fileContent = filePath;
                        } else {
                          listImageFilePath.putIfAbsent(key, () => filePath);
                          listInputFieldInstance[index].fileContent = filePath;
                        }
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.file(File(listImageFilePath[key])),
                  ),
                ),
        ],
      ),
    );
  }

  Widget createUploadFileFieldWidget(int index) {
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
          listFilePath[key] == null
              ? IconButton(
                  onPressed: () {
                    _showFilePicker((data, fileName) {
                      setState(() {
                        String filePath = data;
                        if (listFilePath.containsKey(key)) {
                          listFilePath.update(key, (value) => filePath);
                          listInputFieldInstance[index].fileContent = filePath;
                          listInputFieldInstance[index].fileName = fileName;
                        } else {
                          listFilePath.putIfAbsent(key, () => filePath);
                          listInputFieldInstance[index].fileContent = filePath;
                          listInputFieldInstance[index].fileName = fileName;
                        }
                      });
                    });
                  },
                  icon: Icon(Icons.file_upload, size: 36))
              : GestureDetector(
                  onTap: () {
                    _showFilePicker((data, fileName) {
                      setState(() {
                        String filePath = data;
                        if (listFilePath.containsKey(key)) {
                          listFilePath.update(key, (value) => filePath);
                          listInputFieldInstance[index].fileContent = filePath;
                          listInputFieldInstance[index].fileName = fileName;
                        } else {
                          listFilePath.putIfAbsent(key, () => filePath);
                          listInputFieldInstance[index].fileContent = filePath;
                          listInputFieldInstance[index].fileName = fileName;
                        }
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '${listInputFieldInstance[index].fileName}',
                      style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _onSubmitRequest() async {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.update(message: "Đang xử lý...");
    await pr.show();
    String content = _contentController.text;
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
        "CurrentStepIndex": "0",
        "Status": "new",
        "CreatedDate": createdDate
      }),
    );

    if (response.statusCode == 200) {
      RequestInstance requestInstance =
          RequestInstance.fromJson(jsonDecode(response.body));
      if (listInputFieldInstance.length > 0) {
        for (InputFieldInstance inputFieldInstance in listInputFieldInstance) {
          switch (inputFieldInstance.inputFieldTypeID) {
            case 1:
              // webService.postCreateInputTextFieldInstance(
              //     null,
              //     requestInstance.id,
              //     inputFieldInstance.inputFieldID,
              //     inputFieldInstance.textAnswer,
              //     (data) => update(data));
              break;
            case 2:
            case 3:
              uploadFile(
                  inputFieldInstance.fileContent,
                  requestInstance.id,
                  inputFieldInstance.inputFieldID,
                  inputFieldInstance.inputFieldTypeID);
              break;
          }
        }
      } else {
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
        icon: Image.asset('images/ic-failed.png', width: 24, height: 24),
        message: 'Thất bại!',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      )..show(context);
    }
  }

  Future<String> uploadFile(String path, int requestInstanceID,
      int inputFieldID, int inputFileType) async {
    String fileName = (path.split('/').last).split('.').first +
        DateFormat("yyyy_MM_dd_hh_mm_ss").format(DateTime.now()) +
        '.' +
        path.split('.').last;
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child(inputFileType == 2 ? 'images' : 'documents')
        .child(fileName);
    UploadTask uploadTask = firebaseStorageRef.putFile(File(path));
    uploadTask.whenComplete(() {
      return firebaseStorageRef.getDownloadURL().then((value) {
        if (value != null) {
          String fileUrl = value.split('&').first;
          webService.postCreateInputFileFieldInstance(null, requestInstanceID,
              inputFieldID, fileUrl, fileName, (data) => update(data));
        }
      });
    }).catchError((onError) {
      print(onError);
    });
    return null;
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
        icon: Image.asset('images/ic-failed.png', width: 24, height: 24),
        message: 'Thất bại!',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      )..show(context);
    }
  }
}
