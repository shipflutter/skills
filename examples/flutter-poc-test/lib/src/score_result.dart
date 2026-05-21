class ScoreResult {
  const ScoreResult({
    required this.count,
    required this.multiplier,
    required this.discountPercent,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.rating,
  });

  final int count;
  final int multiplier;
  final int discountPercent;
  final int subtotal;
  final double discount;
  final double total;
  final String rating;
}
