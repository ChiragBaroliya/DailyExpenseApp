class PieCategory {
  final String label;
  final double value;

  PieCategory({required this.label, required this.value});

  factory PieCategory.fromJson(Map<String, dynamic> json) {
    return PieCategory(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }
}
