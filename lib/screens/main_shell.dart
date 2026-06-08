import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/period_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/diary_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home/home_screen.dart';
import 'calender/calendar_screen.dart';
import 'mood/mood_screen.dart';
import 'diary/diary_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    CalendarScreen(),
    MoodScreen(),
    DiaryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUserId;
    if (userId != null) {
      Provider.of<PeriodProvider>(context, listen: false).listenToPeriods(userId);
      Provider.of<MoodProvider>(context, listen: false).listenToMoods(userId);
      Provider.of<DiaryProvider>(context, listen: false).listenToDiaries(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
