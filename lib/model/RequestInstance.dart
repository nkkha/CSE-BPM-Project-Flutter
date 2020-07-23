class RequestInstance {
  final int id;
  final int userID;
  final int requestID;
  final String defaultContent;
  final int currentStepIndex;
  final String status;
  final int numOfSteps;

  RequestInstance({
    this.id,
    this.userID,
    this.requestID,
    this.defaultContent,
    this.currentStepIndex,
    this.status,
    this.numOfSteps,
  });

  factory RequestInstance.fromJson(Map<String, dynamic> json) {
    return RequestInstance(
      id: json['ID'],
      userID: json['UserID'],
      requestID: json['RequestID'],
      defaultContent: json['DefaultContent'],
      currentStepIndex: json['CurrentStepIndex'],
      status: json['Status'],
      numOfSteps: json['NumOfSteps'],
    );
  }
}
