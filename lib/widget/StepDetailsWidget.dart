import 'dart:async';
import 'dart:convert';
import 'package:cse_bpm_project/widget/StepInputFieldInstanceWidget.dart';
import 'package:http/http.dart' as http;

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/model/StepInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/source/SharedPreferencesHelper.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

// ignore: must_be_immutable
class StepDetailsWidget extends StatefulWidget {
  RequestInstance requestInstance;
  final int tabIndex;
  final int numOfSteps;

  StepDetailsWidget(
      {Key key, this.requestInstance, this.tabIndex, this.numOfSteps})
      : super(key: key);

  @override
  _StepDetailsWidgetState createState() => _StepDetailsWidgetState();
}

class _StepDetailsWidgetState extends State<StepDetailsWidget> {
  Future<List<StepInstance>> futureListStep;
  List<StepInstance> stepInstanceList = new List();
  ProgressDialog pr;
  var webService = WebService();

  @override
  void initState() {
    super.initState();
    futureListStep = webService.getStepInstances(
        widget.tabIndex + 1, widget.requestInstance.id);
  }

  Widget build(BuildContext context) {
    int currentStepIndex = widget.requestInstance.currentStepIndex;
    return widget.tabIndex > currentStepIndex - 1
        ? Center(child: Text('Bước $currentStepIndex chưa hoàn thành'))
        : FutureBuilder<List<StepInstance>>(
            future: futureListStep,
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
    String stepStatusInfo = widget.tabIndex + 1 == widget.numOfSteps
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
        ListView.builder(
          itemCount: stepInstanceList.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _buildStepRow(stepInstanceList[index], index);
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

  Widget _buildStepRow(StepInstance stepInstance, int index) {
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
          return snapshot.hasData
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      side: BorderSide(width: 2, color: Colors.green),
                    ),
                    child: InkWell(
                      onTap: () {
//                        Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                            builder: (context) => StepInstanceDetailsScreen(
//                              roleId: snapshot.data,
//                              stepInstance: stepInstance,
//                              passData: (data) {
//                                setState(() {
//                                  // Re-render
//                                  stepInstanceList[index] = data;
//                                });
//                              },
//                            ),
//                          ),
//                        );
                      },
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildCheckBox(
                                stepInstance,
                                snapshot.data,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox();
        });
  }

  _buildCheckBox(StepInstance stepInstance, int roleId) {
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
                onPressed: () => _showAlertDialog(context, 1, stepInstance),
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
                onPressed: () => _showAlertDialog(context, 2, stepInstance),
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
          stepInstance.status = 'done';
          if (stepInstanceList.length == 1) {
            if (widget.tabIndex + 1 == widget.numOfSteps) {
              webService.patchRequestInstanceFinished(
                  stepInstance.requestInstanceID, () => _hidePr(1, false));
            } else {
              widget.requestInstance.currentStepIndex++;
              webService.patchRequestInstanceStepIndex(
                  widget.requestInstance, (data) => _hidePr(2, data));
            }
          } else if (stepInstanceList.length > 1) {
            webService.getOtherCurrentStepInstances(
                widget.requestInstance,
                stepInstance.id,
                widget.tabIndex + 1,
                (data) => _hidePr(2, data));
          }
        }
      } else {
        throw Exception('Failed to update');
      }
    }
  }

  void _hidePr(int index, bool isUpdatedStep) async {
    await pr.hide();
    if (index == 0) {
      // Update request instance status failed
      widget.requestInstance.status = 'failed';
    } else if (index == 1) {
      // Update request instance status done
      widget.requestInstance.status = 'done';
    }
    if (isUpdatedStep) {
      if (index == 2) {
        // Update request instance step index
        widget.requestInstance.currentStepIndex++;
      }
    }
    setState(() {
      // Re-render
    });
  }
}
