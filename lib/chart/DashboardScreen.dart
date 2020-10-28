import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cse_bpm_project/model/CountRIToday.dart';
import 'package:cse_bpm_project/model/NumOfRequestInstance.dart';
import 'package:cse_bpm_project/secretary/SecretaryRequestScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var webService = new WebService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<CountRIToday>>(
        future: webService.getListNumOfRequestInstanceToday(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int totalRI = 0;
            int newRI = 0;
            int inProgressRI = 0;
            int doneRI = 0;
            int failedRI = 0;
            for (CountRIToday countRI in snapshot.data) {
              totalRI += countRI.count;
              if (countRI.status.contains('new')) {
                newRI = countRI.count;
              } else if (countRI.status.contains('active')) {
                inProgressRI = countRI.count;
              } else if (countRI.status.contains('done')) {
                doneRI = countRI.count;
              } else if (countRI.status.contains('failed')) {
                failedRI = countRI.count;
              }
            }
            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Text(
                        'Yêu cầu hôm nay',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: MyColors.black),
                      ),
                    ),
                    Container(
                      height: 230,
                      padding: const EdgeInsets.only(top: 30, bottom: 40),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          countCard(MyColors.mediumGray, 'Tất cả', totalRI),
                          countCard(MyColors.blue, 'Mới', newRI),
                          countCard(
                              MyColors.amber, 'Đang thực hiện', inProgressRI),
                          countCard(MyColors.green, 'Hoàn thành', doneRI),
                          countCard(MyColors.red, ' Thất bại', failedRI),
                        ],
                      ),
                    ),
                    FutureBuilder<List<NumOfRequestInstance>>(
                      future: webService.getListNumOfRequestInstance(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetails(snapshot.data),
                              Container(
                                height: 250,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: new charts.BarChart(
                                  _getListNumOfRequestInstance(snapshot.data),
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Biểu đồ thống kê số lượng yêu cầu',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Center(child: Text("${snapshot.error}"));
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget countCard(Color color, String title, int count) {
    return AspectRatio(
      aspectRatio: 2.7 / 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SecretaryRequestScreen()),
          );
        },
        child: Container(
          margin: EdgeInsets.only(right: 15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color,
          ),
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
                top: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count.toString(),
                      style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: MyColors.white),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 17,
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

  Widget _buildDetails(List<NumOfRequestInstance> data) {
    int totalRequestInstance = 0;
    for (NumOfRequestInstance numOfRequestInstance in data) {
      totalRequestInstance += numOfRequestInstance.numOfRequestInstance;
    }
    return Text(
      'Tổng số yêu cầu: $totalRequestInstance',
      style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: MyColors.black),
    );
  }

  static List<charts.Series<NumOfRequestInstance, String>>
      _getListNumOfRequestInstance(List<NumOfRequestInstance> data) {
    return [
      new charts.Series<NumOfRequestInstance, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (NumOfRequestInstance num, _) => num.requestID.toString(),
        measureFn: (NumOfRequestInstance num, _) => num.numOfRequestInstance,
        data: data,
      )
    ];
  }
}
