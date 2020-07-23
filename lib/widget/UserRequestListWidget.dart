import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/screen/RequestDetailsScreen.dart';
import 'package:flutter/material.dart';

class UserRequestListWidget extends StatefulWidget {
  final List<RequestInstance> requestList;

  const UserRequestListWidget({Key key, this.requestList}) : super(key: key);

  @override
  _UserRequestListWidgetState createState() => _UserRequestListWidgetState();
}

class _UserRequestListWidgetState extends State<UserRequestListWidget> {
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
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RequestDetailsScreen(
                            numOfStep: 3,
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
