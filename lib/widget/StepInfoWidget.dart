import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StepInfoWidget extends StatefulWidget {
  final RequestInstance requestInstance;

  const StepInfoWidget({Key key, this.requestInstance}) : super(key: key);

  @override
  _StepInfoWidgetState createState() => _StepInfoWidgetState(requestInstance);
}

class _StepInfoWidgetState extends State<StepInfoWidget> {
  final RequestInstance _requestInstance;

  _StepInfoWidgetState(this._requestInstance);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: Text(
                "Xét duyệt yêu cầu",
                style: TextStyle(
                    fontSize: 20,
                    color: MyColors.darkGray,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Họ và tên: ${_requestInstance.fullName}",
              style: TextStyle(fontSize: 16, color: MyColors.darkGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Email: ${_requestInstance.email}",
              style: TextStyle(fontSize: 16, color: MyColors.darkGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Phone: ${_requestInstance.phone}",
              style: TextStyle(fontSize: 16, color: MyColors.darkGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Nội dung yêu cầu: ${_requestInstance.defaultContent}",
              style: TextStyle(fontSize: 16, color: MyColors.darkGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Trạng thái yêu cầu: ${_requestInstance.status.contains('TK') ? 'Đang chờ xét duyệt' : 'Đã được xét duyệt'}",
              style: TextStyle(fontSize: 16, color: MyColors.darkGray),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _requestInstance.status.contains('TK')
                  ? Image.asset('images/timer.png', width: 48, height: 48)
                  : Image.asset(
                      'images/ok.png',
                      width: 48,
                      height: 48,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
