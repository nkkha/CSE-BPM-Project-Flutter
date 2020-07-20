class RequestNVQS {
  final int id;
  final String content;
  final int userID;
  final String status;
  final String studentName;
  final String studentID;
  final String email;
  final int phone;

  RequestNVQS({
    this.id,
    this.content,
    this.userID,
    this.status,
    this.studentName,
    this.studentID,
    this.email,
    this.phone,
  });

  factory RequestNVQS.fromJson(Map<String, dynamic> json) {
    return RequestNVQS(
      id: json['ID'],
      content: json['Content'],
      userID: json['UserID'],
      status: json['Status'],
      studentName: json['StudentName'],
      studentID: json['StudentID'],
      email: json['Email'],
      phone: json['Phone'],
    );
  }
}
