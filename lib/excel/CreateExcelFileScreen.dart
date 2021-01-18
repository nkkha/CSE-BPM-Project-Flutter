import 'dart:convert';
import 'dart:io';

import 'package:cse_bpm_project/model/InputField.dart';
import 'package:cse_bpm_project/model/InputFieldExpan.dart';
import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:cse_bpm_project/source/MyColors.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class CreateExcelFileScreen extends StatefulWidget {
  final List<RequestInstance> list;

  const CreateExcelFileScreen({Key key, this.list}) : super(key: key);

  @override
  _CreateExcelFileScreenState createState() => _CreateExcelFileScreenState();
}

class _CreateExcelFileScreenState extends State<CreateExcelFileScreen> {
  List file = new List();
  String directory;

  @override
  void initState() {
    super.initState();

    _listofFiles();
  }

  void _listofFiles() async {
    directory = await _localPath;
    setState(() {
      file = Directory("$directory/documents/").listSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xuất file excel'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 20),
                  child: Text(
                    'File gần đây',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: MyColors.mediumGray,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: file.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: InkWell(
                            onTap: () => openFile(file[index].path),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    child: Image.asset('images/icons8-microsoft-excel-2019-48.png'),
                                  ),
                                  Expanded(
                                    child: Text(
                                      file[index].path.split("/").last,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createExcelFile,
        child: Icon(Icons.print),
      ),
    );
  }

  void _createExcelFile() async {
    List<InputField> listIF = await _fetchListInputField();
    if (listIF != null) {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      CellStyle headerStyle = CellStyle(
          fontSize: 18,
          bold: true,
          textWrapping: TextWrapping.WrapText,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          fontFamily: getFontFamily(FontFamily.Calibri));

      CellStyle titleStyle = CellStyle(
          fontSize: 14,
          textWrapping: TextWrapping.WrapText,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          fontFamily: getFontFamily(FontFamily.Calibri));

      CellStyle cellStyle = CellStyle(
          fontSize: 14,
          bold: true,
          textWrapping: TextWrapping.WrapText,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          fontFamily: getFontFamily(FontFamily.Calibri));

      sheetObject.merge(
        CellIndex.indexByString("A1"),
        CellIndex.indexByString("${_getCharacter(listIF.length-1)}2"),
        customValue: "${widget.list[0].requestName}",
      );

      sheetObject.merge(
        CellIndex.indexByString("A3"),
        CellIndex.indexByString("${_getCharacter(listIF.length-1)}4"),
        customValue: "${widget.list[0].requestDescription}",
      );

      List<String> dataList = [
        "Họ và tên",
        "Mã SV",
        "Số điện thoại",
        "Email",
        "Thời gian tạo",
        "Nội dung",
        "Trạng thái",
        "Bước hiện tại"
      ];
      for (var ip in listIF) {
        dataList.add(ip.title);
      }
      sheetObject.insertRowIterables(dataList, 4);

      for (int i = 1; i <= widget.list.length; i++) {
        RequestInstance rq = widget.list[i - 1];
        List<String> dataList = [
          rq.fullName,
          rq.code,
          rq.phone,
          rq.email,
          rq.createdDate,
          rq.defaultContent,
          rq.status,
          "${rq.currentStepIndex}/${rq.numOfSteps}",
        ];
        for (Map i in widget.list[i - 1].inputFields) {
          InputFieldExpand ipExpand= InputFieldExpand.fromJson(i);
          if (ipExpand.inputFieldTypeID == 1) {
            dataList.add(ipExpand.textAnswer);
          } else {
            dataList.add(ipExpand.fileUrl);
          }
        }
        sheetObject.insertRowIterables(dataList, i + 4);
      }

      var header = sheetObject.cell(CellIndex.indexByString("A1"));
      header.cellStyle = headerStyle;

      var title = sheetObject.cell(CellIndex.indexByString("A3"));
      title.cellStyle = titleStyle;

      var cellA = sheetObject.cell(CellIndex.indexByString("A5"));
      cellA.cellStyle = cellStyle;
      var cellB = sheetObject.cell(CellIndex.indexByString("B5"));
      cellB.cellStyle = cellStyle;
      var cellC = sheetObject.cell(CellIndex.indexByString("C5"));
      cellC.cellStyle = cellStyle;
      var cellD = sheetObject.cell(CellIndex.indexByString("D5"));
      cellD.cellStyle = cellStyle;
      var cellE = sheetObject.cell(CellIndex.indexByString("E5"));
      cellE.cellStyle = cellStyle;
      var cellF = sheetObject.cell(CellIndex.indexByString("F5"));
      cellF.cellStyle = cellStyle;
      var cellG = sheetObject.cell(CellIndex.indexByString("G5"));
      cellG.cellStyle = cellStyle;
      var cellH = sheetObject.cell(CellIndex.indexByString("H5"));
      cellH.cellStyle = cellStyle;
      for (int i = 0; i < listIF.length; i++) {
        var cellH = sheetObject.cell(CellIndex.indexByString("${_getCharacter(i)}5"));
        cellH.cellStyle = cellStyle;
      }

      excel.encode().then((onValue) async {
        String fileName = widget.list[0].requestKeyword.trim() +
            DateFormat("_yyyy_MM_ddThh_mm_ss").format(DateTime.now()) +
            ".xlsx";
        File("$directory/documents/$fileName")
          ..createSync(recursive: true)
          ..writeAsBytesSync(onValue);
        print('Created');
        setState(() {
          file = Directory("$directory/documents/").listSync();
        });
        openFile("$directory/documents/$fileName");
      });
    }
  }

  Future<List<InputField>> _fetchListInputField() async {
    final response = await get(
        'http://nkkha.somee.com/odata/tbInputField?\$filter=requestID eq ${widget
            .list[0].requestID}&\$orderby=ipindex asc');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['value'];
      List<InputField> listInputField = new List();
      for (Map i in data) {
        listInputField.add(InputField.fromJson(i));
      }
      return listInputField;
    } else {
      throw Exception('Failed to load');
    }
  }

  String _getCharacter(int index) {
    switch (index) {
      case 0:
        return "I";
        break;
      case 1:
        return "J";
        break;
      case 2:
        return "K";
        break;
      case 3:
        return "L";
        break;
      case 4:
        return "M";
        break;
      case 5:
        return "N";
        break;
      case 6:
        return "O";
        break;
      case 7:
        return "P";
        break;
      case 8:
        return "Q";
        break;
      default:
        return "Q";
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }
}

extension FileExtention on FileSystemEntity{
  String get name {
    return this?.path?.split("/")?.last;
  }
}