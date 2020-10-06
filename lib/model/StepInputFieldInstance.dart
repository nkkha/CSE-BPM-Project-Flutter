class StepInputFieldInstance {
  final int id;
  final int stepInstanceID;
  final String inputFieldTypeID;
  String title;
  String content;

  StepInputFieldInstance({
    this.id,
    this.stepInstanceID,
    this.inputFieldTypeID,
    this.title,
    this.content,
  });

  factory StepInputFieldInstance.fromJson(Map<String, dynamic> json) {
    return StepInputFieldInstance(
      id: json['ID'],
      stepInstanceID: json['StepInstanceID'],
      inputFieldTypeID: json['InputFieldTypeID'],
      title: json['Title'],
      content: json['Content'],
    );
  }
}
