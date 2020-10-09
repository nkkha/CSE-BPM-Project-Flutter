class StepInputField {
  final int id;
  final int stepID;
  final int requestID;
  final int inputFieldTypeID;
  String title;

  StepInputField({
    this.id,
    this.stepID,
    this.requestID,
    this.inputFieldTypeID,
    this.title,
  });

  factory StepInputField.fromJson(Map<String, dynamic> json) {
    return StepInputField(
      id: json['ID'],
      stepID: json['StepID'],
      requestID: json['RequestID'],
      inputFieldTypeID: json['InputFieldTypeID'],
      title: json['Title'],
    );
  }
}
