import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:cse_bpm_project/model/InputField.dart';
import 'package:cse_bpm_project/model/InputFieldInstance.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

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
  HashMap listImageFilePath = new HashMap<int, String>();
  HashMap listFilePath = new HashMap<int, String>();
  int count;

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
    updateImage(image.path);
  }

  void _imgFromGallery(Function updateImage) async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    updateImage(image.path);
  }

  void _showFilePicker(Function updateFile) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      PlatformFile platformFile = result.files.first;
      File file = File('${platformFile.path}');
      updateFile(file.path, platformFile.name);
    }
  }

  Widget build(BuildContext context) {
    int currentStepIndex = widget.requestInstance.currentStepIndex;
    String txt = "Bước $currentStepIndex chưa hoàn thành!";
    if (currentStepIndex == 0) {
      txt = "Yêu cầu chưa được phê duyệt!";
    }
    return widget.tabIndex > currentStepIndex
        ? Center(
            child: Text(txt,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic)))
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
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      side: stepInstance.approverRoleID == roleID
                          ? BorderSide(width: 2, color: MyColors.green)
                          : BorderSide(width: 0, color: Colors.white),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8, bottom: 8),
                                      child: Text(
                                        stepInstance.stepName,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        stepInstance.description,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
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
                            : _buildInputFieldInstanceColumn(
                                stepInstance.id, stepIndex, roleID),
                        stepInstance.responseMessage != null &&
                                stepInstance.responseMessage != ''
                            ? Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 0, 24, 8),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: "Ghi chú: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic),
                                        ),
                                        TextSpan(
                                            text:
                                                "${stepInstance.responseMessage}"),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
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
                  hashMapInputFieldInstances.putIfAbsent(
                      stepIndex, () => listIFI);
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CircularProgressIndicator(),
            ),
          );
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
    _textController.text =
        hashMapInputFieldInstances[stepIndex][index].textAnswer;
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
              '${index + 1}. ${hashMapInputFieldInstances[stepIndex][index].title}',
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
            '${index + 1}. ${hashMapInputFieldInstances[stepIndex][index].title}',
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
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = filePath;
                        } else {
                          listImageFilePath.putIfAbsent(key, () => filePath);
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = filePath;
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
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = filePath;
                        } else {
                          listImageFilePath.putIfAbsent(key, () => filePath);
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = filePath;
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

  Widget createUploadFileFieldWidget(int stepIndex, int index) {
    final int key = hashMapInputFieldInstances[stepIndex][index].inputFieldID;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Text(
            '${index + 1}. ${hashMapInputFieldInstances[stepIndex][index].title}',
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
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = filePath;
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileName = fileName;
                        } else {
                          listFilePath.putIfAbsent(key, () => filePath);
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = filePath;
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileName = fileName;
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
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = filePath;
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileName = fileName;
                        } else {
                          listFilePath.putIfAbsent(key, () => filePath);
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileContent = filePath;
                          hashMapInputFieldInstances[stepIndex][index]
                              .fileName = fileName;
                        }
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '${hashMapInputFieldInstances[stepIndex][index].fileName}',
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

  _buildInputFieldInstanceColumn(
      int stepInstanceID, int stepIndex, int roleID) {
    return FutureBuilder(
      future: webService.getListInputFieldInstance(null, stepInstanceID),
      builder: (context, snapshot) {
        if (hashMapInputFieldInstances.containsKey(stepIndex)) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: List<Widget>.generate(
                  hashMapInputFieldInstances[stepIndex].length,
                  (index) => _buildInputFieldInstanceField(stepIndex, index)),
            ),
          );
        } else if (snapshot.hasData) {
          if (!hashMapInputFieldInstances.containsKey(stepIndex)) {
            if (snapshot.data.length > 0) {
              List<InputFieldInstance> listIFI = new List();
              listIFI = snapshot.data;
              hashMapInputFieldInstances.putIfAbsent(stepIndex, () => listIFI);
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
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  _buildInputFieldInstanceField(int stepIndex, int index) {
    switch (hashMapInputFieldInstances[stepIndex][index].inputFieldTypeID) {
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      '${index + 1}. ${hashMapInputFieldInstances[stepIndex][index].title}',
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
            ),
          ],
        );
        break;
      case 2:
        // Uint8List decodedBytes;
        // if (hashMapInputFieldInstances[stepIndex][index].fileContent != null) {
        //   decodedBytes = base64Decode(
        //       hashMapInputFieldInstances[stepIndex][index].fileContent);
        // }
        String url;
        if (hashMapInputFieldInstances[stepIndex][index].fileUrl != null) {
          url = hashMapInputFieldInstances[stepIndex][index].fileUrl;
        }
        return Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '${index + 1}. ${hashMapInputFieldInstances[stepIndex][index].title}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: url != null
                  ? Image.network(
                      url,
                      fit: BoxFit.scaleDown,
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
        if (hashMapInputFieldInstances[stepIndex][index].fileUrl != null) {
          String url = hashMapInputFieldInstances[stepIndex][index].fileUrl;
          if (url != null) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          '${index + 1}. ${hashMapInputFieldInstances[stepIndex][index].title}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: RaisedButton(
                          color: MyColors.lightBrand,
                          child: Text(
                            "Mở file",
                            style:
                                TextStyle(fontSize: 16, color: MyColors.white),
                          ),
                          onPressed: () => _launchURL(url),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        '${index + 1}. ${hashMapInputFieldInstances[stepIndex][index].title}',
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
                ),
              ),
            ],
          );
        }
        break;
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
      return SizedBox(height: 16);
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
      if (message != null) {
        resBody["ResponseMessage"] = message;
        stepInstanceList[stepIndex - 1].responseMessage = message;
      }
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
        count = 0;
        if (indexType == 1) {
          stepInstance.status = 'failed';
          webService.patchRequestInstanceFailed(stepInstance.requestInstanceID,
              () => _hidePr(0, false, stepInstance));
        } else {
          stepInstance.status = 'done';
          if (roleID == stepInstance.approverRoleID &&
              hashMapInputFieldInstances.containsKey(stepIndex)) {
            for (int i = 0;
                i < hashMapInputFieldInstances[stepIndex].length;
                i++) {
              InputFieldInstance inputFieldInstance =
                  hashMapInputFieldInstances[stepIndex][i];
              switch (inputFieldInstance.inputFieldTypeID) {
                case 1:
                  webService.postCreateInputTextFieldInstance(
                      inputFieldInstance.stepInstanceID,
                      null,
                      inputFieldInstance.inputFieldID,
                      inputFieldInstance.textAnswer, (isSuccessful) {
                    if (isSuccessful) {
                      count++;
                      if (count ==
                          hashMapInputFieldInstances[stepIndex].length) {
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
                  uploadFile(inputFieldInstance.fileContent, inputFieldInstance,
                      stepInstance, stepIndex, i);
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
                webService.patchRequestInstanceStepIndex(widget.requestInstance,
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

  Future<String> uploadFile(String path, InputFieldInstance inputFieldInstance,
      StepInstance stepInstance, int stepIndex, int index) async {
    String fileName = (path.split('/').last).split('.').first +
        DateFormat("yyyy_MM_dd_hh_mm_ss").format(DateTime.now()) +
        '.' +
        path.split('.').last;
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child(
            inputFieldInstance.inputFieldTypeID == 2 ? 'images' : 'documents')
        .child(fileName);
    UploadTask uploadTask = firebaseStorageRef.putFile(File(path));
    uploadTask.whenComplete(() {
      return firebaseStorageRef.getDownloadURL().then((value) {
        if (value != null) {
          String fileUrl = value.split('&').first;
          hashMapInputFieldInstances[stepIndex][index].fileUrl = fileUrl;
          webService.postCreateInputFileFieldInstance(
              inputFieldInstance.stepInstanceID,
              null,
              inputFieldInstance.inputFieldID,
              fileUrl,
              fileName, (isSuccessful) {
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
        }
      });
    }).catchError((onError) {
      print(onError);
    });
    return null;
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
