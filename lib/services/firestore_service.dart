import 'dart:async';
import '../models/user_model.dart';
import '../models/period_model.dart';
import '../models/mood_model.dart';
import '../models/diary_model.dart';
import 'database_service.dart';

class FirestoreService {
  final DatabaseService _db = DatabaseService();

  // ============ USER ============

  Future<UserModel?> getUser(String uid) async {
    return _db.getUser(uid);
  }

  Future<void> updateUser(UserModel user) async {
    await _db.updateUserFields(user.uid, user.toMap());
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    await _db.updateUserFields(uid, fields);
  }

  // ============ PERIODS ============

  Future<void> addPeriod(PeriodModel period) async {
    await _db.addPeriod(period);
  }

  Future<void> deletePeriod(String userId, String periodId) async {
    await _db.deletePeriod(userId, periodId);
  }

  Stream<List<PeriodModel>> getPeriods(String userId) {
    return _db.getPeriods(userId);
  }

  Future<List<PeriodModel>> getPeriodsOnce(String userId) async {
    return _db.getPeriodsOnce(userId);
  }

  // ============ MOODS ============

  Future<void> addMood(MoodModel mood) async {
    await _db.addMood(mood);
  }

  Stream<List<MoodModel>> getMoods(String userId) {
    return _db.getMoods(userId);
  }

  Future<List<MoodModel>> getMoodsOnce(String userId) async {
    return _db.getMoodsOnce(userId);
  }

  Future<MoodModel?> getMoodForDate(String userId, DateTime date) async {
    return _db.getMoodForDate(userId, date);
  }

  // ============ DIARIES ============

  Future<void> addDiary(DiaryModel diary) async {
    await _db.addDiary(diary);
  }

  Future<void> updateDiary(String userId, String diaryId, String content) async {
    await _db.updateDiary(userId, diaryId, content);
  }

  Future<void> deleteDiary(String userId, String diaryId) async {
    await _db.deleteDiary(userId, diaryId);
  }

  Stream<List<DiaryModel>> getDiaries(String userId) {
    return _db.getDiaries(userId);
  }

  Future<List<DiaryModel>> getDiariesOnce(String userId) async {
    return _db.getDiariesOnce(userId);
  }

  Future<DiaryModel?> getDiaryForDate(String userId, DateTime date) async {
    return _db.getDiaryForDate(userId, date);
  }
}
