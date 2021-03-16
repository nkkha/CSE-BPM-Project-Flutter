import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/screen/RequestInstanceDetailsScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OfficesStudentRequestInstanceListWidget extends StatefulWidget {
  final List<RequestInstance> requestInstanceList;

  const OfficesStudentRequestInstanceListWidget(
      {Key key, this.requestInstanceList})
      : super(key: key);

  @override
  _OfficesStudentRequestInstanceListWidgetState createState() =>
      _OfficesStudentRequestInstanceListWidgetState();
}

class _OfficesStudentRequestInstanceListWidgetState
    extends State<OfficesStudentRequestInstanceListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _buildListRequestInstance(widget.requestInstanceList),
      ],
    );
  }

  Widget _buildListRequestInstance(List<RequestInstance> requests) {
    String title = "Title";
    Color color = MyColors.amber;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // _buildTitle(title),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            itemCount: requests.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildRequestInstanceRow(requests[index], color, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestInstanceRow(
      RequestInstance requestInstance, Color color, int index) {
    var date = DateTime.parse(requestInstance.createdDate.substring(0, requestInstance.createdDate.length - 6));
    String formattedDate = DateFormat('HH:mm:ss - dd/MM/yyyy').format(date);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RequestInstanceDetailsScreen(
                    requestInstance: requestInstance,
                    isStudent: false,
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
                        'Mã yêu cầu: ${requestInstance.id}  -  Quy trình: ${requestInstance.requestKeyword.trim()}',
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
