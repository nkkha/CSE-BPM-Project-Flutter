class RequestInstance {
  final int id;
  final int userID;
  final int requestID;
  final String defaultContent;
  int currentStepIndex;
  String status;
  String createdDate;
  String finishedDate;
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
      this.createdDate,
      this.finishedDate,
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
      createdDate: json['CreatedDate'],
      finishedDate: json['FinishedDate'],
      numOfSteps: json['NumOfSteps'],
      userName: json['UserName'],
      email: json['Mail'],
      phone: json['Phone'],
      fullName: json['FullName'],
    );
  }
}
