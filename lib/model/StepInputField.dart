class StepInputField {
  final int id;
  final int stepID;
  final int inputFieldID;
  String title;

  StepInputField({
    this.id,
    this.stepID,
    this.inputFieldID,
    this.title,
  });

  factory StepInputField.fromJson(Map<String, dynamic> json) {
    return StepInputField(
      id: json['ID'],
      stepID: json['StepID'],
      inputFieldID: json['InputFieldID'],
      title: json['Title'],
    );
  }
}
