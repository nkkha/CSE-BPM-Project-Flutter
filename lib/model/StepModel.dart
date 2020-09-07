class StepModel {
  final int id;
  final int requestID;
  final String description;
  final int approverRoleID;
  final int stepIndex;

  StepModel({
    this.id,
    this.requestID,
    this.description,
    this.approverRoleID,
    this.stepIndex,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['ID'],
      requestID: json['RequestID'],
      description: json['Description'],
      approverRoleID: json['ApproverRoleID'],
      stepIndex: json['StepIndex'],
    );
  }
}
