import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  ExpenseModel({required String id, required String title, required double amount, required DateTime date})
      : super(id: id, title: title, amount: amount, date: date);

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
