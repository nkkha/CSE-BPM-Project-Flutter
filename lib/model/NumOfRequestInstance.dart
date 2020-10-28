class NumOfRequestInstance {
  final int requestID;
  final int numOfRequestInstance;

  NumOfRequestInstance({
    this.requestID,
    this.numOfRequestInstance,
  });

  factory NumOfRequestInstance.fromJson(Map<String, dynamic> json) {
    return NumOfRequestInstance(
      requestID: json['RequestID'],
      numOfRequestInstance: json['NumOfRequestInstance'],
    );
  }
}
