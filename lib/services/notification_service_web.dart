class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> initialize() async {}
  Future<void> requestPermissions() async {}
  Future<void> scheduleMoodReminder() async {}
  Future<void> schedulePeriodReminder(DateTime predictedDate) async {}
  Future<void> cancelAll() async {}
  Future<void> cancelNotification(int id) async {}
}
