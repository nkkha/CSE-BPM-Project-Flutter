class User {
  final int id;
  final String username;
  final String phone;
  final String email;
  final String fullName;
  final String studentCode;

  User({
    this.id,
    this.username,
    this.phone,
    this.email,
    this.fullName,
    this.studentCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['ID'],
      username: json['UserName'],
      phone: json['Phone'],
      email: json['Mail'],
      fullName: json['FullName'],
      studentCode: json['StudentCode'],
    );
  }
}
