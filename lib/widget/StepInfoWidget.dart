import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/StepModel.dart';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

// ignore: must_be_immutable
class StepInfoWidget extends StatefulWidget {
  Function(RequestInstance) passData;
  final RequestInstance requestInstance;
  final bool isStudent;

  StepInfoWidget({Key key, this.requestInstance, this.isStudent, this.passData})
      : super(key: key);

  @override
  _StepInfoWidgetState createState() => _StepInfoWidgetState(requestInstance);
}

class _StepInfoWidgetState extends State<StepInfoWidget> {
  final RequestInstance _requestInstance;

  _StepInfoWidgetState(this._requestInstance);

  bool _isClicked = false;
  int count = 0;
  int nextStepSize = 0;
  ProgressDialog pr;

  @override
  Widget build(BuildContext context) {
    String status = "Yêu cầu không được phê duyệt";
    String imgUrl = "images/ic-failed.png";
    if (_requestInstance.status.contains('new')) {
      status = 'Đang chờ phê duyệt';
      imgUrl = 'images/timer.png';
    } else if (_requestInstance.status.contains('active') || _requestInstance.status.contains('done')){
      status = 'Đã được phê duyệt';
      imgUrl = 'images/ok.png';
    }

    return Padding(
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
                    fontSize: 20,
                    color: MyColors.darkGray,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Họ và tên: ${_requestInstance.fullName}",
              style: TextStyle(fontSize: 16, color: MyColors.darkGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Email: ${_requestInstance.email}",
              style: TextStyle(fontSize: 16, color: MyColors.darkGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Phone: ${_requestInstance.phone}",
              style: TextStyle(fontSize: 16, color: MyColors.darkGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Nội dung yêu cầu: ${_requestInstance.defaultContent}",
              style: TextStyle(fontSize: 16, color: MyColors.darkGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Trạng thái yêu cầu: $status",
              style: TextStyle(fontSize: 16, color: MyColors.darkGray),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Image.asset(imgUrl, width: 48, height: 48)
            ),
          ),
          _requestInstance.status.contains("new") && !widget.isStudent
              ? _buildCheckBox()
              : SizedBox()
        ],
      ),
    );
  }

  _buildCheckBox() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly  ,
        children: [
          Container(
            width: 155,
            child: RaisedButton(
              onPressed: () => _didTapButton(1),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.red)
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/icons8-cross-mark-48.png',
                    width: 36,
                    height: 36,
                  ),
                  Text(' Từ chối', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyColors.red))
                ],
              ),
            ),
          ),
          Container(
            width: 155,
            child: RaisedButton(
              onPressed: () => _didTapButton(2),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.green)
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/icons8-check-mark-48.png',
                    width: 36,
                    height: 36,
                  ),
                  Text(' Phê duyệt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyColors.green))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _didTapButton(int indexType) async {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    pr.update(message: "Đang xử lý...");
    await pr.show();

    _isClicked = true;

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
      widget.passData(_requestInstance);
      _getNextStep();
    } else {
      _isClicked = false;
    }
  }

  Future<void> _getNextStep() async {
    final response = await http.get('http://nkkha.somee.com/odata/tbStep?\$filter=RequestID eq ${_requestInstance.requestID} and StepIndex eq ${_requestInstance.currentStepIndex}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<StepModel> listStep = new List();
      for (Map i in data) {
        listStep.add(StepModel.fromJson(i));
      }
      nextStepSize = listStep.length;
      for (int i = 0; i <listStep.length ; i++) {
        _createNextStep(listStep[i].id);
      }
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<void> _createNextStep(int stepID) async {
    final http.Response response = await http.post(
      'http://nkkha.somee.com/odata/tbStepInstance',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "RequestInstanceID": "${_requestInstance.id}",
        "ApproverID": null,
        "DefaultContent": "",
        "Status": "active",
        "StepID": "$stepID",
        "ResponseMessage": ""
      }),
    );

    if (response.statusCode == 200) {
      count++;
      if (count == nextStepSize) {
        await pr.hide();
      }
    } else {
      throw Exception('Failed to create next step instances.');
    }
  }
}
