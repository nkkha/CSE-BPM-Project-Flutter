import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cse_bpm_project/model/InputField.dart';
import 'package:cse_bpm_project/model/InputFieldInstance.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/model/StepInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/source/SharedPreferencesHelper.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

// ignore: must_be_immutable
class StepDetailsWidget extends StatefulWidget {
  RequestInstance requestInstance;
  final int tabIndex;
  final int numOfSteps;
  Function update;

  StepDetailsWidget(
      {Key key,
      this.requestInstance,
      this.tabIndex,
      this.numOfSteps,
      this.update})
      : super(key: key);

  @override
  _StepDetailsWidgetState createState() => _StepDetailsWidgetState();
}

class _StepDetailsWidgetState extends State<StepDetailsWidget> {
  var webService = WebService();
  ProgressDialog pr;
  int roleID;

  Future<List<StepInstance>> futureListStepInstance;
  List<StepInstance> stepInstanceList = new List();

  HashMap hashMapInputFields = new HashMap<int, List<InputField>>();
  HashMap hashMapInputFieldInstances =
      new HashMap<int, List<InputFieldInstance>>();
  HashMap listImageBytes = new HashMap<int, Uint8List>();
  HashMap listFileBytes = new HashMap<int, Uint8List>();

  final DateFormat formatterDateTime = DateFormat('yyyy-MM-ddThh:mm:ss-07:00');

  @override
  void initState() {
    super.initState();
    futureListStepInstance =
        webService.getStepInstances(widget.tabIndex, widget.requestInstance.id);
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
    var bytes = image.readAsBytesSync();
    String imageB64 = base64Encode(bytes);
    updateImage(imageB64);
  }

