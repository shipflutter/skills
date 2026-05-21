import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poc_test/src/score_calculator.dart';

void main() {
  group('calculateScore', () {
    test('calculates the default scenario', () {
      final result = calculateScore(
        count: 12,
        multiplier: 8,
        discountPercent: 10,
      );

      expect(result.subtotal, 96);
      expect(result.discount, 9.6);
      expect(result.total, 86.4);
      expect(result.rating, 'Growth');
    });

    test('returns Starter below 50', () {
      final result = calculateScore(
        count: 4,
        multiplier: 10,
        discountPercent: 0,
      );

      expect(result.total, 40);
      expect(result.rating, 'Starter');
    });

    test('returns Growth from 50 to below 100', () {
      final result = calculateScore(
        count: 5,
        multiplier: 10,
        discountPercent: 0,
      );

      expect(result.total, 50);
      expect(result.rating, 'Growth');
    });

    test('returns Scale at 100 or above', () {
      final result = calculateScore(
        count: 20,
        multiplier: 5,
        discountPercent: 0,
      );

      expect(result.total, 100);
      expect(result.rating, 'Scale');
    });

    test('clamps discount above 100', () {
      final result = calculateScore(
        count: 10,
        multiplier: 10,
        discountPercent: 250,
      );

      expect(result.discountPercent, 100);
      expect(result.total, 0);
    });

    test('clamps negative numeric inputs', () {
      final result = calculateScore(
        count: -4,
        multiplier: -3,
        discountPercent: -10,
      );

      expect(result.count, 0);
      expect(result.multiplier, 0);
      expect(result.discountPercent, 0);
      expect(result.total, 0);
    });

    test('is deterministic across repeated calls', () {
      final first = calculateScore(
        count: 14,
        multiplier: 9,
        discountPercent: 15,
      );
      final second = calculateScore(
        count: 14,
        multiplier: 9,
        discountPercent: 15,
      );

      expect(second.subtotal, first.subtotal);
      expect(second.discount, first.discount);
      expect(second.total, first.total);
      expect(second.rating, first.rating);
    });
  });
}
