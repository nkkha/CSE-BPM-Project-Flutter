import 'package:cse_bpm_project/screen/CreateRequestInstanceScreen.dart';
import 'package:cse_bpm_project/screen/CreateRequestScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

class NoRequestWidget extends StatelessWidget {
  final bool isStudent;

  NoRequestWidget({this.isStudent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        !isStudent
            ? Positioned(
                top: 20,
                right: 20,
                child: Image.asset('images/arrow.png'),
              )
            : Container(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  'Hiện tại không',
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
                  'có quy trình nào!',
                  style: TextStyle(
                    color: MyColors.brand,
                    fontSize: 42,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              !isStudent
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CreateRequestScreen()),
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
                          'TẠO QUY TRÌNH ĐẦU TIÊN!',
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
