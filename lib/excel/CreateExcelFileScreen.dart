import 'dart:io';

import 'package:cse_bpm_project/model/RequestInstance.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class CreateExcelFileScreen extends StatefulWidget {
  final List<RequestInstance> list;

  const CreateExcelFileScreen({Key key, this.list}) : super(key: key);

  @override
  _CreateExcelFileScreenState createState() => _CreateExcelFileScreenState();
}

class _CreateExcelFileScreenState extends State<CreateExcelFileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xuất file excel'),
      ),
      body: SingleChildScrollView(
        child: FloatingActionButton(
          onPressed: _createExcelFile,
        ),
      ),
    );
  }

  void _createExcelFile() {
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
      CellIndex.indexByString("H2"),
      customValue: "${widget.list[0].requestName}",
    );

    sheetObject.merge(
      CellIndex.indexByString("A3"),
      CellIndex.indexByString("H4"),
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
        "${rq.currentStepIndex}/${rq.numOfSteps}"
      ];
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

    excel.encode().then((onValue) async {
      final path = await _localPath;
      print(path);
      File("$path/excel.xlsx")
        ..createSync(recursive: true)
        ..writeAsBytesSync(onValue);
      print('Created');
      openFile("$path/excel.xlsx");
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }
}
