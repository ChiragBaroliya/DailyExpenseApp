class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String dateOfBirth; // ISO 8601 string

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
      };
}
