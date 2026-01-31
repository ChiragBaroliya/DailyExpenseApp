class ExpenseRequest {
  final double amount;
  final String category;
  final String paymentMode;
  final String date; // ISO string
  final String? notes;
  final String createdBy;
  final String familyGroupId;

  ExpenseRequest({
    required this.amount,
    required this.category,
    required this.paymentMode,
    required this.date,
    this.notes,
    required this.createdBy,
    required this.familyGroupId,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'category': category,
        'paymentMode': paymentMode,
        'date': date,
        if (notes != null) 'notes': notes,
        'createdBy': createdBy,
        'familyGroupId': familyGroupId,
      };
}
