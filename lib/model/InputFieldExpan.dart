class InputFieldExpand {
  final String title;
  final String textAnswer;
  final String fileUrl;
  final int inputFieldTypeID;

  InputFieldExpand({
    this.title,
    this.textAnswer,
    this.fileUrl,
    this.inputFieldTypeID,
  });

  factory InputFieldExpand.fromJson(Map<String, dynamic> json) {
    return InputFieldExpand(
      title: json['Title'],
      textAnswer: json['TextAnswer'],
      fileUrl: json['FileUrl'],
      inputFieldTypeID: json['InputFieldTypeID'],
    );
  }
}
