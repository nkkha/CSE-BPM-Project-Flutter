import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/screen/RequestInstanceDetailsScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestInstanceListWidget extends StatefulWidget {
  final List<RequestInstance> requestInstanceList;

  const RequestInstanceListWidget({Key key, this.requestInstanceList})
      : super(key: key);

  @override
  _RequestInstanceListWidgetState createState() =>
      _RequestInstanceListWidgetState();
}

class _RequestInstanceListWidgetState
    extends State<RequestInstanceListWidget> {
  @override
  Widget build(BuildContext context) {
    List<RequestInstance> newRequests = new List();
    List<RequestInstance> inProgressRequests = new List();
    List<RequestInstance> doneRequests = new List();
    List<RequestInstance> failedRequests = new List();

    for (RequestInstance request in widget.requestInstanceList) {
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

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            newRequests.length != 0 ? _buildListRequestInstance(newRequests, 1) : Container(),
            inProgressRequests.length != 0 ? _buildListRequestInstance(inProgressRequests, 2) : Container(),
            doneRequests.length != 0 ? _buildListRequestInstance(doneRequests, 3) : Container(),
            failedRequests.length != 0 ? _buildListRequestInstance(failedRequests, 4) : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildListRequestInstance(
      List<RequestInstance> listRequestInstance, int index) {
    String title = "";
    Color color;
    if (index == 1) {
      title = "Yêu cầu mới";
      color = MyColors.amber;
    } else if (index == 2) {
      title = "Đang thực hiện";
      color = MyColors.blue;
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
            itemCount: listRequestInstance.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildRequestInstanceRow(
                  listRequestInstance[index], color, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestInstanceRow(
      RequestInstance requestInstance, Color color, int index) {
    var date = DateTime.parse(requestInstance.createdDate);
    String formattedDate = DateFormat('HH:mm:ss - dd/MM/yyyy').format(date);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RequestInstanceDetailsScreen(
                requestInstance: requestInstance,
                isStudent: true,
                update: (data) {
                  setState(() {});
                },
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
                                  ? '${requestInstance.numOfSteps}/${requestInstance.numOfSteps}'
                                  : '${requestInstance.currentStepIndex}/${requestInstance.numOfSteps}',
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
                        'Mã yêu cầu: ${requestInstance.id}',
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
                        'Quy trình: ${requestInstance.requestKeyword.trim()}  -  Mã: ${requestInstance.requestID}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: MyColors.black,
                        ),
                      ),
                    ),
                    Text(
                      'Thời gian tạo: $formattedDate',
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
            child: Divider(thickness: 1, height: 1),
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
