class User {
  final String id;
  final String email;
  final String role; // 'Student' or 'Admin'
  final String name;
  final String phone;
  final String profilePictureUrl;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.phone,
    required this.profilePictureUrl,
  });

  factory User.fromMap(String id, Map<String, dynamic> data) {
    return User(
      id: id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'Student',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  // Convert User to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  // Create User from JSON for local storage
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      name: json['name'],
      phone: json['phone'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }
}
