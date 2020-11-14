class NumOfRequestInstance {
  final String keyword;
  final int numOfRequestInstance;

  NumOfRequestInstance({
    this.keyword,
    this.numOfRequestInstance,
  });

  factory NumOfRequestInstance.fromJson(Map<String, dynamic> json) {
    return NumOfRequestInstance(
      keyword: json['Keyword'],
      numOfRequestInstance: json['NumOfRequestInstance'],
    );
  }
}
