import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/period_model.dart';
import '../models/mood_model.dart';
import '../models/diary_model.dart';

class DatabaseService {
  // Web storage (so Chrome can login)
  static const String _webUsersKey = 'web_users_v1';
  static const String _webPeriodsKey = 'web_periods_v1';
  static const String _webMoodsKey = 'web_moods_v1';
  static const String _webDiariesKey = 'web_diaries_v1';
  static const String _webSeedEmail = 'kiki@example.com';
  static const String _webSeedPassword = 'kikiexample';
  static const String _webSeedUid = 'default_kiki';

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite not supported on web. Use web methods instead.',
      );
    }
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // --- Web Data Helpers ---

  Future<Map<String, dynamic>> _loadWebData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_webUsersKey);
    if (raw == null || raw.isEmpty) {
      final initial = <String, dynamic>{
        'users': [
          {
            'uid': _webSeedUid,
            'name': 'Kiki',
            'email': _webSeedEmail,
            'avatarIndex': 0,
            'createdAt': DateTime.now().toIso8601String(),
            'password': _webSeedPassword,
          },
        ],
      };
      await prefs.setString(_webUsersKey, jsonEncode(initial));
      return initial;
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _saveWebData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webUsersKey, jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> _loadWebList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _saveWebList(String key, List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(list));
  }

  // --- SQLite Init ---

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'hercycle.db');
    final database = await openDatabase(path, version: 1, onCreate: _createDB);

    // Ensure default user exists even if DB was already created
    final res = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: ['kiki@example.com'],
    );
    if (res.isEmpty) {
      await database.insert('users', {
        'uid': 'default_kiki',
        'name': 'Kiki',
        'email': 'kiki@example.com',
        'avatarIndex': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'password': 'kikiexample',
      });
    } else {
      await database.update(
        'users',
        {'password': 'kikiexample'},
        where: 'email = ?',
        whereArgs: ['kiki@example.com'],
      );
    }

    return database;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        uid TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        avatarIndex INTEGER,
        createdAt TEXT,
        password TEXT
      )
    ''');

    // Seed default user
    await db.insert('users', {
      'uid': 'default_kiki',
      'name': 'Kiki',
      'email': 'kiki@example.com',
      'avatarIndex': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'password': 'kikiexample',
    });

    await db.execute('''
      CREATE TABLE periods (
        id TEXT PRIMARY KEY,
        userId TEXT,
        startDate TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE moods (
        id TEXT PRIMARY KEY,
        userId TEXT,
        date TEXT,
        mood TEXT,
        level INTEGER,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE diaries (
        id TEXT PRIMARY KEY,
        userId TEXT,
        date TEXT,
        title TEXT,
        content TEXT,
        createdAt TEXT
      )
    ''');
  }

  // --- Auth Methods ---
  Future<UserModel> register(String name, String email, String password) async {
    if (kIsWeb) {
      final data = await _loadWebData();
      final users = (data['users'] as List).cast<Map<String, dynamic>>();
      final exists = users.any((u) => (u['email'] as String?) == email);
      if (exists) throw Exception('Email already exists');

      final uid = DateTime.now().millisecondsSinceEpoch.toString();
      final user = UserModel(
        uid: uid,
        name: name,
        email: email,
        avatarIndex: 0,
        createdAt: DateTime.now(),
      );

      users.add({...user.toMap(), 'password': password});

      await _saveWebData({'users': users});
      return user;
    }

    final db = await database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (res.isNotEmpty) throw Exception('Email already exists');

    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    final user = UserModel(
      uid: uid,
      name: name,
      email: email,
      avatarIndex: 0,
      createdAt: DateTime.now(),
    );

    await db.insert('users', {...user.toMap(), 'password': password});

    return user;
  }

  Future<UserModel> login(String email, String password) async {
    if (kIsWeb) {
      final data = await _loadWebData();
      final users = (data['users'] as List).cast<Map<String, dynamic>>();
      final match = users.firstWhere(
        (u) =>
            (u['email'] as String?) == email &&
            (u['password'] as String?) == password,
        orElse: () => <String, dynamic>{},
      );

      if (match.isEmpty) throw Exception('Invalid email or password');

      return UserModel(
        uid: match['uid'] as String,
        name: match['name'] as String,
        email: match['email'] as String,
        avatarIndex: (match['avatarIndex'] as num?)?.toInt() ?? 0,
        createdAt: match['createdAt'] != null
            ? DateTime.parse(match['createdAt'] as String)
            : DateTime.now(),
      );
    }

    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (res.isEmpty) throw Exception('Invalid email or password');
    return UserModel.fromMap(res.first);
  }

  Future<UserModel?> getUser(String uid) async {
    if (kIsWeb) {
      final data = await _loadWebData();
      final users = (data['users'] as List).cast<Map<String, dynamic>>();
      final match = users.where((u) => (u['uid'] as String?) == uid).toList();
      if (match.isEmpty) return null;

      final m = match.first;
      return UserModel(
        uid: m['uid'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
        avatarIndex: (m['avatarIndex'] as num?)?.toInt() ?? 0,
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'] as String)
            : DateTime.now(),
      );
    }

    final db = await database;
    final res = await db.query('users', where: 'uid = ?', whereArgs: [uid]);
    if (res.isEmpty) return null;
    return UserModel.fromMap(res.first);
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    if (kIsWeb) {
      final data = await _loadWebData();
      final users = (data['users'] as List).cast<Map<String, dynamic>>();
      final index = users.indexWhere((u) => (u['uid'] as String?) == uid);
      if (index == -1) return;

      final updated = Map<String, dynamic>.from(users[index]);
      updated.addAll(fields);
      users[index] = updated;

      await _saveWebData({'users': users});
      return;
    }

    final db = await database;
    await db.update('users', fields, where: 'uid = ?', whereArgs: [uid]);
  }

  Future<void> deleteAccount(String uid) async {
    if (kIsWeb) {
      final data = await _loadWebData();
      final users = (data['users'] as List).cast<Map<String, dynamic>>();
      final filtered = users
          .where((u) => (u['uid'] as String?) != uid)
          .toList();
      await _saveWebData({'users': filtered});

      // Also clean up periods, moods, diaries for this user
      var periods = await _loadWebList(_webPeriodsKey);
      periods = periods.where((p) => p['userId'] != uid).toList();
      await _saveWebList(_webPeriodsKey, periods);

      var moods = await _loadWebList(_webMoodsKey);
      moods = moods.where((m) => m['userId'] != uid).toList();
      await _saveWebList(_webMoodsKey, moods);

      var diaries = await _loadWebList(_webDiariesKey);
      diaries = diaries.where((d) => d['userId'] != uid).toList();
      await _saveWebList(_webDiariesKey, diaries);
      return;
    }

    final db = await database;
    await db.delete('users', where: 'uid = ?', whereArgs: [uid]);
    await db.delete('periods', where: 'userId = ?', whereArgs: [uid]);
    await db.delete('moods', where: 'userId = ?', whereArgs: [uid]);
    await db.delete('diaries', where: 'userId = ?', whereArgs: [uid]);
  }

  // --- Period Methods ---
  final _periodsController = StreamController<List<PeriodModel>>.broadcast();

  Future<void> addPeriod(PeriodModel period) async {
    if (kIsWeb) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final list = await _loadWebList(_webPeriodsKey);
      final data = period.toMap();
      data['id'] = id;
      list.add(data);
      await _saveWebList(_webPeriodsKey, list);
      _refreshPeriods(period.userId);
      return;
    }

    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final data = period.toMap();
    data['id'] = id;
    await db.insert('periods', data);
    _refreshPeriods(period.userId);
  }

  Future<void> deletePeriod(String userId, String periodId) async {
    if (kIsWeb) {
      var list = await _loadWebList(_webPeriodsKey);
      list = list.where((p) => p['id'] != periodId).toList();
      await _saveWebList(_webPeriodsKey, list);
      _refreshPeriods(userId);
      return;
    }

    final db = await database;
    await db.delete('periods', where: 'id = ?', whereArgs: [periodId]);
    _refreshPeriods(userId);
  }

  Stream<List<PeriodModel>> getPeriods(String userId) {
    _refreshPeriods(userId);
    return _periodsController.stream;
  }

  Future<List<PeriodModel>> getPeriodsOnce(String userId) async {
    if (kIsWeb) {
      final list = await _loadWebList(_webPeriodsKey);
      final filtered = list.where((p) => p['userId'] == userId).toList();
      filtered.sort((a, b) {
        final dateA = DateTime.parse(a['startDate'] as String);
        final dateB = DateTime.parse(b['startDate'] as String);
        return dateB.compareTo(dateA);
      });
      return filtered.map((m) => PeriodModel.fromMap(m, m['id'] as String)).toList();
    }

    final db = await database;
    final res = await db.query(
      'periods',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'startDate DESC',
    );
    return res.map((m) => PeriodModel.fromMap(m, m['id'] as String)).toList();
  }

  Future<void> _refreshPeriods(String userId) async {
    final res = await getPeriodsOnce(userId);
    _periodsController.add(res);
  }

  // --- Mood Methods ---
  final _moodsController = StreamController<List<MoodModel>>.broadcast();

  Future<void> addMood(MoodModel mood) async {
    if (kIsWeb) {
      final list = await _loadWebList(_webMoodsKey);
      final dateStart = DateTime(mood.date.year, mood.date.month, mood.date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));

      // Check if mood already exists for this date
      final existingIndex = list.indexWhere((m) {
        if (m['userId'] != mood.userId) return false;
        final mDate = DateTime.parse(m['date'] as String);
        return !mDate.isBefore(dateStart) && mDate.isBefore(dateEnd);
      });

      if (existingIndex != -1) {
        // Update existing
        list[existingIndex]['mood'] = mood.mood.name;
        list[existingIndex]['level'] = mood.level;
      } else {
        // Add new
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final data = mood.toMap();
        data['id'] = id;
        list.add(data);
      }

      await _saveWebList(_webMoodsKey, list);
      _refreshMoods(mood.userId);
      return;
    }

    final db = await database;
    final dateStart = DateTime(
      mood.date.year,
      mood.date.month,
      mood.date.day,
    ).toIso8601String();
    final dateEnd = DateTime(
      mood.date.year,
      mood.date.month,
      mood.date.day,
    ).add(const Duration(days: 1)).toIso8601String();

    final res = await db.query(
      'moods',
      where: 'userId = ? AND date >= ? AND date < ?',
      whereArgs: [mood.userId, dateStart, dateEnd],
    );

    if (res.isNotEmpty) {
      await db.update(
        'moods',
        {'mood': mood.mood.name, 'level': mood.level},
        where: 'id = ?',
        whereArgs: [res.first['id']],
      );
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final data = mood.toMap();
      data['id'] = id;
      await db.insert('moods', data);
    }
    _refreshMoods(mood.userId);
  }

  Stream<List<MoodModel>> getMoods(String userId) {
    _refreshMoods(userId);
    return _moodsController.stream;
  }

  Future<List<MoodModel>> getMoodsOnce(String userId) async {
    if (kIsWeb) {
      final list = await _loadWebList(_webMoodsKey);
      final filtered = list.where((m) => m['userId'] == userId).toList();
      filtered.sort((a, b) {
        final dateA = DateTime.parse(a['date'] as String);
        final dateB = DateTime.parse(b['date'] as String);
        return dateB.compareTo(dateA);
      });
      return filtered.map((m) => MoodModel.fromMap(m, m['id'] as String)).toList();
    }

    final db = await database;
    final res = await db.query(
      'moods',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return res.map((m) => MoodModel.fromMap(m, m['id'] as String)).toList();
  }

  Future<MoodModel?> getMoodForDate(String userId, DateTime date) async {
    if (kIsWeb) {
      final list = await _loadWebList(_webMoodsKey);
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));

      final matching = list.where((m) {
        if (m['userId'] != userId) return false;
        final mDate = DateTime.parse(m['date'] as String);
        return !mDate.isBefore(dateStart) && mDate.isBefore(dateEnd);
      }).toList();

      if (matching.isNotEmpty) {
        return MoodModel.fromMap(matching.first, matching.first['id'] as String);
      }
      return null;
    }

    final db = await database;
    final dateStart = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final dateEnd = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(const Duration(days: 1)).toIso8601String();

    final res = await db.query(
      'moods',
      where: 'userId = ? AND date >= ? AND date < ?',
      whereArgs: [userId, dateStart, dateEnd],
    );
    if (res.isNotEmpty) {
      return MoodModel.fromMap(res.first, res.first['id'] as String);
    }
    return null;
  }

  Future<void> _refreshMoods(String userId) async {
    final res = await getMoodsOnce(userId);
    _moodsController.add(res);
  }

  // --- Diary Methods ---
  final _diariesController = StreamController<List<DiaryModel>>.broadcast();

  Future<void> addDiary(DiaryModel diary) async {
    if (kIsWeb) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final list = await _loadWebList(_webDiariesKey);
      final data = diary.toMap();
      data['id'] = id;
      list.add(data);
      await _saveWebList(_webDiariesKey, list);
      _refreshDiaries(diary.userId);
      return;
    }

    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final data = diary.toMap();
    data['id'] = id;
    await db.insert('diaries', data);
    _refreshDiaries(diary.userId);
  }

  Future<void> updateDiary(
    String userId,
    String diaryId,
    String content,
  ) async {
    if (kIsWeb) {
      final list = await _loadWebList(_webDiariesKey);
      final index = list.indexWhere((d) => d['id'] == diaryId && d['userId'] == userId);
      if (index != -1) {
        list[index]['content'] = content;
        await _saveWebList(_webDiariesKey, list);
        _refreshDiaries(userId);
      }
      return;
    }

    final db = await database;
    await db.update(
      'diaries',
      {'content': content},
      where: 'id = ? AND userId = ?',
      whereArgs: [diaryId, userId],
    );
    _refreshDiaries(userId);
  }

  Future<void> deleteDiary(String userId, String diaryId) async {
    if (kIsWeb) {
      var list = await _loadWebList(_webDiariesKey);
      list = list.where((d) => d['id'] != diaryId).toList();
      await _saveWebList(_webDiariesKey, list);
      _refreshDiaries(userId);
      return;
    }

    final db = await database;
    await db.delete('diaries', where: 'id = ?', whereArgs: [diaryId]);
    _refreshDiaries(userId);
  }

  Stream<List<DiaryModel>> getDiaries(String userId) {
    _refreshDiaries(userId);
    return _diariesController.stream;
  }

  Future<List<DiaryModel>> getDiariesOnce(String userId) async {
    if (kIsWeb) {
      final list = await _loadWebList(_webDiariesKey);
      final filtered = list.where((d) => d['userId'] == userId).toList();
      filtered.sort((a, b) {
        final dateA = DateTime.parse(a['date'] as String);
        final dateB = DateTime.parse(b['date'] as String);
        return dateB.compareTo(dateA);
      });
      return filtered.map((m) => DiaryModel.fromMap(m, m['id'] as String)).toList();
    }

    final db = await database;
    final res = await db.query(
      'diaries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return res.map((m) => DiaryModel.fromMap(m, m['id'] as String)).toList();
  }

  Future<DiaryModel?> getDiaryForDate(String userId, DateTime date) async {
    if (kIsWeb) {
      final list = await _loadWebList(_webDiariesKey);
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));

      final matching = list.where((d) {
        if (d['userId'] != userId) return false;
        final dDate = DateTime.parse(d['date'] as String);
        return !dDate.isBefore(dateStart) && dDate.isBefore(dateEnd);
      }).toList();

      if (matching.isNotEmpty) {
        return DiaryModel.fromMap(matching.first, matching.first['id'] as String);
      }
      return null;
    }

    final db = await database;
    final dateStart = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final dateEnd = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(const Duration(days: 1)).toIso8601String();

    final res = await db.query(
      'diaries',
      where: 'userId = ? AND date >= ? AND date < ?',
      whereArgs: [userId, dateStart, dateEnd],
    );
    if (res.isNotEmpty) {
      return DiaryModel.fromMap(res.first, res.first['id'] as String);
    }
    return null;
  }

  Future<void> _refreshDiaries(String userId) async {
    final res = await getDiariesOnce(userId);
    _diariesController.add(res);
  }
}
