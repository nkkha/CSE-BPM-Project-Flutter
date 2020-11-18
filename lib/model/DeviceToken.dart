class DeviceToken {
  final int id;
  final int userID;
  final String token;
  final bool isLogin;

  DeviceToken({
    this.id,
    this.userID,
    this.token,
    this.isLogin,
  });

  factory DeviceToken.fromJson(Map<String, dynamic> json) {
    return DeviceToken(
      id: json['ID'],
      userID: json['UserID'],
      token: json['DeviceToken'],
      isLogin: json['IsLogin']
    );
  }
}
