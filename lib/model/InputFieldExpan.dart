class InputField {
  final String title;
  final String textAnswer;
  final String fileUrl;

  InputField({
    this.title,
    this.textAnswer,
    this.fileUrl,
  });

  factory InputField.fromJson(Map<String, dynamic> json) {
    return InputField(
      title: json['Title'],
      textAnswer: json['TextAnswer'],
      fileUrl: json['FileUrl'],
    );
  }
}
