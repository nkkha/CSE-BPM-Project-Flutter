import 'package:cse_bpm_project/model/RequestInstance.dart';
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
    return Column(
      children: [
        Text("Xác nhận yêu cầu"),
        Text("${_requestInstance.defaultContent}"),
        Text("${_requestInstance.status}"),
      ],
    );
  }
}
