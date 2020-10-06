import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/StepInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/source/SharedPreferencesHelper.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

// ignore: must_be_immutable
class StepInstanceDetailsScreen extends StatefulWidget {
  Function(StepInstance) passData;
  final int roleId;
  final StepInstance stepInstance;

  StepInstanceDetailsScreen({Key key, this.roleId, this.stepInstance, this.passData})
      : super(key: key);

  @override
  _StepInstanceDetailsScreenState createState() =>
      _StepInstanceDetailsScreenState(stepInstance);
}

class _StepInstanceDetailsScreenState extends State<StepInstanceDetailsScreen> {
  StepInstance _stepInstance;

  _StepInstanceDetailsScreenState(this._stepInstance);

  ProgressDialog pr;
  var webService = WebService();

  TextEditingController _messageController = new TextEditingController();
  FocusNode _myFocusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    _myFocusNode = new FocusNode();
    _myFocusNode.addListener(_onOnFocusNodeEvent);
  }

  @override
  void dispose() {
    super.dispose();
    _myFocusNode.dispose();
    _messageController.dispose();
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chi tiết bước'),
          titleSpacing: 0,
          bottomOpacity: 1,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(
                      "Thông tin chi tiết",
                      style: TextStyle(
                          fontSize: 20,
                          color: MyColors.darkGray,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Text(
                    "Nội dung: ${_stepInstance.description}",
                    style: TextStyle(fontSize: 16, color: MyColors.darkGray),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Text(
                    "Nơi xử lý: ...",
                    style: TextStyle(fontSize: 16, color: MyColors.darkGray),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Trạng thái: ${_stepInstance.status}",
                        style:
                        TextStyle(fontSize: 16, color: MyColors.darkGray),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: StreamBuilder(
                    // stream: authBloc.passStream,
                    builder: (context, snapshot) => TextField(
                      focusNode: _myFocusNode,
                      controller: _messageController,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                        errorText: snapshot.hasError ? snapshot.error : null,
                        labelText: 'Ghi chú',
                        labelStyle: TextStyle(
                            color: _myFocusNode.hasFocus
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
                _stepInstance.status.contains('active')
                    && widget.roleId != 2
                    && widget.roleId == _stepInstance.approverRoleID
                    ? _buildCheckBox(_stepInstance)
                    : SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildCheckBox(StepInstance stepInstance) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly  ,
        children: [
          Container(
            width: 155,
            child: RaisedButton(
              onPressed: () =>  _showAlertDialog(context, 1, stepInstance),
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
              onPressed: () => _showAlertDialog(context, 2, stepInstance),
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

  _showAlertDialog(BuildContext context, index, StepInstance stepInstance) {
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
            onPressed: () =>
                _didTapButton(index, messageController.text, stepInstance),
            child: Text(
              "Đồng ý",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  Future<void> _didTapButton(
      int indexType, String message, StepInstance stepInstance) async {
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
      String str = json.encode(resBody);

      final http.Response response = await http.patch(
        'http://nkkha.somee.com/odata/tbStepInstance(${stepInstance.id})',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: str,
      );

      if (response.statusCode == 200) {
        if (indexType == 1) {
          stepInstance.status = 'failed';
          webService.patchRequestInstanceFailed(
              stepInstance.requestInstanceID, () => _hidePr(0, false));
        } else {
//          stepInstance.status = 'done';
//          if (stepInstanceList.length == 1) {
//            if (widget.tabIndex + 1 == widget.numOfSteps) {
//              webService.patchRequestInstanceFinished(
//                  stepInstance.requestInstanceID, () => _hidePr(1, false));
//            } else {
//              widget.requestInstance.currentStepIndex++;
//              webService.patchRequestInstanceStepIndex(
//                  widget.requestInstance, (data) => _hidePr(2, data));
//            }
//          } else if (stepInstanceList.length > 1) {
//            webService.getOtherCurrentStepInstances(
//                widget.requestInstance,
//                stepInstance.id,
//                widget.tabIndex + 1,
//                    (data) => _hidePr(2, data));
//          }
        }
      } else {
        throw Exception('Failed to update');
      }
    }
  }

  void _hidePr(int index, bool isUpdatedStep) async {
    await pr.hide();
//    if (index == 0) {
//      // Update request instance status failed
//      widget.requestInstance.status = 'failed';
//    } else if (index == 1) {
//      // Update request instance status done
//      widget.requestInstance.status = 'done';
//    }
//    if (isUpdatedStep) {
//      if (index == 2) {
//        // Update request instance step index
//        widget.requestInstance.currentStepIndex++;
//      }
//    }
//    setState(() {
//      // Re-render
//    });
  }

}
