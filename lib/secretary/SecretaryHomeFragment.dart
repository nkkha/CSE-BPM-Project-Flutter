import 'package:cse_bpm_project/screen/CreateRequestScreen.dart';
import 'package:cse_bpm_project/secretary/SecretaryRequestScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

class SecretaryHomeFragment extends StatefulWidget {
  const SecretaryHomeFragment({Key key}) : super(key: key);

  @override
  _SecretaryHomeFragmentState createState() => _SecretaryHomeFragmentState();
}

class _SecretaryHomeFragmentState extends State<SecretaryHomeFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Trang chủ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
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
                            builder: (context) => SecretaryRequestScreen()));
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          child: Text(
                            "Yêu cầu của sinh viên",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
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
                            builder: (context) => CreateRequestScreen()));
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          child: Text(
                            "Tạo yêu cầu mới",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
