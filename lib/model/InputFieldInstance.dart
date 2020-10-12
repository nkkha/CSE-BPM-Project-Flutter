class InputFieldInstance {
  final int id;
  final int inputFieldID;
  final int stepInstanceID;
  final int requestInstanceID;
  String fileContent;
  String textAnswer;
  final int inputFieldTypeID;
  String content;
  String title;

  InputFieldInstance({
    this.id,
    this.inputFieldID,
    this.stepInstanceID,
    this.requestInstanceID,
    this.fileContent,
    this.textAnswer,
    this.inputFieldTypeID,
    this.content,
    this.title,
  });

  factory InputFieldInstance.fromJson(Map<String, dynamic> json) {
    return InputFieldInstance(
      id: json['ID'],
      inputFieldID: json['InputFieldID'],
      stepInstanceID: json['StepInstanceID'],
      requestInstanceID: json['RequestInstanceID'],
      fileContent: json['FileContent'],
      textAnswer: json['TextAnswer'],
      inputFieldTypeID: json['InputFieldTypeID'],
      content: json['Content'],
      title: json['Title'],
    );
  }
}