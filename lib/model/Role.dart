class Role {
  final int id;
  final String name;

  Role({
    this.id,
    this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['ID'],
      name: json['Name'],
    );
  }
}
