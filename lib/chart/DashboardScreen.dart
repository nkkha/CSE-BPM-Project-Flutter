import 'dart:collection';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cse_bpm_project/chart/DashboardEachRequestInstanceScreen.dart';
import 'package:cse_bpm_project/model/ListItem.dart';
import 'package:cse_bpm_project/model/NumOfRequestInstance.dart';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  HashMap hashMapRequestInstances = new HashMap<int, List<RequestInstance>>();
  List<List<RequestInstance>> listRequestInstances = new List();
  List<NumOfRequestInstance> listNumOfRI = new List();

  DateTime startDate, dueDate;
  String startDateStr, dueDateStr;
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd');
  static final String formatted = formatter.format(now);

  List<ListItem> _dropdownItems = [
    ListItem(1, "Tất cả", ""),
    ListItem(2, "Hôm nay", "\$filter=CreatedDate eq $formatted"),
    ListItem(3, "Tháng này", "\$filter=month(CreatedDate) eq ${now.month}"),
    ListItem(4, "Chọn ngày", ""),
  ];
  List<DropdownMenuItem<ListItem>> _dropdownMenuItems;
  ListItem _selectedItem;

  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[1].value;

    startDate = DateTime.now();
    dueDate = startDate;
    startDateStr = "Từ";
    dueDateStr = "Đến";
  }

  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = List();
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Text(listItem.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14)),
            ),
          ),
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
        actions: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 10),
            padding: const EdgeInsets.only(left: 8, right: 8),
            decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(10.0),
                // border: Border.all()
                ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                  value: _selectedItem,
                  items: _dropdownMenuItems,
                  icon: Image.asset('images/ic_filter.png',
                      width: 24, height: 24),
                  onChanged: (value) {
                    if (_selectedItem != value) {
                      setState(() {
                        _selectedItem = value;
                        if (_selectedItem.value != 4) {
                          query = _selectedItem.query;
                        }
                      });
                    }
                  }),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<RequestInstance>>(
        future: webService.getListRequestInstance(query),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            clearCache();
            listAll = snapshot.data;
            for (RequestInstance requestInstance in snapshot.data) {
              int id = requestInstance.requestID;
              if (requestInstance.status.contains('new')) {
                listNew.add(requestInstance);
              } else if (requestInstance.status.contains('active')) {
                listInProgress.add(requestInstance);
              } else if (requestInstance.status.contains('done')) {
                listDone.add(requestInstance);
              } else if (requestInstance.status.contains('failed')) {
                listFailed.add(requestInstance);
              }
              if (!hashMapRequestInstances.containsKey(id)) {
                List<RequestInstance> listRI = new List();
                listRI.add(requestInstance);
                hashMapRequestInstances.putIfAbsent(id, () => listRI);
              } else {
                List<RequestInstance> listRI = hashMapRequestInstances[id];
                listRI.add(requestInstance);
                hashMapRequestInstances.update(id, (v) => listRI);
              }
            }
            hashMapRequestInstances.forEach((k, v) {
              listRequestInstances.add(v);
              listNumOfRI.add(new NumOfRequestInstance(
                  keyword: v[0].requestKeyword.trim(),
                  numOfRequestInstance: v.length));
            });

            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: Row(
                        children: [
                          Text(
                            'Yêu cầu ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: MyColors.darkGray,
                            ),
                          ),
                          _selectedItem.value == 4
                              ? Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () => _pickDate(true),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom:
                                                      BorderSide(width: 1.0),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8.0),
                                                    child: Text(startDateStr),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 4.0),
                                                    child:
                                                        Icon(Icons.date_range),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () => _pickDate(false),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom:
                                                      BorderSide(width: 1.0),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8.0),
                                                    child: Text(dueDateStr),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 4.0),
                                                    child: InkWell(
                                                        child: Icon(
                                                            Icons.date_range)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Container(
                      height: 190,
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          countCard(1, MyColors.mediumGray, 'Tất cả', listAll),
                          countCard(2, MyColors.amber, 'Mới', listNew),
                          countCard(3, MyColors.blue, 'Đang thực hiện',
                              listInProgress),
                          countCard(4, MyColors.green, 'Hoàn thành', listDone),
                          countCard(5, MyColors.red, ' Thất bại', listFailed),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildDetails(snapshot.data),
                        Container(
                          height: 250,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: new charts.BarChart(
                            _getListNumOfRequestInstance(listNumOfRI),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Biểu đồ thống kê số lượng yêu cầu theo từng loại.',
                            style: TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    listRequestInstances.length != 0
                        ? _buildTableDetails()
                        : Container(),
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

  _buildTableDetails() {
    List<DataRow> rows = [];
    for (List<RequestInstance> list in listRequestInstances) {
      String dateRange = "0";
      int count = 0;
      int totalDayRange = 0;
      for (RequestInstance requestInstance in list) {
        if (requestInstance.finishedDate != null) {
          count++;
          DateTime created = DateTime.parse(requestInstance.createdDate);
          DateTime finished = DateTime.parse(requestInstance.finishedDate);
          totalDayRange += finished.difference(created).inDays;
        }
      }
      dateRange = (totalDayRange.toDouble() / count.toDouble()).toString();
      rows.add(DataRow(
        onSelectChanged: (bool selected) {
          if (selected) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardEachRequestInstanceScreen(
                        requestInstanceList: list,
                        requestID: list[0].requestID,
                      )),
            );
          }
        },
        cells: <DataCell>[
          DataCell(_buildText(list[0].requestKeyword.trim())),
          DataCell(_buildText(list[0].requestName)),
          DataCell(_buildText(list.length.toString())),
          DataCell(
              _buildText('$dateRange${dateRange != 'NaN' ? ' ngày' : ''}')),
        ],
      ));
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          columnSpacing: 30,
          columns: <DataColumn>[
            DataColumn(
              label: Text(
                'ID',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Tên yêu cầu',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Số lượng',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Thời gian hoàn thành trung bình',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          rows: rows,
        ),
      ),
    );
  }

  _buildText(String text) {
    return Text(text, style: TextStyle(fontSize: 14));
  }

  _pickDate(bool isStart) async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: startDate,
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          startDate = date;
          startDateStr =
              "${startDate.day}/${formatTime(startDate.month)}/${formatTime(startDate.year)}";
          query += "CreatedDate ge ${formatter.format(startDate)}";
        } else {
          dueDate = date;
          dueDateStr =
              "${dueDate.day}/${formatTime(dueDate.month)}/${formatTime(dueDate.year)}";
        }
        query =
            "\$filter=CreatedDate ge ${formatter.format(startDate)} and CreatedDate le ${formatter.format(dueDate)}";
        print(query);
      });
    }
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

  static List<charts.Series<NumOfRequestInstance, String>>
      _getListNumOfRequestInstance(List<NumOfRequestInstance> data) {
    return [
      new charts.Series<NumOfRequestInstance, String>(
        id: 'Requests',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (NumOfRequestInstance num, _) => num.keyword.trim(),
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
    listNumOfRI.clear();
    hashMapRequestInstances.clear();
    listRequestInstances.clear();
  }

  String formatTime(int num) {
    return num < 10 ? '0$num' : num.toString();
  }
}
