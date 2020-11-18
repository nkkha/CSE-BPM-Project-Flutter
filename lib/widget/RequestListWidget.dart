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
        String parsedStartDate = DateFormat('kk:mm - dd/MM ').format(DateTime.parse(request.startDate));
        String parsedDueDate = DateFormat('kk:mm - dd/MM').format(DateTime.parse(request.dueDate));
        return Padding(
          padding: index == 0 ? const EdgeInsets.fromLTRB(20, 30, 20, 20) : const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide(width: 2, color: Colors.green),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateRequestInstanceDetailsScreen(request: request)),
                );
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  '${request.description}',
                ),
                subtitle: Text('Từ $parsedStartDate đến $parsedDueDate'),
              ),
            ),
          ),
        );
      },
      itemCount: widget.requestList.length,
    );
  }
}
