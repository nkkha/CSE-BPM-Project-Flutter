import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cse_bpm_project/model/InputFieldInstance.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class StepInfoWidget extends StatefulWidget {
  RequestInstance requestInstance;
  final int numOfSteps;
  final bool isStudent;
  Function update;

  StepInfoWidget(
      {Key key, this.requestInstance, this.isStudent, this.numOfSteps, this.update})
      : super(key: key);

  @override
  _StepInfoWidgetState createState() => _StepInfoWidgetState(requestInstance);
}

class _StepInfoWidgetState extends State<StepInfoWidget> {
  final RequestInstance _requestInstance;

  _StepInfoWidgetState(this._requestInstance);

  var webService = WebService();

  List<InputFieldInstance> listInputFieldInstance = new List();
  Future<List<InputFieldInstance>> futureListIFI;
  int count = 0;
  int nextStepSize = 0;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();

    futureListIFI =
        webService.getListInputFieldInstance(_requestInstance.id, null);
  }

  @override
  Widget build(BuildContext context) {
    String status = "Yêu cầu không được phê duyệt";
    String imgUrl = "images/ic-failed.png";
    if (_requestInstance.status.contains('new')) {
      status = 'Đang chờ phê duyệt';
      imgUrl = 'images/timer.png';
    } else if (_requestInstance.status.contains('active') ||
        _requestInstance.status.contains('done')) {
      status = 'Đã được phê duyệt';
      imgUrl = 'images/ok.png';
    }

    return FutureBuilder(
      future: futureListIFI,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (listInputFieldInstance.length == 0) {
            listInputFieldInstance = snapshot.data;
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: Text(
                        "Phê duyệt yêu cầu",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Họ và tên: ${_requestInstance.fullName}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Email: ${_requestInstance.email}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Phone: ${_requestInstance.phone}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Nội dung yêu cầu: ${_requestInstance.defaultContent}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
                    child: Text(
                      "Trạng thái yêu cầu: $status",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  listInputFieldInstance.length > 0
                      ? Column(
                          children: List<Widget>.generate(
                              listInputFieldInstance.length,
                              (index) => _buildInputFieldInstanceField(index)),
                        )
                      : Container(),
                  Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Image.asset(imgUrl, width: 48, height: 48)),
                  ),
                  _requestInstance.status.contains("new") && !widget.isStudent
                      ? _buildCheckBox()
                      : SizedBox()
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  _buildInputFieldInstanceField(int index) {
    switch (listInputFieldInstance[index].inputFieldTypeID) {
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    '${listInputFieldInstance[index].title}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    '${listInputFieldInstance[index].textAnswer}',
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
        if (listInputFieldInstance[index].fileContent != null) {
          decodedBytes =
              base64Decode(listInputFieldInstance[index].fileContent);
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                '${listInputFieldInstance[index].title}',
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
        if (listInputFieldInstance[index].fileContent != null) {
          Uint8List decodedBytes =
              base64Decode(listInputFieldInstance[index].fileContent);
          return FutureBuilder(
            future: getApplicationDocumentsDirectory(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                File file = new File(
                    '${snapshot.data.path}/${listInputFieldInstance[index].fileName}');
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
                              '${listInputFieldInstance[index].title}',
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
                    return CircularProgressIndicator();
                  },
                );
              }
              return CircularProgressIndicator();
            },
          );
        } else {
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '${listInputFieldInstance[index].title}',
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

  _buildCheckBox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 155,
            child: RaisedButton(
              onPressed: () => _showAlertDialog(context, 1),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.red)),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/icons8-cross-mark-48.png',
                    width: 36,
                    height: 36,
                  ),
                  Text(' Từ chối',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MyColors.red))
                ],
              ),
            ),
          ),
          Container(
            width: 155,
            child: RaisedButton(
              onPressed: () => _showAlertDialog(context, 2),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.green)),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/icons8-check-mark-48.png',
                    width: 36,
                    height: 36,
                  ),
                  Text(' Phê duyệt',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MyColors.green))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showAlertDialog(BuildContext context, index) {
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
            onPressed: () => _didTapButton(index, messageController.text),
            child: Text(
              "Đồng ý",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  Future<void> _didTapButton(int indexType, String message) async {
    Navigator.pop(context);

    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.update(message: "Đang xử lý...");
    await pr.show();

    var resBody = {};
    // indexType = 1: Reject, indexType = 2: Approve
    resBody["Status"] = indexType == 1 ? "failed" : "active";
    resBody["CurrentStepIndex"] = indexType == 1 ? 1 : 2;
    String str = json.encode(resBody);

    final http.Response response = await http.patch(
      'http://nkkha.somee.com/odata/tbRequestInstance(${_requestInstance.id})',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: str,
    );

    if (response.statusCode == 200) {
      if (indexType == 1) {
        _requestInstance.status = 'failed';
      } else {
        _requestInstance.status = 'active';
        _requestInstance.currentStepIndex = 2;
      }
      if (widget.numOfSteps == 1) {
        webService.patchRequestInstanceFinished(
            _requestInstance.id, () => _hidePr(false));
      } else {
        webService.getNextStep(_requestInstance, 1, (data) => _hidePr(data));
      }
    } else {
      throw Exception('Failed to update');
    }
  }

  void _hidePr(boolData) async {
    await pr.hide();
    setState(() {
      widget.update(widget.requestInstance);
    });
  }
}
