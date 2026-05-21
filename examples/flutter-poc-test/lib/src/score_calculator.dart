import 'score_result.dart';

ScoreResult calculateScore({
  required int count,
  required int multiplier,
  required int discountPercent,
}) {
  final safeCount = count.clamp(0, 1000000);
  final safeMultiplier = multiplier.clamp(0, 1000000);
  final safeDiscountPercent = discountPercent.clamp(0, 100);
  final subtotal = safeCount * safeMultiplier;
  final discount = subtotal * safeDiscountPercent / 100;
  final total = subtotal - discount;

  return ScoreResult(
    count: safeCount,
    multiplier: safeMultiplier,
    discountPercent: safeDiscountPercent,
    subtotal: subtotal,
    discount: discount,
    total: total,
    rating: ratingFor(total),
  );
}

String ratingFor(double total) {
  if (total < 50) return 'Starter';
  if (total < 100) return 'Growth';
  return 'Scale';
}

String formatMoney(double value) => value.toStringAsFixed(2);
