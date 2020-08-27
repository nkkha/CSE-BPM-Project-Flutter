import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/screen/RequestInstanceDetailsScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StudentRequestInstanceListWidget extends StatefulWidget {
  final List<RequestInstance> requestList;

  const StudentRequestInstanceListWidget({Key key, this.requestList})
      : super(key: key);

  @override
  _StudentRequestInstanceListWidgetState createState() =>
      _StudentRequestInstanceListWidgetState(requestList);
}

class _StudentRequestInstanceListWidgetState
    extends State<StudentRequestInstanceListWidget> {
  final List<RequestInstance> requestList;

  _StudentRequestInstanceListWidgetState(this.requestList);

  @override
  Widget build(BuildContext context) {
    List<RequestInstance> newRequests = new List();
    List<RequestInstance> inProgressRequests = new List();
    List<RequestInstance> doneRequests = new List();
    List<RequestInstance> failedRequests = new List();

    for (RequestInstance request in requestList) {
      if (request.status.contains("new")) {
        newRequests.add(request);
      } else if (request.status.contains("done")) {
        doneRequests.add(request);
      } else if (request.status.contains("failed")) {
        failedRequests.add(request);
      } else {
        inProgressRequests.add(request);
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildListRequestInstance(newRequests, 1),
            _buildListRequestInstance(inProgressRequests, 2),
            _buildListRequestInstance(doneRequests, 3),
            _buildListRequestInstance(failedRequests, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildListRequestInstance(List<RequestInstance> requests, int index) {
    String title = "";
    Color color;
    if (index == 1) {
      title = "Yêu cầu mới";
      color = MyColors.indigo;
    } else if (index == 2) {
      title = "Đang thực hiện";
      color = MyColors.amber;
    } else if (index == 3) {
      title = "Đã hoàn thành";
      color = MyColors.green;
    } else {
      title = "Đã thất bại";
      color = MyColors.red;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTitle(title),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            itemCount: requests.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildRequestInstanceRow(requests[index], color);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestInstanceRow(
      RequestInstance requestInstance, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RequestInstanceDetailsScreen(
                    requestInstance: requestInstance, isStudent: false,
                  )),
        ).then((value) {
          setState(() {
            // Re-render
            print("Re-render");
          });
        });
      },
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(18),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.only(top: 10),
                      height: 60,
                      width: 60,
                      child: Column(
                        children: [
                          Text(
                            'Bước',
                            style: TextStyle(
                                fontSize: 16,
                                color: MyColors.white,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                              requestInstance.status.contains('done')
                                  ? '3/3'
                                  : '${requestInstance.currentStepIndex}/3',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: MyColors.white,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Mã yêu cầu: 000${requestInstance.id}',
                        style: TextStyle(
                          fontSize: 16,
                          color: MyColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, right: 12),
                      child: Text(
                        'Tên sinh viên: ${requestInstance.fullName}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: MyColors.black,
                        ),
                      ),
                    ),
                    Text(
                      'Thời gian tạo: 18:00 - 20/07',
                      style: TextStyle(
                        fontSize: 14,
                        color: MyColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 96),
            child: Divider(
              height: 0.0,
            ),
          ),
        ],
      ),
    );
  }

  _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: Text(
        '$title',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: MyColors.mediumGray,
        ),
      ),
    );
  }
}
