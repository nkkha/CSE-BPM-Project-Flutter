import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/model/InputFieldInstance.dart';
import 'package:cse_bpm_project/source/SharedPreferencesHelper.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flushbar/flushbar.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class StepInfoWidget extends StatefulWidget {
  RequestInstance requestInstance;
  final int numOfSteps;
  final bool isStudent;
  Function update;

  StepInfoWidget(
      {Key key,
      this.requestInstance,
      this.isStudent,
      this.numOfSteps,
      this.update})
      : super(key: key);

  @override
  _StepInfoWidgetState createState() => _StepInfoWidgetState(requestInstance);
}

class _StepInfoWidgetState extends State<StepInfoWidget> {
  final RequestInstance _requestInstance;

  _StepInfoWidgetState(this._requestInstance);

  var webService = WebService();
  final DateFormat formatterDateTime = DateFormat('yyyy-MM-ddThh:mm:ss+07:00');

  Future<List<InputFieldInstance>> futureListIFI;
  List<InputFieldInstance> listInputFieldInstance = new List();
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
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
                    child: Text(
                      "Nội dung: ${_requestInstance.defaultContent}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  listInputFieldInstance.length > 0
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            children: List<Widget>.generate(
                                listInputFieldInstance.length,
                                (index) =>
                                    _buildInputFieldInstanceField(index)),
                          ))
                      : Container(),
                  Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Text(
                            status,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Image.asset(imgUrl, width: 48, height: 48)),
                      ],
                    ),
                  ),
                  _requestInstance.status.contains("new") && !widget.isStudent
                      ? _buildCheckBox()
                      : SizedBox(),
                  _requestInstance.responseMessage != null
                      ? Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
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
                                    text: "${_requestInstance.responseMessage}"),
                              ],
                            ),
                          ),
                      )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: SizedBox(),
                        ),
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
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      '${index + 1}. ${listInputFieldInstance[index].title}',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      listInputFieldInstance[index].textAnswer != null
                          ? listInputFieldInstance[index].textAnswer
                          : "null",
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
        return Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '${index + 1}. ${listInputFieldInstance[index].title}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: listInputFieldInstance[index].fileUrl != null
                  ? Image.network(
                      listInputFieldInstance[index].fileUrl,
                      fit: BoxFit.scaleDown,
                    )
                  : Text(
                      "null",
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
        if (listInputFieldInstance[index].fileUrl != null) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        '${index + 1}. ${listInputFieldInstance[index].title}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RaisedButton(
                        color: MyColors.lightBrand,
                        child: Text(
                          "Mở file",
                          style: TextStyle(fontSize: 16, color: MyColors.white),
                        ),
                        onPressed: () =>
                            _launchURL(listInputFieldInstance[index].fileUrl),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      '${index + 1}. ${listInputFieldInstance[index].title}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      "null",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
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

  _buildCheckBox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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

    final userID = await SharedPreferencesHelper.getUserId();

    if (userID != null) {
      var resBody = {};
      // indexType = 1: Reject, indexType = 2: Approve
      resBody["Status"] = indexType == 1 ? "failed" : "active";
      resBody["CurrentStepIndex"] = indexType == 1 ? 0 : 1;
      if (message != null) {
        resBody["ResponseMessage"] = message;
        _requestInstance.responseMessage = message;
      }
      if (indexType == 1) {
        resBody["FinishedDate"] = formatterDateTime.format(DateTime.now());
      }
      resBody["ApproverID"] = userID;
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
          _requestInstance.currentStepIndex = 1;
        }
        if (widget.numOfSteps == 1) {
          webService.patchRequestInstanceFinished(
              _requestInstance.id, () => _hidePr(false));
        } else {
          webService.getNextStep(_requestInstance, 1, (data) => _hidePr(data));
        }
      } else {
        _hidePr(false);
      }
    }
  }

  void _hidePr(boolData) async {
    await pr.hide();
    if (boolData) {
      setState(() {
        widget.update(widget.requestInstance);
      });
    } else {
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
