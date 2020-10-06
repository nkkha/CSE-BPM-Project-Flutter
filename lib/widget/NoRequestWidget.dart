import 'package:cse_bpm_project/screen/CreateRequestInstanceScreen.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:flutter/material.dart';

class NoRequestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'Hiện tại',
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
                  'không có yêu cầu nào',
                  style: TextStyle(
                    color: MyColors.brand,
                    fontSize: 42,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateRequestInstanceScreen()),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
