class StepInputFieldInstance {
  final int id;
  final int stepInstanceID;
  final int content;

  StepInputFieldInstance({
    this.id,
    this.stepInstanceID,
    this.content,
  });

  factory StepInputFieldInstance.fromJson(Map<String, dynamic> json) {
    return StepInputFieldInstance(
      id: json['ID'],
      stepInstanceID: json['StepInstanceID'],
      content: json['Content'],
    );
  }
}
