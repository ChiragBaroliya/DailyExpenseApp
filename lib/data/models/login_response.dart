class LoginResponse {
  final String token;
  final String userId;
  final String email;
  final String familyGroupId;

  LoginResponse({required this.token, required this.userId, required this.email, required this.familyGroupId});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
      familyGroupId: json['familyGroupId'] as String,
    );
  }
}
