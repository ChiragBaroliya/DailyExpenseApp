// User model used across the app (simple, no external dependencies).

class User {
  final String id;
  final String email;
  final String firstName;
  final String role;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'role': role,
    };
  }
}
