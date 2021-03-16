import 'package:cse_bpm_project/model/Request.dart';
import 'package:cse_bpm_project/screen/CreateRequestInstanceDetailsScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestListWidget extends StatefulWidget {
  final List<Request> requestList;

  const RequestListWidget({Key key, this.requestList}) : super(key: key);

  @override
  _RequestListWidgetState createState() => _RequestListWidgetState();
}

class _RequestListWidgetState extends State<RequestListWidget> {
  List<Request> availableRequests = new List();

  @override
  void initState() {
    super.initState();
    
    for (Request request in widget.requestList) {
      request.startDate = request.startDate.substring(0, request.startDate.length - 6);
      request.dueDate = request.dueDate.substring(0, request.startDate.length - 6);
      DateTime start = DateTime.parse(request.startDate);
      DateTime due = DateTime.parse(request.dueDate);
      if (isCurrentDateInRange(start, due))
        availableRequests.add(request);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        Request request = availableRequests[index];
        String parsedStartDate = DateFormat('kk:mm - dd/MM ').format(DateTime.parse(request.startDate));
        String parsedDueDate = DateFormat('kk:mm - dd/MM').format(DateTime.parse(request.dueDate));
        return Padding(
          padding: index == 0 ? const EdgeInsets.fromLTRB(20, 30, 20, 20) : const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              // side: BorderSide(width: 2, color: Colors.green),
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
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "${availableRequests[index].name}",
                    style: TextStyle(
                        fontSize: 18,
                        color: MyColors.brand,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                subtitle: Text(
                  'Từ $parsedStartDate đến $parsedDueDate',
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
      itemCount: availableRequests.length,
    );
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.compareTo(startDate) >= 0 && currentDate.compareTo(endDate) < 0;
  }
}
