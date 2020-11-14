class MyStep {
  final int id;
  final int requestID;
  final String description;
  final int approverRoleID;
  final int stepIndex;

  MyStep({
    this.id,
    this.requestID,
    this.description,
    this.approverRoleID,
    this.stepIndex,
  });

  factory MyStep.fromJson(Map<String, dynamic> json) {
    return MyStep(
      id: json['ID'],
      requestID: json['RequestID'],
      description: json['Description'],
      approverRoleID: json['ApproverRoleID'],
      stepIndex: json['StepIndex'],
    );
  }
}
