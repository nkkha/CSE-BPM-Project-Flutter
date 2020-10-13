import 'dart:collection';

import 'package:cse_bpm_project/model/InputFieldInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:cse_bpm_project/web_service/WebService.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:io';

class StepInputFieldInstanceWidget extends StatefulWidget {
  final int requestInstanceID;

  StepInputFieldInstanceWidget({Key key, this.requestInstanceID})
      : super(key: key);

  @override
  _StepInputFieldInstanceWidgetState createState() =>
      _StepInputFieldInstanceWidgetState();
}

class _StepInputFieldInstanceWidgetState
    extends State<StepInputFieldInstanceWidget> {
  var webService = WebService();

  int count = 0;
  ProgressDialog pr;
  List<InputFieldInstance> listIFInstance = new List();
  HashMap listImage = new HashMap<int, File>();

  _imgFromCamera(Function updateImage) async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    updateImage(image);
  }

  _imgFromGallery(Function updateImage) async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    updateImage(image);
  }

  @override
  void initState() {
    super.initState();

    listIFInstance.add(new InputFieldInstance(
        id: 0,
        stepInstanceID: 0,
        inputFieldTypeID: 2,
        title: "CMND mặt trước:"));
    listIFInstance.add(new InputFieldInstance(
        id: 1,
        stepInstanceID: 0,
        inputFieldTypeID: 2,
        title: "CMND mặt sau:"));
    listIFInstance.add(new InputFieldInstance(
        id: 2,
        stepInstanceID: 0,
        inputFieldTypeID: 2,
        title: "Bạn đã có chứng chỉ tiếng Anh hay chưa?"));
  }

  void _showPicker(BuildContext context, Function updateImage) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery((data) {
                          updateImage(data);
                        });
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera((data) {
                        updateImage(data);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
          listIFInstance.length, (index) => _buildInputFieldInstance(index)),
    );
  }

  Widget _buildInputFieldInstance(int index) {
    final int key = listIFInstance[index].id;
    if (listIFInstance[index].inputFieldTypeID == 2) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            Text(
              '${listIFInstance[index].title}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(width: 10, height: 10),
            listImage[key] == null
                ? IconButton(
                    onPressed: () {
                      _showPicker(context, (data) {
                        setState(() {
                          File _image = data;
                          if (listImage.containsKey(key)) {
                            listImage.update(key, (value) => _image);
                          } else {
                            listImage.putIfAbsent(key, () => _image);
                          }
                        });
                      });
                    },
                    icon: Icon(Icons.add_a_photo, size: 36))
                : GestureDetector(
                    onTap: () {
                      _showPicker(context, (data) {
                        setState(() {
                          File _image = data;
                          if (listImage.containsKey(key)) {
                            listImage.update(key, (value) => _image);
                          } else {
                            listImage.putIfAbsent(key, () => _image);
                          }
                        });
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.file(listImage[key]),
                    ),
                  ),
          ],
        ),
      );
    } else if (listIFInstance[index].inputFieldTypeID == 1) {
      TextEditingController _textController = new TextEditingController();
      _textController.text = listIFInstance[index].textAnswer;
      _textController.addListener(() {
        listIFInstance[index].textAnswer = _textController.text;
      });

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                '${listIFInstance[index].title}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            StreamBuilder(
              // stream: authBloc.passStream,
              builder: (context, snapshot) => TextField(
                controller: _textController,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                  errorText: snapshot.hasError ? snapshot.error : null,
                  labelText: 'Trả lời',
//              labelStyle: TextStyle(
//                  color: _myFocusNode.hasFocus
//                      ? MyColors.lightBrand
//                      : MyColors.mediumGray),
                  labelStyle: TextStyle(color: MyColors.mediumGray),
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: MyColors.lightGray, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: MyColors.lightBrand, width: 2.0),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  void _hidePr(boolData) async {
    await pr.hide();
    setState(() {
      // Re-render
    });
  }
}