  void _imgFromGallery(Function updateImage) async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    var bytes = image.readAsBytesSync();
    String imageB64 = base64Encode(bytes);
    updateImage(imageB64);
  }

  void _showFilePicker(Function updateFile) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      PlatformFile platformFile = result.files.first;
      File file = File('${platformFile.path}');
      var bytes = file.readAsBytesSync();
      String fileB64 = base64Encode(bytes);
      updateFile(fileB64, platformFile.name);
    }
  }

  Widget build(BuildContext context) {
    int currentStepIndex = widget.requestInstance.currentStepIndex;
    return widget.tabIndex > currentStepIndex
        ? Center(child: Text('Bước $currentStepIndex chưa hoàn thành'))
        : FutureBuilder<List<StepInstance>>(
            future: futureListStepInstance,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                stepInstanceList = snapshot.data;
                return SingleChildScrollView(
                    child: _buildStepDetails(stepInstanceList));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(child: CircularProgressIndicator());
            },
          );
  }

  Widget _buildStepDetails(List<StepInstance> stepInstanceList) {
    String stepStatusInfo = widget.tabIndex == widget.numOfSteps
        ? "Yêu cầu đã hoàn thành!"
        : "Tất cả các bước bên trên đã hoàn thành!";
    String imgUrl = "images/ok.png";

    for (var stepInstance in stepInstanceList) {
      if (stepInstance.status.contains("active")) {
        stepStatusInfo = "Vui lòng đợi các bước bên trên hoàn thành!";
        imgUrl = "images/timer.png";
        break;
      }
    }

    for (var stepInstance in stepInstanceList) {
      if (stepInstance.status.contains("failed")) {
        stepStatusInfo = "Yêu cầu đã thất bại!";
        imgUrl = "images/ic-failed.png";
        break;
      }
    }

    return Column(
      children: [
        SizedBox(height: 16),
        stepInstanceList.length == 1
            ? _buildStepRow(stepInstanceList[0], 1)
            : ListView.builder(
                itemCount: stepInstanceList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildStepRow(stepInstanceList[index], index + 1);
                },
              ),
        Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    stepStatusInfo,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Image.asset(imgUrl, width: 48, height: 48),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildStepRow(StepInstance stepInstance, int stepIndex) {
    Color statusColor;

    switch (stepInstance.status) {
      case 'active':
        statusColor = MyColors.amber;
        break;
      case 'done':
        statusColor = MyColors.green;
        break;
      case 'failed':
        statusColor = MyColors.red;
        break;
    }

    return FutureBuilder<int>(
        future: SharedPreferencesHelper.getRoleId(),
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData && roleID == null) {
            roleID = snapshot.data;
          }
          return roleID != null
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      side: BorderSide(width: 2, color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    stepInstance.description,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: Text(
                                    stepInstance.status,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: MyColors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        stepInstance.status.contains('active') &&
                                stepInstance.approverRoleID == roleID
                            ? _buildInputFieldColumn(stepInstance, stepIndex)
                            : _buildInputFieldInstanceColumn(stepInstance.id, stepIndex, roleID),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildCheckBox(stepInstance, roleID, stepIndex),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox();
        });
  }

  _buildInputFieldColumn(StepInstance stepInstance, int stepIndex) {
    return FutureBuilder(
        future: webService.getListInputField(null, stepInstance.stepID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              if (!hashMapInputFields.containsKey(stepIndex)) {
                List<InputField> listIF = new List();
                listIF = snapshot.data;
                hashMapInputFields.putIfAbsent(stepIndex, () => listIF);
                if (!hashMapInputFieldInstances.containsKey(stepIndex)) {
                  List<InputFieldInstance> listIFI = new List();
                  for (InputField inputField in hashMapInputFields[stepIndex]) {
                    listIFI.add(new InputFieldInstance(
                        inputFieldID: inputField.id,
                        stepInstanceID: stepInstance.id,
                        inputFieldTypeID: inputField.inputFieldTypeID,
                        title: inputField.title));
                  }
                  hashMapInputFieldInstances.putIfAbsent(stepIndex, () => listIFI);
                }
              }
            }
            return Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  hashMapInputFieldInstances.length > 0
                      ? Column(
                          children: List<Widget>.generate(
                              hashMapInputFieldInstances[stepIndex].length,
                              (index) => createInputFieldInstanceWidget(
                                  stepIndex, index)),
                        )
                      : Container(),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CircularProgressIndicator(),
          ));
        });
  }

  Widget createInputFieldInstanceWidget(int stepIndex, int index) {
    switch (hashMapInputFieldInstances[stepIndex][index].inputFieldTypeID) {
      case 1:
        return createTextFieldWidget(stepIndex, index);
        break;
      case 2:
        return createImageFieldWidget(stepIndex, index);
        break;
      case 3:
        return createUploadFileFieldWidget(stepIndex, index);
        break;
    }
    return Container();
  }

  Widget createTextFieldWidget(int stepIndex, int index) {
    TextEditingController _textController = new TextEditingController();
    _textController.text = hashMapInputFieldInstances[stepIndex][index].textAnswer;
    _textController.addListener(() {
      hashMapInputFieldInstances[stepIndex][index].textAnswer =
          _textController.text;
    });

    String label = "Trả lời";

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              hashMapInputFieldInstances[stepIndex][index].title,
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

  Widget createImageFieldWidget(int stepIndex, int index) {
    final int key = hashMapInputFieldInstances[stepIndex][index].inputFieldID;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Text(
            '${hashMapInputFieldInstances[stepIndex][index].title}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(width: 10, height: 10),
          listImageBytes[key] == null
              ? IconButton(
                  onPressed: () {
                    _showPicker(context, (data) {
                      setState(() {
                        Uint8List decodedBytes = base64Decode(data);
                        if (listImageBytes.containsKey(key)) {
                          listImageBytes.update(key, (value) => decodedBytes);
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = data;
                        } else {
                          listImageBytes.putIfAbsent(key, () => decodedBytes);
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = data;
                        }
                      });
                    });
                  },
                  icon: Icon(Icons.add_a_photo, size: 36))
              : GestureDetector(
                  onTap: () {
                    _showPicker(context, (data) {
                      setState(() {
                        Uint8List decodedBytes = base64Decode(data);
                        if (listImageBytes.containsKey(key)) {
                          listImageBytes.update(key, (value) => decodedBytes);
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = data;
                        } else {
                          listImageBytes.putIfAbsent(key, () => decodedBytes);
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = data;
                        }
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.memory(listImageBytes[key]),
                  ),
                ),
        ],
      ),
    );
  }

  Widget createUploadFileFieldWidget(int stepIndex, int index) {
    final int key = hashMapInputFieldInstances[stepIndex][index].inputFieldID;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Text(
            '${hashMapInputFieldInstances[stepIndex][index].title}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(width: 10, height: 10),
          listFileBytes[key] == null
              ? IconButton(
                  onPressed: () {
                    _showFilePicker((fileB64, fileName) {
                      setState(() {
                        Uint8List decodedBytes = base64Decode(fileB64);
                        if (listFileBytes.containsKey(key)) {
                          listFileBytes.update(key, (value) => decodedBytes);
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = fileB64;
                          hashMapInputFieldInstances[stepIndex][index].fileName =
                              fileName;
                        } else {
                          listFileBytes.putIfAbsent(key, () => decodedBytes);
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = fileB64;
                          hashMapInputFieldInstances[stepIndex][index].fileName =
                              fileName;
                        }
                      });
                    });
                  },
                  icon: Icon(Icons.file_upload, size: 36))
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '${hashMapInputFieldInstances[stepIndex][index].fileName}',
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
    );
  }

  _buildInputFieldInstanceColumn(int stepInstanceID, int stepIndex, int roleID) {
    return FutureBuilder(
      future: webService.getListInputFieldInstance(null, stepInstanceID),
      builder: (context, snapshot) {
        if (hashMapInputFieldInstances.containsKey(stepIndex)) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: List<Widget>.generate(
                  hashMapInputFieldInstances[stepIndex].length,
                      (index) =>
                      _buildInputFieldInstanceField(stepIndex, index)),
            ),
          );
        } else if (snapshot.hasData) {
          if (!hashMapInputFieldInstances.containsKey(stepIndex)) {
            if (snapshot.data.length > 0) {
              List<InputFieldInstance> listIFI = new List();
              listIFI = snapshot.data;
              hashMapInputFieldInstances.putIfAbsent(
                  stepIndex, () => listIFI);
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: List<Widget>.generate(
                      hashMapInputFieldInstances[stepIndex].length,
                      (index) =>
                          _buildInputFieldInstanceField(stepIndex, index)),
                ),
              );
            } else {
              return SizedBox();
            }
          } else {
            return SizedBox();
          }
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CircularProgressIndicator(),
        ));
      },
    );
  }

  _buildInputFieldInstanceField(int stepIndex, int index) {
    switch (hashMapInputFieldInstances[stepIndex][index].inputFieldTypeID) {
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    '${hashMapInputFieldInstances[stepIndex][index].title}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    '${hashMapInputFieldInstances[stepIndex][index].textAnswer}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        );
        break;
      case 2:
        Uint8List decodedBytes;
        if (hashMapInputFieldInstances[stepIndex][index].fileContent != null) {
          decodedBytes = base64Decode(
              hashMapInputFieldInstances[stepIndex][index].fileContent);
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                '${hashMapInputFieldInstances[stepIndex][index].title}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: decodedBytes != null
                  ? Image.memory(
                      decodedBytes,
                      fit: BoxFit.fitWidth,
                    )
                  : Text(
                      'null',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
            ),
          ],
        );
        break;
      case 3:
        if (hashMapInputFieldInstances[stepIndex][index].fileContent != null) {
          Uint8List decodedBytes = base64Decode(
              hashMapInputFieldInstances[stepIndex][index].fileContent);
          return FutureBuilder(
            future: getApplicationDocumentsDirectory(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                File file = new File(
                    '${snapshot.data.path}/${hashMapInputFieldInstances[stepIndex][index].fileName}');
                file.writeAsBytesSync(decodedBytes);
                return FutureBuilder(
                  future: file.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              '${hashMapInputFieldInstances[stepIndex][index].title}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: RaisedButton(
                              color: MyColors.lightBrand,
                              child: Text(
                                "Mở file",
                                style: TextStyle(
                                    fontSize: 16, color: MyColors.white),
                              ),
                              onPressed: () => openFile(file.path),
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                );
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '${hashMapInputFieldInstances[stepIndex][index].title}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  "null",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        }
        break;
    }
  }

  Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }

  _buildCheckBox(StepInstance stepInstance, int roleId, int stepIndex) {
    if (stepInstance.approverRoleID == roleId &&
        !stepInstance.status.contains('failed') &&
        !stepInstance.status.contains('done')) {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0, bottom: 8),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 8),
              width: 75,
              child: RaisedButton(
                onPressed: () =>
                    _showAlertDialog(context, 1, stepInstance, stepIndex),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.red)),
                child: Image.asset(
                  'images/icons8-cross-mark-48.png',
                  width: 28,
                  height: 28,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 8),
              width: 75,
              child: RaisedButton(
                onPressed: () =>
                    _showAlertDialog(context, 2, stepInstance, stepIndex),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.green)),
                child: Image.asset(
                  'images/icons8-check-mark-48.png',
                  width: 28,
                  height: 28,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }

  _showAlertDialog(
      BuildContext context, index, StepInstance stepInstance, int stepIndex) {
    TextEditingController messageController = new TextEditingController();
    Alert(
        context: context,
        title: "Xác nhận",
        content: Column(
          children: <Widget>[
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                icon: Icon(Icons.message_outlined),
                labelText: 'Ghi chú',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Huỷ bỏ",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            onPressed: () => _didTapButton(
                index, messageController.text, stepInstance, stepIndex),
            child: Text(
              "Đồng ý",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  Future<void> _didTapButton(int indexType, String message,
      StepInstance stepInstance, int stepIndex) async {
    Navigator.pop(context);

    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.update(message: "Đang xử lý...");
    await pr.show();

    final userID = await SharedPreferencesHelper.getUserId();

    if (userID != null) {
      var resBody = {};
      // indexType = 1: Reject, indexType = 2: Approve
      resBody["Status"] = indexType == 1 ? "failed" : "done";
      resBody["ResponseMessage"] = message;
      resBody["ApproverID"] = userID;
      resBody["FinishedDate"] = formatterDateTime.format(DateTime.now());
      String str = json.encode(resBody);

      final http.Response response = await http.patch(
        'http://nkkha.somee.com/odata/tbStepInstance(${stepInstance.id})',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: str,
      );

      if (response.statusCode == 200) {
        int count = 0;
        if (indexType == 1) {
          stepInstance.status = 'failed';
          webService.patchRequestInstanceFailed(stepInstance.requestInstanceID,
              () => _hidePr(0, false, stepInstance));
        } else {
          stepInstance.status = 'done';
          if (roleID == stepInstance.approverRoleID && hashMapInputFieldInstances.containsKey(stepIndex)) {
            for (InputFieldInstance inputFieldInstance
                in hashMapInputFieldInstances[stepIndex]) {
              switch (inputFieldInstance.inputFieldTypeID) {
                case 1:
                  webService.postCreateInputTextFieldInstance(
                      inputFieldInstance.stepInstanceID,
                      null,
                      inputFieldInstance.inputFieldID,
                      inputFieldInstance.textAnswer, (isSuccessful) {
                    if (isSuccessful) {
                      count++;
                      if (count == hashMapInputFieldInstances[stepIndex].length) {
                        if (stepInstanceList.length == 1) {
                          if (widget.tabIndex == widget.numOfSteps) {
                            webService.patchRequestInstanceFinished(
                                stepInstance.requestInstanceID,
                                    () => _hidePr(1, false, stepInstance));
                          } else {
                            webService.patchRequestInstanceStepIndex(
                                widget.requestInstance,
                                    (data) => _hidePr(2, data, stepInstance));
                          }
                        } else if (stepInstanceList.length > 1) {
                          if (widget.tabIndex == widget.numOfSteps) {
                            webService.getOtherCurrentStepInstances(
                                widget.requestInstance,
                                stepInstance.id,
                                widget.tabIndex,
                                true,
                                    (data) => _hidePr(2, data, stepInstance));
                          } else {
                            webService.getOtherCurrentStepInstances(
                                widget.requestInstance,
                                stepInstance.id,
                                widget.tabIndex,
                                false,
                                    (data) => _hidePr(2, data, stepInstance));
                          }
                        }
                      }
                    } else {
                      _hideByError();
                    }
                  });
                  break;
                case 2:
                case 3:
                  webService.postCreateInputFileFieldInstance(
                      inputFieldInstance.stepInstanceID,
                      null,
                      inputFieldInstance.inputFieldID,
                      inputFieldInstance.fileContent,
                      inputFieldInstance.fileName, (isSuccessful) {
                    if (isSuccessful) {
                      count++;
                      if (count == hashMapInputFieldInstances[stepIndex].length) {
                        if (stepInstanceList.length == 1) {
                          if (widget.tabIndex == widget.numOfSteps) {
                            webService.patchRequestInstanceFinished(
                                stepInstance.requestInstanceID,
                                    () => _hidePr(1, false, stepInstance));
                          } else {
                            webService.patchRequestInstanceStepIndex(
                                widget.requestInstance,
                                    (data) => _hidePr(2, data, stepInstance));
                          }
                        } else if (stepInstanceList.length > 1) {
                          if (widget.tabIndex == widget.numOfSteps) {
                            webService.getOtherCurrentStepInstances(
                                widget.requestInstance,
                                stepInstance.id,
                                widget.tabIndex,
                                true,
                                    (data) => _hidePr(2, data, stepInstance));
                          } else {
                            webService.getOtherCurrentStepInstances(
                                widget.requestInstance,
                                stepInstance.id,
                                widget.tabIndex,
                                false,
                                    (data) => _hidePr(2, data, stepInstance));
                          }
                        }
                      }
                    } else {
                      _hideByError();
                    }
                  });
                  break;
              }
            }
          } else {
            if (stepInstanceList.length == 1) {
              if (widget.tabIndex == widget.numOfSteps) {
                webService.patchRequestInstanceFinished(
                    stepInstance.requestInstanceID,
                        () => _hidePr(1, false, stepInstance));
              } else {
                webService.patchRequestInstanceStepIndex(
                    widget.requestInstance,
                        (data) => _hidePr(2, data, stepInstance));
              }
            } else if (stepInstanceList.length > 1) {
              if (widget.tabIndex == widget.numOfSteps) {
                webService.getOtherCurrentStepInstances(
                    widget.requestInstance,
                    stepInstance.id,
                    widget.tabIndex,
                    true,
                        (data) => _hidePr(2, data, stepInstance));
              } else {
                webService.getOtherCurrentStepInstances(
                    widget.requestInstance,
                    stepInstance.id,
                    widget.tabIndex,
                    false,
                        (data) => _hidePr(2, data, stepInstance));
              }
            }
          }
        }
      } else {
        throw Exception('Failed to update');
      }
    }
  }

  void _hideByError() async {
    await pr.hide();
    Flushbar(
      icon: Image.asset('images/ic-failed.png', width: 24, height: 24),
      message: 'Thất bại!',
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(8),
      borderRadius: 8,
    )..show(context);
  }

  void _hidePr(int index, var isUpdatedStep, StepInstance stepInstance) async {
    await pr.hide();
    if (index == 0) {
      // Update request instance status failed
      widget.requestInstance.status = 'failed';
    } else if (index == 1) {
      // Update request instance status done
      widget.requestInstance.status = 'done';
    }
    if (isUpdatedStep.runtimeType == bool) {
      if (isUpdatedStep) {
        if (index == 2) {
          // Update request instance step index
          widget.requestInstance.currentStepIndex++;
        }
      }
    }
    if (isUpdatedStep.runtimeType == int) {
      if (isUpdatedStep == 200) {
        webService.patchRequestInstanceFinished(stepInstance.requestInstanceID,
            () => _hidePr(1, false, stepInstance));
      }
    }

    setState(() {
      widget.update(widget.requestInstance);
    });
  }
}
