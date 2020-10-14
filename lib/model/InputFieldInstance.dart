import 'dart:typed_data';

class InputFieldInstance {
  final int id;
  final int inputFieldID;
  final int stepInstanceID;
  final int requestInstanceID;
  String fileContent;
  String fileName;
  String textAnswer;
  final int inputFieldTypeID;
  String title;

  InputFieldInstance({
    this.id,
    this.inputFieldID,
    this.stepInstanceID,
    this.requestInstanceID,
    this.fileContent,
    this.fileName,
    this.textAnswer,
    this.inputFieldTypeID,
    this.title,
  });

  factory InputFieldInstance.fromJson(Map<String, dynamic> json) {
    return InputFieldInstance(
      id: json['ID'],
      inputFieldID: json['InputFieldID'],
      stepInstanceID: json['StepInstanceID'],
      requestInstanceID: json['RequestInstanceID'],
      fileContent: json['FileContent'],
      fileName: json['FileName'],
      textAnswer: json['TextAnswer'],
      inputFieldTypeID: json['InputFieldTypeID'],
      title: json['Title'],
    );
  }
}