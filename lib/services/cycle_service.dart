import '../models/period_model.dart';
import '../config/constants.dart';

enum CyclePhase {
  menstrual,
  follicular,
  ovulation,
  luteal,
  unknown;

  String label(bool isEnglish) {
    switch (this) {
      case CyclePhase.menstrual:
        return isEnglish ? 'Menstrual' : 'Menstruasi';
      case CyclePhase.follicular:
        return isEnglish ? 'Follicular' : 'Folikuler';
      case CyclePhase.ovulation:
        return isEnglish ? 'Ovulation' : 'Ovulasi';
      case CyclePhase.luteal:
        return isEnglish ? 'Luteal' : 'Luteal';
      case CyclePhase.unknown:
        return isEnglish ? 'Normal' : 'Normal';
    }
  }
}

class CycleService {
  /// Calculate the average cycle length from a list of period start dates.
  /// Uses adaptive average: computes intervals between consecutive dates.
  static int calculateAverageCycleLength(List<PeriodModel> periods) {
    if (periods.length < 2) return AppConstants.defaultCycleLength;

    // Sort by date ascending
    final sorted = List<PeriodModel>.from(periods)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final intervals = <int>[];
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].startDate.difference(sorted[i - 1].startDate).inDays;
      if (diff > 0 && diff < 60) {
        // Ignore unreasonable intervals
        intervals.add(diff);
      }
    }

    if (intervals.isEmpty) return AppConstants.defaultCycleLength;

    final sum = intervals.reduce((a, b) => a + b);
    return (sum / intervals.length).round();
  }

  /// Predict next period date based on last period + average cycle length.
  static DateTime? predictNextPeriod(List<PeriodModel> periods) {
    if (periods.isEmpty) return null;

    final sorted = List<PeriodModel>.from(periods)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final lastPeriod = sorted.first.startDate;
    final avgCycle = calculateAverageCycleLength(periods);

    return lastPeriod.add(Duration(days: avgCycle));
  }

  /// Get the current cycle phase for a given date.
  static CyclePhase getCurrentPhase(List<PeriodModel> periods, DateTime date) {
    if (periods.isEmpty) return CyclePhase.unknown;

    final sorted = List<PeriodModel>.from(periods)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final lastPeriod = sorted.first.startDate;
    final avgCycle = calculateAverageCycleLength(periods);
    final dayOfCycle = date.difference(lastPeriod).inDays;

    if (dayOfCycle < 0) return CyclePhase.unknown;

    // Period phase (days 1-5)
    if (dayOfCycle < AppConstants.defaultPeriodLength) {
      return CyclePhase.menstrual;
    }

    // Follicular phase (days 6-13)
    if (dayOfCycle < avgCycle - AppConstants.fertileWindowDaysBefore - 1) {
      return CyclePhase.follicular;
    }

    // Ovulation phase (days around mid-cycle)
    final ovulationDay = avgCycle - AppConstants.fertileWindowDaysBefore;
    if (dayOfCycle >= ovulationDay - 2 && dayOfCycle <= ovulationDay + 2) {
      return CyclePhase.ovulation;
    }

    // Luteal phase
    if (dayOfCycle < avgCycle) {
      return CyclePhase.luteal;
    }

    return CyclePhase.unknown;
  }

  /// Get the day number in the current cycle.
  static int getDayOfCycle(List<PeriodModel> periods, DateTime date) {
    if (periods.isEmpty) return 0;

    final sorted = List<PeriodModel>.from(periods)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final lastPeriod = sorted.first.startDate;
    return date.difference(lastPeriod).inDays + 1;
  }

  /// Check if a given date is a menstrual day.
  static bool isMenstrualDay(List<PeriodModel> periods, DateTime date) {
    for (final period in periods) {
      final diff = date.difference(period.startDate).inDays;
      if (diff >= 0 && diff < AppConstants.defaultPeriodLength) {
        return true;
      }
    }
    return false;
  }

  /// Check if a given date is in the fertile window.
  static bool isFertileDay(List<PeriodModel> periods, DateTime date) {
    if (periods.isEmpty) return false;

    final avgCycle = calculateAverageCycleLength(periods);

    for (final period in periods) {
      final ovulationDay = period.startDate.add(Duration(days: avgCycle - AppConstants.fertileWindowDaysBefore));
      final fertileStart = ovulationDay.subtract(const Duration(days: 2));
      final fertileEnd = ovulationDay.add(const Duration(days: 2));

      if (!date.isBefore(fertileStart) && !date.isAfter(fertileEnd)) {
        return true;
      }
    }
    return false;
  }

  /// Check if a date is a predicted period day.
  static bool isPredictedDay(List<PeriodModel> periods, DateTime date) {
    final nextPeriod = predictNextPeriod(periods);
    if (nextPeriod == null) return false;

    final diff = date.difference(nextPeriod).inDays;
    return diff >= 0 && diff < AppConstants.defaultPeriodLength;
  }

  /// Get fertile window dates for display.
  static List<DateTime> getFertileWindow(List<PeriodModel> periods) {
    final nextPeriod = predictNextPeriod(periods);
    if (nextPeriod == null) return [];

    final avgCycle = calculateAverageCycleLength(periods);
    final sorted = List<PeriodModel>.from(periods)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final lastPeriod = sorted.first.startDate;

    final ovulationDay = lastPeriod.add(Duration(days: avgCycle - AppConstants.fertileWindowDaysBefore));
    final fertileStart = ovulationDay.subtract(const Duration(days: 2));

    return List.generate(
      AppConstants.fertileWindowRange,
      (i) => fertileStart.add(Duration(days: i)),
    );
  }
}
