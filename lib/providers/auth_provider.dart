import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isPrivacyLockEnabled = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.currentUser != null;
  String? get currentUserId => _authService.currentUser?.uid;
  bool get isPrivacyLockEnabled => _isPrivacyLockEnabled;

  AuthProvider() {
    _loadPrivacyLock();
  }

  Future<void> _loadPrivacyLock() async {
    final prefs = await SharedPreferences.getInstance();
    _isPrivacyLockEnabled = prefs.getBool('privacy_lock') ?? false;
    notifyListeners();
  }

  Future<void> togglePrivacyLock(bool value) async {
    _isPrivacyLockEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_lock', value);
    notifyListeners();
  }

  Stream<UserModel?> get authStateChanges => _authService.authStateChanges;

  Future<void> loadUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      _user = await _firestoreService.getUser(firebaseUser.uid);
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile({String? name, int? avatarIndex}) async {
    if (_user == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (avatarIndex != null) updates['avatarIndex'] = avatarIndex;

    if (updates.isNotEmpty) {
      await _firestoreService.updateUserFields(_user!.uid, updates);
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        avatarIndex: avatarIndex ?? _user!.avatarIndex,
      );
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.deleteAccount();
      _user = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
