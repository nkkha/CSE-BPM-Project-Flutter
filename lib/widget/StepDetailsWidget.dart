import 'package:cse_bpm_project/model/StepInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

class StepDetailsWidget extends StatefulWidget {
  final int currentStepIndex;
  final int tabIndex;

  const StepDetailsWidget({Key key, this.currentStepIndex, this.tabIndex})
      : super(key: key);

  @override
  _StepDetailsWidgetState createState() => _StepDetailsWidgetState();
}

class _StepDetailsWidgetState extends State<StepDetailsWidget> {
  Widget build(BuildContext context) {
    List<StepInstance> stepInstanceList = new List();
    stepInstanceList.add(new StepInstance(
        id: 2,
        requestInstanceID: 1,
        approverID: null,
        defaultContent: null,
        status: "active",
        stepIndex: 2,
        description: "Ban chu nhiem kiem tra"));
    stepInstanceList.add(new StepInstance(
        id: 3,
        requestInstanceID: 1,
        approverID: null,
        defaultContent: null,
        status: "active",
        stepIndex: 2,
        description: "Phong dao tao kiem tra"));
    stepInstanceList.add(new StepInstance(
        id: 4,
        requestInstanceID: 1,
        approverID: null,
        defaultContent: null,
        status: "active",
        stepIndex: 2,
        description: "Phong tai chinh kiem tra"));

    return widget.tabIndex > widget.currentStepIndex - 1
        ? Center(child: Text('Bước ${widget.currentStepIndex} chưa hoàn thành'))
        : _buildStepDetails(stepInstanceList);
  }

  Widget _buildStepDetails(List<StepInstance> stepInstanceList) {
    String stepStatusInfo = "Tất cả các bước bên trên đã hoàn thành!";
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
        stepStatusInfo = "Yêu cầu của bạn đã thất bại!";
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
            return _buildStepRow(stepInstanceList[index]);
          },
        ),
        Center(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    stepStatusInfo,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MyColors.darkGray),
                  ),
                  SizedBox(height: 20),
                  Image.asset(imgUrl, width: 48, height: 48),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildStepRow(StepInstance stepInstance) {
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

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: InkWell(
          onTap: () {},
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Text(
                    stepInstance.description,
                    style: TextStyle(fontSize: 16, color: MyColors.darkGray),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
      ),
    );
  }
}
