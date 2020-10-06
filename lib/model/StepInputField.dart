class StepInputField {
  final int id;
  final int stepID;
  final int requestID;
  final int inputFieldID;
  String title;

  StepInputField({
    this.id,
    this.stepID,
    this.requestID,
    this.inputFieldID,
    this.title,
  });

  factory StepInputField.fromJson(Map<String, dynamic> json) {
    return StepInputField(
      id: json['ID'],
      stepID: json['StepID'],
      requestID: json['RequestID'],
      inputFieldID: json['InputFieldID'],
      title: json['Title'],
    );
  }
}
