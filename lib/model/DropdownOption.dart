class DropdownOption {
  final int id;
  int inputFieldID;
  String content;

  DropdownOption({
    this.id,
    this.inputFieldID,
    this.content,
  });

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      id: json['ID'],
      inputFieldID: json['InputFieldID'],
      content: json['Content'],
    );
  }
}
