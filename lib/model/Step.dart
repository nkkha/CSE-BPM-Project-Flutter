class Step {
  final int id;
  final int requestID;
  final String description;
  final int approverRoleID;
  final int stepIndex;

  Step({
    this.id,
    this.requestID,
    this.description,
    this.approverRoleID,
    this.stepIndex,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      id: json['ID'],
      requestID: json['RequestID'],
      description: json['Description'],
      approverRoleID: json['ApproverRoleID'],
      stepIndex: json['StepIndex'],
    );
  }
}
