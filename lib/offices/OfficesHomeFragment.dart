import 'package:cse_bpm_project/offices/OfficesRequestScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

class OfficesHomeFragment extends StatefulWidget {
  final int roleID;

  const OfficesHomeFragment({Key key, this.roleID}) : super(key: key);

  @override
  _OfficesHomeFragmentState createState() => _OfficesHomeFragmentState();
}

class _OfficesHomeFragmentState extends State<OfficesHomeFragment> {
  var title = "";

  @override
  Widget build(BuildContext context) {
    switch (widget.roleID) {
      case 5:
        title = 'PDT';
        break;
      case 6:
        title = 'PTC';
        break;
      default:
        title = 'Offices';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          title,
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
                            builder: (context) => OfficesRequestScreen(roleID: widget.roleID,)));
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          child: Text(
                            "Yêu cầu cần xử lý",
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
