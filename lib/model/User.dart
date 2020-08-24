class User {
  final int id;
  final String name;
  final String phone;
  final String email;
  final int roleId;

  User({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['UserId'],
      name: json['Name'],
      phone: json['Phone'],
      email: json['Email'],
      roleId: json['RoleId'],
    );
  }
}
