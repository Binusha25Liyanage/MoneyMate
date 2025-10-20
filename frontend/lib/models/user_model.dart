class UserModel {
  final int id;
  final String name;
  final String email;
  final String? dateOfBirth;
  final bool isActive;
  final String? lastLogin;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.dateOfBirth,
    required this.isActive,
    this.lastLogin,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      dateOfBirth: json['date_of_birth'],
      isActive: json['is_active'] == 1,
      lastLogin: json['last_login'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'date_of_birth': dateOfBirth,
      'is_active': isActive ? 1 : 0,
      'last_login': lastLogin,
      'created_at': createdAt,
    };
  }
}