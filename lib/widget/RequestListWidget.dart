import 'package:cse_bpm_project/model/Request.dart';
import 'package:cse_bpm_project/screen/CreateRequestInstanceDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestListWidget extends StatefulWidget {
  final List<Request> requestList;

  const RequestListWidget({Key key, this.requestList}) : super(key: key);

  @override
  _RequestListWidgetState createState() => _RequestListWidgetState();
}

class _RequestListWidgetState extends State<RequestListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        Request request = widget.requestList[index];
        String parsedStartDate = DateFormat('kk:mm · dd/MM ').format(DateTime.parse(request.startDate));
        String parsedDueDate = DateFormat('kk:mm · dd/MM').format(DateTime.parse(request.dueDate));
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateRequestInstanceDetailsScreen(requestID: request.id,)),
                );
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(8.0),
                title: Text(
                  '${request.description}',
                ),
                subtitle: Text('$parsedStartDate đến $parsedDueDate'),
              ),
            ),
          ),
        );
      },
      itemCount: widget.requestList.length,
    );
  }
}
