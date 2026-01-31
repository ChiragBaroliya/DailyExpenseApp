class FamilyGroupRequest {
  final String name;
  final String adminUserId;
  final String adminEmail;

  FamilyGroupRequest({required this.name, required this.adminUserId, required this.adminEmail});

  Map<String, dynamic> toJson() => {
        'name': name,
        'adminUserId': adminUserId,
        'adminEmail': adminEmail,
      };
}
