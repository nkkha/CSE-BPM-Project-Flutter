import 'package:cse_bpm_project/screen/XinGiayNVQSScreen.dart';
import 'package:flutter/material.dart';

class CreateRequestScreen extends StatefulWidget {
  @override
  _CreateRequestScreenState createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo yêu cầu'),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(
                    'Xin giấy hoãn nghĩa vụ quân sự',
                  ),
                  subtitle: Text('30/05/2020 - 30/06/2020'),
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => XinGiayNghiaVuScreen()));
              },
            ),
            Divider(),
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(
                    'Xin mở môn học',
                  ),
                  subtitle: Text('30/05/2020 - 30/06/2020'),
                ),
              ),
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => CreateRequestScreen()));
              },
            ),
            Divider(),
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(
                    'Đăng ký làm Pre-thesis',
                  ),
                  subtitle: Text('30/05/2020 - 30/06/2020'),
                ),
              ),
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => CreateRequestScreen()));
              },
            ),
            Divider(),
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(
                    'Đăng ký làm Thesis',
                  ),
                  subtitle: Text('30/05/2020 - 30/06/2020'),
                ),
              ),
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => CreateRequestScreen()));
              },
            ),
            Divider(),
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(
                    'Đăng ký đi internship',
                  ),
                  subtitle: Text('30/05/2020 - 30/06/2020'),
                ),
              ),
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => CreateRequestScreen()));
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
