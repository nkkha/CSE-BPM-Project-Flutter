import 'package:cse_bpm_project/model/InputField.dart';

class RequestInstance {
  final int id;
  final int userID;
  final int requestID;
  final String defaultContent;
  int currentStepIndex;
  String status;
  int approverID;
  String createdDate;
  String finishedDate;
  String requestKeyword;
  String requestName;
  String requestDescription;
  final int numOfSteps;
  final String userName;
  final String email;
  final String phone;
  final String fullName;
  final String code;
  final List<dynamic> inputFields;

  RequestInstance(
      {this.id,
      this.userID,
      this.requestID,
      this.defaultContent,
      this.currentStepIndex,
      this.status,
      this.approverID,
      this.createdDate,
      this.finishedDate,
      this.requestKeyword,
      this.requestName,
      this.requestDescription,
      this.numOfSteps,
      this.userName,
      this.email,
      this.phone,
      this.fullName,
      this.code,
      this.inputFields});

  factory RequestInstance.fromJson(Map<String, dynamic> json) {
    return RequestInstance(
      id: json['ID'],
      userID: json['UserID'],
      requestID: json['RequestID'],
      defaultContent: json['DefaultContent'],
      currentStepIndex: json['CurrentStepIndex'],
      status: json['Status'],
      approverID: json['ApproverID'],
      createdDate: json['CreatedDate'],
      finishedDate: json['FinishedDate'],
      requestKeyword: json['Keyword'],
      requestName: json['RequestName'],
      requestDescription: json['RequestDescription'],
      numOfSteps: json['NumOfSteps'],
      userName: json['UserName'],
      email: json['Mail'],
      phone: json['Phone'],
      fullName: json['FullName'],
      code: json['Code'],
      inputFields: json['InputFields'],
    );
  }
}
