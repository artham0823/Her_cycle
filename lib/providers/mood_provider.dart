import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mood_model.dart';
import '../services/firestore_service.dart';

class MoodProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MoodModel> _moods = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<MoodModel> get moods => _moods;
  bool get isLoading => _isLoading;
  int get totalMoods => _moods.length;

  MoodModel? get todaysMood {
    final today = DateTime.now();
    try {
      return _moods.firstWhere(
        (m) =>
            m.date.year == today.year &&
            m.date.month == today.month &&
            m.date.day == today.day,
      );
    } catch (_) {
      return null;
    }
  }

  List<MoodModel> get recentMoods {
    final sorted = List<MoodModel>.from(_moods)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(7).toList();
  }

  void listenToMoods(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestoreService.getMoods(userId).listen((moods) {
      _moods = moods;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> logMood(String userId, MoodType mood, int level) async {
    final now = DateTime.now();
    final moodModel = MoodModel(
      id: '',
      userId: userId,
      date: DateTime(now.year, now.month, now.day),
      mood: mood,
      level: level,
      createdAt: now,
    );
    await _firestoreService.addMood(moodModel);
  }

  MoodModel? getMoodForDate(DateTime date) {
    try {
      return _moods.firstWhere(
        (m) =>
            m.date.year == date.year &&
            m.date.month == date.month &&
            m.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  // Insights helpers
  Map<MoodType, int> get moodDistribution {
    final dist = <MoodType, int>{};
    for (final mood in _moods) {
      dist[mood.mood] = (dist[mood.mood] ?? 0) + 1;
    }
    return dist;
  }

  MoodType? get mostCommonMood {
    final dist = moodDistribution;
    if (dist.isEmpty) return null;
    return dist.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
