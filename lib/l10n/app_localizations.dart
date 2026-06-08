import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_name': 'HerCycle',
      'tagline': 'Understand Your Rhythm, Understand Yourself.',
      'loading': 'Loading...',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'back': 'Back',
      'search': 'Search...',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'error': 'Error',
      'success': 'Success',
      'copyright': '© 2026 HerCycle. All rights reserved.',

      // Auth
      'login': 'Login',
      'register': 'Register',
      'logout': 'Log Out',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'name': 'Name',
      'forgot_password': 'Forgot Password?',
      'welcome_back': 'Welcome Back',
      'login_subtitle': 'Sign in to continue your journey',
      'create_account': 'Create Account',
      'register_subtitle': 'Start your wellness journey today',
      'already_have_account': 'Already have an account? ',
      'dont_have_account': "Don't have an account? ",
      'reset_password': 'Reset Password',
      'reset_subtitle': 'Enter your email to receive a reset link',
      'send_reset_link': 'Send Reset Link',
      'reset_sent': 'Password reset email sent!',
      'logout_confirm': 'Are you sure you want to Log Out?',
      'yes_logout': 'Yes, Log Out',
      'no_back': 'No, back',

      // Navigation
      'home': 'Home',
      'calendar': 'Calendar',
      'mood': 'Mood',
      'diary': 'Diary',
      'profile': 'Profile',
      'insights': 'Insights',

      // Home
      'greeting': 'Hi',
      'next_period': 'Next Period',
      'cycle_length': 'Cycle Length',
      'days': 'days',
      'todays_phase': "Today's Phase",
      'log_period': 'Log Period',
      'period_start': 'Period Start',
      'how_feeling': 'How are you feeling?',
      'intensity': 'Intensity',
      'write_diary': 'Write Ur Diary',
      'diary_hint': 'Write Bout Ur Day Heree!',
      'save_diary': 'Save Diary',
      'diary_entries': 'Diary Entries',
      'your_diary': 'Your Diary',
      'no_data': 'No data yet',
      'start_tracking': 'Start Tracking',
      'start_tracking_desc': 'Begin by logging your period and mood data!',

      // Calendar
      'period_days': 'Period',
      'normal_days': 'Normal',
      'fertile_window': 'Fertile',
      'predicted_period': 'Predicted',
      'cycle_phase': 'Cycle Phase',
      'period_phase': 'Period Phase',
      'day_of_cycle': 'Day %s of your cycle',

      // Mood
      'happy': 'Happy',
      'neutral': 'Neutral',
      'angry': 'Angry',
      'mood_logged': 'Mood logged successfully! 💖',
      'mood_updated': 'Mood updated! 💖',
      'recent_moods': 'Recent Moods',
      'select_mood': 'Select your mood',
      'mood_history': 'Mood History',

      // Diary
      'new_entry': 'New Entry',
      'diary_saved': 'Diary saved! 📝',
      'diary_deleted': 'Diary entry deleted',
      'no_entries': 'No diary entries yet',
      'write_something': 'Write something about your day...',
      'days_ago': '%s Days Ago',
      'today': 'Today',
      'yesterday': 'Yesterday',

      // Insights
      'your_insights': 'Your Insights',
      'insights_subtitle': 'Personal patterns based on your tracking data',
      'emotional_before_period': 'You tend to feel more emotional before your period.',
      'happiest_mid_cycle': 'Your happiest days are often during the middle of your cycle.',
      'avg_cycle_stable': 'Your cycle length is quite consistent!',
      'avg_cycle_varies': 'Your cycle length varies - this is normal for many women.',
      'mood_pattern': 'Mood Pattern',
      'cycle_pattern': 'Cycle Pattern',
      'no_insights': 'Keep tracking to see insights!',
      'need_more_data': 'We need more data to generate insights. Keep tracking! 💖',

      // Profile
      'edit_profile': 'Edit Profile',
      'update_profile': 'Update Profile',
      'update_profile_desc': 'Update your profile information',
      'change_password': 'Change Password',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'avg_cycle': 'Average Cycle',
      'total_moods': 'Total Moods',
      'total_diaries': 'Total Diaries',
      'period_history': 'Period History',
      'add_period': 'Add Period',
      'danger_zone': 'Danger',
      'delete_account': 'Delete Account',
      'delete_account_desc': 'Are you sure you want to delete all your data? This action cannot be undone.',
      'yes_delete': 'Yes, Delete',
      'profile_updated': 'Profile updated!',
      'password_changed': 'Password changed!',
      'select_avatar': 'Select Avatar',
      'language': 'Language',
      'english': 'English',
      'indonesian': 'Indonesian',
      'notifications': 'Notifications',

      // Phases
      'menstrual': 'Menstrual',
      'follicular': 'Follicular',
      'ovulation': 'Ovulation',
      'luteal': 'Luteal',
      'normal': 'Normal',

      // Onboarding
      'ob_title_1': 'Track Your Cycle',
      'ob_desc_1': 'Log your periods easily and get smart predictions about your cycle phases and fertility window.',
      'ob_title_2': 'Log Your Moods',
      'ob_desc_2': 'Understand your emotions better by tracking your daily moods and their intensities.',
      'ob_title_3': 'Your Safe Space',
      'ob_desc_3': 'Keep a personal diary. Your thoughts and feelings are secure and private.',
      'ob_get_started': 'Get Started',
      'ob_skip': 'Skip',
      'ob_next': 'Next',

      // Lock Screen
      'unlock_reason': 'Please authenticate to unlock HerCycle',
      'app_locked': 'App Locked',
      'unlock': 'Unlock',
      'privacy_lock': 'Privacy Lock',
    },
    'id': {
      // General
      'app_name': 'HerCycle',
      'tagline': 'Pahami Ritme-mu, Pahami Dirimu.',
      'loading': 'Memuat...',
      'save': 'Simpan',
      'cancel': 'Batal',
      'delete': 'Hapus',
      'edit': 'Ubah',
      'back': 'Kembali',
      'search': 'Cari...',
      'yes': 'Ya',
      'no': 'Tidak',
      'ok': 'OK',
      'error': 'Kesalahan',
      'success': 'Berhasil',
      'copyright': '© 2026 HerCycle. Hak cipta dilindungi.',

      // Auth
      'login': 'Masuk',
      'register': 'Daftar',
      'logout': 'Keluar',
      'email': 'Email',
      'password': 'Kata Sandi',
      'confirm_password': 'Konfirmasi Kata Sandi',
      'name': 'Nama',
      'forgot_password': 'Lupa Kata Sandi?',
      'welcome_back': 'Selamat Datang',
      'login_subtitle': 'Masuk untuk melanjutkan perjalananmu',
      'create_account': 'Buat Akun',
      'register_subtitle': 'Mulai perjalanan kesehatan-mu hari ini',
      'already_have_account': 'Sudah punya akun? ',
      'dont_have_account': 'Belum punya akun? ',
      'reset_password': 'Reset Kata Sandi',
      'reset_subtitle': 'Masukkan email untuk menerima tautan reset',
      'send_reset_link': 'Kirim Tautan Reset',
      'reset_sent': 'Email reset kata sandi terkirim!',
      'logout_confirm': 'Apakah kamu yakin ingin Keluar?',
      'yes_logout': 'Ya, Keluar',
      'no_back': 'Tidak, kembali',

      // Navigation
      'home': 'Beranda',
      'calendar': 'Kalender',
      'mood': 'Suasana',
      'diary': 'Buku Harian',
      'profile': 'Profil',
      'insights': 'Wawasan',

      // Home
      'greeting': 'Hai',
      'next_period': 'Menstruasi Berikutnya',
      'cycle_length': 'Panjang Siklus',
      'days': 'hari',
      'todays_phase': 'Fase Hari Ini',
      'log_period': 'Catat Menstruasi',
      'period_start': 'Mulai Menstruasi',
      'how_feeling': 'Bagaimana perasaanmu?',
      'intensity': 'Intensitas',
      'write_diary': 'Tulis Buku Harian',
      'diary_hint': 'Tulis tentang harimu di sini!',
      'save_diary': 'Simpan Buku Harian',
      'diary_entries': 'Catatan Harian',
      'your_diary': 'Buku Harianmu',
      'no_data': 'Belum ada data',
      'start_tracking': 'Mulai Melacak',
      'start_tracking_desc': 'Mulai dengan mencatat data menstruasi dan suasana hati!',

      // Calendar
      'period_days': 'Menstruasi',
      'normal_days': 'Normal',
      'fertile_window': 'Subur',
      'predicted_period': 'Prediksi',
      'cycle_phase': 'Fase Siklus',
      'period_phase': 'Fase Menstruasi',
      'day_of_cycle': 'Hari ke-%s siklus-mu',

      // Mood
      'happy': 'Senang',
      'neutral': 'Netral',
      'angry': 'Marah',
      'mood_logged': 'Suasana hati tercatat! 💖',
      'mood_updated': 'Suasana hati diperbarui! 💖',
      'recent_moods': 'Suasana Terkini',
      'select_mood': 'Pilih suasana hatimu',
      'mood_history': 'Riwayat Suasana',

      // Diary
      'new_entry': 'Catatan Baru',
      'diary_saved': 'Buku harian tersimpan! 📝',
      'diary_deleted': 'Catatan dihapus',
      'no_entries': 'Belum ada catatan',
      'write_something': 'Tulis sesuatu tentang harimu...',
      'days_ago': '%s Hari Lalu',
      'today': 'Hari Ini',
      'yesterday': 'Kemarin',

      // Insights
      'your_insights': 'Wawasanmu',
      'insights_subtitle': 'Pola personal berdasarkan data pelacakanmu',
      'emotional_before_period': 'Kamu cenderung lebih emosional sebelum menstruasi.',
      'happiest_mid_cycle': 'Hari-hari paling bahagia biasanya di tengah siklus.',
      'avg_cycle_stable': 'Panjang siklusmu cukup konsisten!',
      'avg_cycle_varies': 'Panjang siklusmu bervariasi - ini normal untuk banyak wanita.',
      'mood_pattern': 'Pola Suasana',
      'cycle_pattern': 'Pola Siklus',
      'no_insights': 'Terus melacak untuk melihat wawasan!',
      'need_more_data': 'Kami butuh lebih banyak data. Terus melacak! 💖',

      // Profile
      'edit_profile': 'Ubah Profil',
      'update_profile': 'Perbarui Profil',
      'update_profile_desc': 'Perbarui informasi profil-mu',
      'change_password': 'Ubah Kata Sandi',
      'current_password': 'Kata Sandi Saat Ini',
      'new_password': 'Kata Sandi Baru',
      'avg_cycle': 'Rata-rata Siklus',
      'total_moods': 'Total Suasana',
      'total_diaries': 'Total Catatan',
      'period_history': 'Riwayat Menstruasi',
      'add_period': 'Tambah Menstruasi',
      'danger_zone': 'Bahaya',
      'delete_account': 'Hapus Akun',
      'delete_account_desc': 'Apakah kamu yakin ingin menghapus semua data? Tindakan ini tidak dapat dibatalkan.',
      'yes_delete': 'Ya, Hapus',
      'profile_updated': 'Profil diperbarui!',
      'password_changed': 'Kata sandi diubah!',
      'select_avatar': 'Pilih Avatar',
      'language': 'Bahasa',
      'english': 'Inggris',
      'indonesian': 'Indonesia',
      'notifications': 'Notifikasi',

      // Phases
      'menstrual': 'Menstruasi',
      'follicular': 'Folikuler',
      'ovulation': 'Ovulasi',
      'luteal': 'Luteal',
      'normal': 'Normal',

      // Onboarding
      'ob_title_1': 'Lacak Siklusmu',
      'ob_desc_1': 'Catat menstruasimu dengan mudah dan dapatkan prediksi cerdas tentang fase siklus dan masa suburmu.',
      'ob_title_2': 'Catat Suasana Hatimu',
      'ob_desc_2': 'Pahami emosimu lebih baik dengan mencatat suasana hati harian beserta intensitasnya.',
      'ob_title_3': 'Ruang Amanmu',
      'ob_desc_3': 'Simpan buku harian pribadi. Pikiran dan perasaanmu aman dan terjaga privasinya.',
      'ob_get_started': 'Mulai Sekarang',
      'ob_skip': 'Lewati',
      'ob_next': 'Selanjutnya',

      // Lock Screen
      'unlock_reason': 'Silakan autentikasi untuk membuka HerCycle',
      'app_locked': 'Aplikasi Terkunci',
      'unlock': 'Buka Kunci',
      'privacy_lock': 'Kunci Privasi',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get currentLanguageCode => locale.languageCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_language') ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);
    notifyListeners();
  }

  bool get isEnglish => _locale.languageCode == 'en';
}

// Extension for easy access
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => AppLocalizations.of(this).translate(key);
}
