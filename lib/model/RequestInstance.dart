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
  String requestName;
  String requestDescription;
  final int numOfSteps;
  final String userName;
  final String email;
  final String phone;
  final String fullName;

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
      this.requestName,
      this.requestDescription,
      this.numOfSteps,
      this.userName,
      this.email,
      this.phone,
      this.fullName});

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
      requestName: json['RequestName'],
      requestDescription: json['RequestDescription'],
      numOfSteps: json['NumOfSteps'],
      userName: json['UserName'],
      email: json['Mail'],
      phone: json['Phone'],
      fullName: json['FullName'],
    );
  }
}
