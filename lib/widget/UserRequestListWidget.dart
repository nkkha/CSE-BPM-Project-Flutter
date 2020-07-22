import 'package:cse_bpm_project/model/RequestNVQS.dart';
import 'package:cse_bpm_project/screen/RequestDetailsScreen.dart';
import 'package:flutter/material.dart';

class UserRequestListWidget extends StatefulWidget {
  final List<RequestNVQS> requestList;

  const UserRequestListWidget({Key key, this.requestList}) : super(key: key);

  @override
  _UserRequestListWidgetState createState() => _UserRequestListWidgetState();
}

class _UserRequestListWidgetState extends State<UserRequestListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Thông tin yêu cầu",
                      textAlign: TextAlign.center,
                    ),
                    content: Container(
                      height: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Họ và tên: ${widget.requestList[index].studentName}"),
                          Text("MSSV: ${widget.requestList[index].id}"),
                          Text("Email: ${widget.requestList[index].email}"),
                          Text("Phone: ${widget.requestList[index].phone}"),
                          Text(
                              "Nội dung yêu cầu: ${widget.requestList[index].content}"),
                          Text("Trạng thái: Thư ký khoa xét duyệt"),
                        ],
                      ),
                    ),
                    actions: [
                      FlatButton(
                        child: Text("Xóa"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text("Đóng"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RequestDetailsScreen(numOfStep: 4,)),
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    'Mã yêu cầu: ${widget.requestList[index].id}',
                  ),
                  subtitle:
                      Text('''Nội dung: ${widget.requestList[index].content}
Trạng thái: Thư ký khoa đang xét duyệt.'''),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: widget.requestList.length,
    );
  }
}
