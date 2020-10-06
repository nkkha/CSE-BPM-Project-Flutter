class StepInstance {
  final int id;
  final int requestInstanceID;
  int approverID;
  String defaultContent;
  String status;
  String responseMessage;
  final int stepIndex;
  final String description;
  int approverRoleID;
  String createdDate;
  String finishedDate;

  StepInstance({
    this.id,
    this.requestInstanceID,
    this.approverID,
    this.defaultContent,
    this.status,
    this.responseMessage,
    this.stepIndex,
    this.description,
    this.approverRoleID,
    this.createdDate,
    this.finishedDate
  });

  factory StepInstance.fromJson(Map<String, dynamic> json) {
    return StepInstance(
      id: json['ID'],
      requestInstanceID: json['RequestInstanceID'],
      approverID: json['ApproverID'],
      defaultContent: json['DefaultContent'],
      status: json['Status'],
      responseMessage: json['ResponseMessage'],
      stepIndex: json['StepIndex'],
      description: json['Description'],
      approverRoleID: json['ApproverRoleID'],
      createdDate: json['StartedDate'],
      finishedDate: json['FinishedDate'],
    );
  }
}
