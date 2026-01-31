class PasscodeModel {
  final String passcode;
  final DateTime createdAt;

  PasscodeModel({required this.passcode, required this.createdAt});

  factory PasscodeModel.fromJson(Map<String, dynamic> json) {
    return PasscodeModel(
      passcode: json['passcode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'passcode': passcode,
        'createdAt': createdAt.toIso8601String(),
      };
}
