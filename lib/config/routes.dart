import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String diaryDetail = '/diary-detail';
  static const String editProfile = '/edit-profile';
  static const String insights = '/insights';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Routes are handled via Navigator in main.dart
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Route not found')),
      ),
    );
  }
}
