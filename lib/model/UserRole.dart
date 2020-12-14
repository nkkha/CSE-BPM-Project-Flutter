class UserRole {
  final int userId;
  final int roleId;

  UserRole({
    this.userId,
    this.roleId,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      userId: json['UserId'],
      roleId: json['RoleId'],
    );
  }
}
