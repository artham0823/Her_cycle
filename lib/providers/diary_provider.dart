import 'dart:async';
import 'package:flutter/material.dart';
import '../models/diary_model.dart';
import '../services/firestore_service.dart';

class DiaryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<DiaryModel> _diaries = [];
  bool _isLoading = false;
  String _searchQuery = '';
  StreamSubscription? _subscription;

  List<DiaryModel> get diaries => _diaries;
  bool get isLoading => _isLoading;
  int get totalDiaries => _diaries.length;
  String get searchQuery => _searchQuery;

  List<DiaryModel> get filteredDiaries {
    if (_searchQuery.isEmpty) return _diaries;
    return _diaries
        .where((d) =>
            d.content.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<DiaryModel> get recentDiaries {
    final sorted = List<DiaryModel>.from(_diaries)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  void listenToDiaries(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestoreService.getDiaries(userId).listen((diaries) {
      _diaries = diaries;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addDiary(String userId, String content) async {
    final now = DateTime.now();
    final diary = DiaryModel(
      id: '',
      userId: userId,
      date: DateTime(now.year, now.month, now.day),
      content: content,
      createdAt: now,
    );
    await _firestoreService.addDiary(diary);
  }

  Future<void> updateDiary(String userId, String diaryId, String content) async {
    await _firestoreService.updateDiary(userId, diaryId, content);
  }

  Future<void> deleteDiary(String userId, String diaryId) async {
    await _firestoreService.deleteDiary(userId, diaryId);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  DiaryModel? getDiaryForDate(DateTime date) {
    try {
      return _diaries.firstWhere(
        (d) =>
            d.date.year == date.year &&
            d.date.month == date.month &&
            d.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
