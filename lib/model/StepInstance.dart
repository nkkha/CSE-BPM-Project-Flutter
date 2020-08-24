class StepInstance {
  final int id;
  final int requestInstanceID;
  final int approverID;
  final String defaultContent;
  final String status;
  final int stepIndex;
  final  description;

  StepInstance({
    this.id,
    this.requestInstanceID,
    this.approverID,
    this.defaultContent,String
    this.status,
    this.stepIndex,
    this.description,
  });

  factory StepInstance.fromJson(Map<String, dynamic> json) {
    return StepInstance(
      id: json['ID'],
      requestInstanceID: json['RequestInstanceID'],
      approverID: json['ApproverID'],
      defaultContent: json['DefaultContent'],
      status: json['Status'],
      stepIndex: json['StepIndex'],
      description: json['Description'],
    );
  }
}
