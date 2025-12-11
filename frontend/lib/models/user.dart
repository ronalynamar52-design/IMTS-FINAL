class User {
  final String id;
  final String idNumber;
  final String email;
  final String name;
  final String? department;
  final String role;
  final String? phone;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;

  User({
    required this.id,
    required this.idNumber,
    required this.email,
    required this.name,
    this.department,
    required this.role,
    this.phone,
    this.avatarUrl,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      idNumber: json['id_number'],
      email: json['email'],
      name: json['name'],
      department: json['department'],
      role: json['role'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      isActive: json['is_active'] ?? true,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_number': idNumber,
      'email': email,
      'name': name,
      'department': department,
      'role': role,
      'phone': phone,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}