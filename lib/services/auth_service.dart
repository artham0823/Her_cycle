import 'dart:async';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _db = DatabaseService();
  final _authStateController = StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _db.register(name, email, password);
      _currentUser = user;
      _authStateController.add(user);
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _db.login(email, password);
      _currentUser = user;
      _authStateController.add(user);
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> logout() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  Future<void> deleteAccount() async {
    if (_currentUser != null) {
      await _db.deleteAccount(_currentUser!.uid);
      _currentUser = null;
      _authStateController.add(null);
    }
  }
}
