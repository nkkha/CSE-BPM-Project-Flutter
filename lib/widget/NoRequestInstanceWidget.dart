import 'package:cse_bpm_project/screen/CreateRequestInstanceScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

class NoRequestInstanceWidget extends StatelessWidget {
  final bool isStudent;

  NoRequestInstanceWidget({this.isStudent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
       Positioned(
         top: 20,
         right: 20,
         child: Image.asset('images/arrow.png'),
       ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  isStudent ? 'Hiện tại không' : 'Bạn không',
                  style: TextStyle(
                    color: MyColors.brand,
                    fontSize: 42,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'có yêu cầu nào!',
                  style: TextStyle(
                    color: MyColors.brand,
                    fontSize: 42,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              isStudent
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CreateRequestInstanceScreen(isStudent: true)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: MyColors.lightGray,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'TẠO YÊU CẦU ĐẦU TIÊN!',
                          style: TextStyle(
                            color: MyColors.brand,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.25,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }
}
