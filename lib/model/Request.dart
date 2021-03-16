class Request {
  final int id;
  final String name;
  final String description;
  final String status;
  final int creatorID;
  final String createdTime;
  String startDate;
  String dueDate;
  final int numOfSteps;

  Request({
    this.id,
    this.name,
    this.description,
    this.status,
    this.creatorID,
    this.createdTime,
    this.startDate,
    this.dueDate,
    this.numOfSteps,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['ID'],
      name: json['Name'],
      description: json['Description'],
      status: json['Status'],
      creatorID: json['CreatorID'],
      createdTime: json['CreatedTime'],
      startDate: json['StartDate'],
      dueDate: json['DueDate'],
      numOfSteps: json['NumOfSteps'],
    );
  }
}
