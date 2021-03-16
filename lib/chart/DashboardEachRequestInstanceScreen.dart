import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cse_bpm_project/model/NumOfDayHandleStep.dart';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/model/StepInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/model/Step.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/material.dart';
import 'DashboardRequestInstanceScreen.dart';

class DashboardEachRequestInstanceScreen extends StatefulWidget {
  final List<RequestInstance> requestInstanceList;
  final int requestID;

  const DashboardEachRequestInstanceScreen(
      {Key key, this.requestInstanceList, this.requestID})
      : super(key: key);

  @override
  _DashboardEachRequestInstanceScreenState createState() =>
      _DashboardEachRequestInstanceScreenState();
}

class _DashboardEachRequestInstanceScreenState
    extends State<DashboardEachRequestInstanceScreen> {
  var webService = new WebService();
  List<RequestInstance> listAll = [];
  List<RequestInstance> listNew = [];
  List<RequestInstance> listInProgress = [];
  List<RequestInstance> listDone = [];
  List<RequestInstance> listFailed = [];
  List<List<RequestInstance>> listRequestInstances = [];
  List<MyStep> listStep = [];
  List<NumOfDayHandleStep> listNumOfDayHandleStep = [];
  Future<List<StepInstance>> futureListStepInstance;
  Future<List<MyStep>> futureListStep;

  void initState() {
    super.initState();

    String query = "\$filter=";
    bool isFirst = true;
    for (RequestInstance requestInstance in widget.requestInstanceList) {
      if (isFirst) {
        query += "(RequestInstanceID eq ${requestInstance.id}";
        isFirst = false;
      } else {
        query += " or RequestInstanceID eq ${requestInstance.id}";
      }
      if (requestInstance.status.contains('new')) {
        listNew.add(requestInstance);
      } else if (requestInstance.status.contains('active')) {
        listInProgress.add(requestInstance);
      } else if (requestInstance.status.contains('done')) {
        listDone.add(requestInstance);
      } else if (requestInstance.status.contains('failed')) {
        listFailed.add(requestInstance);
      }
    }

    query += ")";

    listAll = widget.requestInstanceList;
    futureListStepInstance = webService.getStepInstancesByQuery(query);
    futureListStep = webService.getStepByID(widget.requestID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: Text(
          'Thống kê',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: FutureBuilder<List<MyStep>>(
        future: futureListStep,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            clearCache();
            listStep = snapshot.data;
            return FutureBuilder(
                future: futureListStepInstance,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    int index = 0;
                    int parallelIndex = 2;
                    for (MyStep step in listStep) {
                      int dateRange = 0;
                      int count = 0;
                      int totalDayRange = 0;
                      for (StepInstance stepInstance in snapshot.data) {
                        if (stepInstance.stepID == step.id) {
                          if (stepInstance.finishedDate != null) {
                            count++;
                            DateTime created = DateTime.parse(stepInstance.createdDate);
                            DateTime finished = DateTime.parse(stepInstance.finishedDate);
                            totalDayRange += finished.difference(created).inDays + 1;
                          }
                        }
                      }
                      if (totalDayRange != 0 && count != 0) {
                        dateRange = totalDayRange ~/ count;
                      }

                      String stepIndex = "";
                      if (step.stepIndex == index) {
                        if (listNumOfDayHandleStep.last.stepIndex == index.toString()) {
                          listNumOfDayHandleStep.last.stepIndex = "$index.1";
                        }
                        stepIndex = "$index.$parallelIndex";
                        parallelIndex++;
                      } else {
                        index++;
                        stepIndex = index.toString();
                        parallelIndex = 2;
                      }

                      listNumOfDayHandleStep.add(new NumOfDayHandleStep(
                          stepIndex: stepIndex,
                          dayElapsed: dateRange));
                    }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Yêu cầu: ${widget.requestInstanceList[0].requestName}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: MyColors.darkGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 190,
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 20),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  countCard(1, MyColors.mediumGray, 'Tất cả',
                                      listAll),
                                  countCard(2, MyColors.amber, 'Mới', listNew),
                                  countCard(3, MyColors.blue, 'Đang thực hiện',
                                      listInProgress),
                                  countCard(4, MyColors.green, 'Hoàn thành',
                                      listDone),
                                  countCard(
                                      5, MyColors.red, ' Thất bại', listFailed),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 250,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: new charts.BarChart(
                                    _getListNumOfStep(listNumOfDayHandleStep),
                                  ),
                                ),
                                Text(
                                  'Biểu đồ thống kê số ngày hoàn thành trung bình của từng bước.',
                                  style: TextStyle(
                                      fontSize: 14, fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            // listRequestInstances.length != 0
                            //     ? _buildTableDetails()
                            //     : Container(),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("${snapshot.error}"));
                  }
                  return Center(child: CircularProgressIndicator());
                });
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget countCard(
      int index, Color color, String title, List<RequestInstance> listRI) {
    IconData icon;
    switch (index) {
      case 1:
        icon = Icons.list_alt;
        break;
      case 2:
        icon = Icons.fiber_new;
        break;
      case 3:
        icon = Icons.access_time;
        break;
      case 4:
        icon = Icons.check_circle_outline;
        break;
      case 5:
        icon = Icons.highlight_off;
        break;
    }

    return AspectRatio(
      aspectRatio: 2.7 / 3,
      child: Container(
        margin: EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color,
        ),
        child: InkWell(
          onTap: listRI.length == 0
              ? () {}
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DashboardRequestInstanceScreen(
                            listRequestInstance: listRI)),
                  );
                },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        stops: [
                          0.1,
                          0.9
                        ],
                        colors: [
                          Colors.black.withOpacity(.4),
                          Colors.black.withOpacity(.1)
                        ])),
              ),
              Positioned(
                left: 10,
                top: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          listRI.length.toString(),
                          style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: MyColors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(
                            icon,
                            size: 42,
                            color: MyColors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: MyColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<charts.Series<NumOfDayHandleStep, String>> _getListNumOfStep(
      List<NumOfDayHandleStep> data) {
    return [
      new charts.Series<NumOfDayHandleStep, String>(
        id: 'Requests',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (NumOfDayHandleStep instance, _) =>
            "B${instance.stepIndex}",
        measureFn: (NumOfDayHandleStep instance, _) => instance.dayElapsed,
        data: data,
      )
    ];
  }

  void clearCache() {
    listRequestInstances.clear();
    listStep.clear();
  }

  String formatTime(int num) {
    return num < 10 ? '0$num' : num.toString();
  }
}
