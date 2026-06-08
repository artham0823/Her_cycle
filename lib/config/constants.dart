class AppConstants {
  // App Info
  static const String appName = 'HerCycle';
  static const String appTagline = 'Understand Your Rhythm, Understand Yourself.';
  static const String appTaglineId = 'Pahami Ritme-mu, Pahami Dirimu.';

  // Default cycle
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int fertileWindowDaysBefore = 14;
  static const int fertileWindowRange = 5; // 5 days fertile window

  // Mood emojis
  static const String happyEmoji = '😊';
  static const String neutralEmoji = '😐';
  static const String angryEmoji = '😡';

  // Avatar count
  static const int avatarCount = 12;

  // Notification IDs
  static const int moodReminderId = 1001;
  static const int periodReminderId = 1002;

  // SharedPreferences keys
  static const String prefLanguage = 'app_language';
  static const String prefNotifications = 'notifications_enabled';
  static const String prefSelectedAvatar = 'selected_avatar';
}
