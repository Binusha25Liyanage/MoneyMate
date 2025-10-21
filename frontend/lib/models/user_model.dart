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
      isActive: json['is_active'] == 1 || json['is_active'] == true,
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
      'is_active': isActive,
      'last_login': lastLogin,
      'created_at': createdAt,
    };
  }

  // Helper method to format date of birth for display
  String get formattedDateOfBirth {
    if (dateOfBirth == null) return 'Not set';
    try {
      final date = DateTime.parse(dateOfBirth!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateOfBirth!;
    }
  }

  // Helper method to get member since date
  String get memberSince {
    if (createdAt == null) return 'Unknown';
    try {
      final date = DateTime.parse(createdAt!);
      return '${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}