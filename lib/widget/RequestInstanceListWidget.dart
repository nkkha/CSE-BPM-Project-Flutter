import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/screen/RequestDetailsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RequestInstanceListWidget extends StatefulWidget {
  final List<RequestInstance> requestList;

  const RequestInstanceListWidget({Key key, this.requestList}) : super(key: key);

  @override
  _RequestInstanceListWidgetState createState() => _RequestInstanceListWidgetState();
}

class _RequestInstanceListWidgetState extends State<RequestInstanceListWidget> {
  @override
  Widget build(BuildContext context) {
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
            margin: index == 0 ? const EdgeInsets.only(top: 20) : const EdgeInsets.all(0),
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
