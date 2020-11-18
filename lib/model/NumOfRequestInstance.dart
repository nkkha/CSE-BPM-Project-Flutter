class NumOfRequestInstance {
  final String keyword;
  final int requestID;
  final int numOfRequestInstance;

  NumOfRequestInstance({
    this.keyword,
    this.requestID,
    this.numOfRequestInstance,
  });

  factory NumOfRequestInstance.fromJson(Map<String, dynamic> json) {
    return NumOfRequestInstance(
      keyword: json['Keyword'],
      requestID: json['RequestID'],
      numOfRequestInstance: json['NumOfRequestInstance'],
    );
  }
}
