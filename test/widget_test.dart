import 'package:flutter_test/flutter_test.dart';
import 'package:hercycle/models/period_model.dart';
import 'package:hercycle/services/cycle_service.dart';

void main() {
  group('CycleService Tests', () {
    test('calculateAverageCycleLength with empty periods returns default', () {
      final result = CycleService.calculateAverageCycleLength([]);
      expect(result, 28);
    });

    test('calculateAverageCycleLength with one period returns default', () {
      final p1 = PeriodModel(
        id: '1',
        userId: 'user1',
        startDate: DateTime(2026, 3, 1),
        createdAt: DateTime.now(),
      );
      final result = CycleService.calculateAverageCycleLength([p1]);
      expect(result, 28);
    });

    test('calculateAverageCycleLength calculates average correctly', () {
      final p1 = PeriodModel(
        id: '1',
        userId: 'user1',
        startDate: DateTime(2026, 3, 1),
        createdAt: DateTime.now(),
      );
      final p2 = PeriodModel(
        id: '2',
        userId: 'user1',
        startDate: DateTime(2026, 3, 22), // 21 days interval
        createdAt: DateTime.now(),
      );
      final p3 = PeriodModel(
        id: '3',
        userId: 'user1',
        startDate: DateTime(2026, 4, 15), // 24 days interval
        createdAt: DateTime.now(),
      );

      final result = CycleService.calculateAverageCycleLength([p1, p2, p3]);
      // Average of 21 and 24 is 22.5, rounded to 23
      expect(result, 23);
    });

    test('predictNextPeriod predicts next period date correctly', () {
      final p1 = PeriodModel(
        id: '1',
        userId: 'user1',
        startDate: DateTime(2026, 3, 1),
        createdAt: DateTime.now(),
      );
      final p2 = PeriodModel(
        id: '2',
        userId: 'user1',
        startDate: DateTime(2026, 3, 22), // 21 days interval
        createdAt: DateTime.now(),
      );

      final nextPeriod = CycleService.predictNextPeriod([p1, p2]);
      // 2026-03-22 + 21 days = 2026-04-12
      expect(nextPeriod, DateTime(2026, 4, 12));
    });
  });
}
