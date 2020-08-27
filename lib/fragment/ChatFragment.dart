import 'package:cse_bpm_project/widget/NoChatWidget.dart';
import 'package:flutter/material.dart';

class ChatFragment extends StatefulWidget {
  const ChatFragment({Key key}) : super(key: key);

  @override
  _ChatFragmentState createState() => _ChatFragmentState();
}

class _ChatFragmentState extends State<ChatFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Chat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
//        actions: <Widget>[
//          IconButton(
//            icon: Image.asset(
//              'images/ic-toolbar-new.png',
//            ),
//            onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => null),
//               );
//            },
//          ),
//        ],
      ),
      body: NoChatWidget(),
    );
  }
}
