class InputField {
  final int id;
  final int stepID;
  final int requestID;
  final int inputFieldTypeID;
  String title;

  InputField({
    this.id,
    this.stepID,
    this.requestID,
    this.inputFieldTypeID,
    this.title,
  });

  factory InputField.fromJson(Map<String, dynamic> json) {
    return InputField(
      id: json['ID'],
      stepID: json['StepID'],
      requestID: json['RequestID'],
      inputFieldTypeID: json['InputFieldTypeID'],
      title: json['Title'],
    );
  }
}
