import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cse_bpm_project/model/CountRIToday.dart';
import 'package:cse_bpm_project/model/ListItem.dart';
import 'package:cse_bpm_project/model/NumOfRequestInstance.dart';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/secretary/SecretaryRequestScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'DashboardRequestInstanceScreen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var webService = new WebService();
  String query = "\$filter=CreatedDate eq $formatted";
  List<RequestInstance> listAll = new List();
  List<RequestInstance> listNew = new List();
  List<RequestInstance> listInProgress = new List();
  List<RequestInstance> listDone = new List();
  List<RequestInstance> listFailed = new List();

  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd');
  static final String formatted = formatter.format(now);

  List<ListItem> _dropdownItems = [
    ListItem(1, "Tất cả", ""),
    ListItem(2, "Hôm nay", "\$filter=CreatedDate eq $formatted"),
    ListItem(3, "Tháng này", "\$filter=month(CreatedDate) eq ${now.month}"),
  ];

  List<DropdownMenuItem<ListItem>> _dropdownMenuItems;
  ListItem _selectedItem;

  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[1].value;
  }

  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = List();
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Trang chủ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: FutureBuilder<List<RequestInstance>>(
        future: webService.getListRequestInstance(query),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            clearCache();
            listAll = snapshot.data;
            for (RequestInstance requestInstance in snapshot.data) {
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
            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Yêu cầu ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: MyColors.darkGray,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: MyColors.lightGray,
                                border: Border.all()),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                  value: _selectedItem,
                                  items: _dropdownMenuItems,
                                  onChanged: (value) {
                                    if (_selectedItem != value) {
                                      setState(() {
                                        _selectedItem = value;
                                        query = _selectedItem.query;
                                      });
                                    }
                                  }),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 230,
                      padding: const EdgeInsets.only(top: 30, bottom: 40),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          countCard(1, MyColors.mediumGray, 'Tất cả', listAll),
                          countCard(2, MyColors.amber, 'Mới', listNew),
                          countCard(3,
                              MyColors.blue, 'Đang thực hiện', listInProgress),
                          countCard(4, MyColors.green, 'Hoàn thành', listDone),
                          countCard(5, MyColors.red, ' Thất bại', listFailed),
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
                              // _buildDetails(snapshot.data),
                              Container(
                                height: 300,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: new charts.BarChart(
                                  _getListNumOfRequestInstance(snapshot.data),
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Biểu đồ thống kê số lượng theo từng loại yêu cầu',
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

  Widget countCard(int index, Color color, String title, List<RequestInstance> listRI) {
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
                top: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          listRI.length.toString(),
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: MyColors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(icon, size: 42, color: MyColors.white,),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
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
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: MyColors.darkGray,
      ),
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

  void clearCache() {
    listAll.clear();
    listNew.clear();
    listInProgress.clear();
    listDone.clear();
    listFailed.clear();
  }
}
