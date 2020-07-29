import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/screen/RequestDetailsScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RequestInstanceListWidget extends StatefulWidget {
  final List<RequestInstance> requestList;

  const RequestInstanceListWidget({Key key, this.requestList})
      : super(key: key);

  @override
  _RequestInstanceListWidgetState createState() =>
      _RequestInstanceListWidgetState(requestList);
}

class _RequestInstanceListWidgetState extends State<RequestInstanceListWidget> {
  final List<RequestInstance> requestList;

  _RequestInstanceListWidgetState(this.requestList);

  @override
  Widget build(BuildContext context) {
    List<RequestInstance> inProgressRequests = new List();
    List<RequestInstance> doneRequests = new List();
    List<RequestInstance> failedRequests = new List();

    for (RequestInstance request in requestList) {
      if (request.status.contains("done")) {
        doneRequests.add(request);
      } else if (request.status.contains("failed")) {
        failedRequests.add(request);
      } else {
        inProgressRequests.add(request);
      }
    }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: <Widget>[
            _buildListRequestInstance(inProgressRequests, 1),
            _buildListRequestInstance(doneRequests, 2),
            _buildListRequestInstance(failedRequests, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildListRequestInstance(List<RequestInstance> requests, int index) {
    String title = "";
    Color color;
    if (index == 1) {
      title = "Đang thực hiện";
      color = MyColors.green;
    } else if (index == 2) {
      title = "Đã hoàn thành";
      color = MyColors.red;
    } else {
      title = "Đã thất bại";
      color = MyColors.black;
    }

    return Column(
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
              builder: (context) => RequestDetailsScreen(
                    requestInstance: requestInstance,
                  )),
        );
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
                        'Nội dung: ${requestInstance.defaultContent}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: MyColors.black,
                        ),
                      ),
                    ),
                    Text(
                      'Thời gian thực hiện: 18:00 - 20/07',
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
            padding: const EdgeInsets.only(left: 90),
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

  Widget _buildListRqIns() {
    return ListView.builder(
      itemBuilder: (context, index) {
        RequestInstance requestInstance = widget.requestList[index];
        String status = requestInstance.status;
        if (status.contains('TK')) {
          status = 'Thư ký khoa đang xét duyệt';
        } else if (status.contains('BCN')) {
          status = 'Ban chủ nhiệm khoa đang xét duyệt';
        } else if (status.contains('PDT')) {
          status = 'Phòng đào tạo khoa đang xét duyệt';
        } else if (status.contains('PTC')) {
          status = 'Phòng tài chính khoa đang xét duyệt';
        } else {
          status = 'Thành công';
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Card(
            margin: index == 0
                ? const EdgeInsets.only(top: 20)
                : const EdgeInsets.all(0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RequestDetailsScreen(
                            requestInstance: requestInstance,
                          )),
                );
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(8.0),
                title: Text(
                  'Nội dung: ${requestInstance.defaultContent}',
                ),
                subtitle: Text('Trạng thái: $status'),
              ),
            ),
          ),
        );
      },
      itemCount: widget.requestList.length,
    );
  }
}
