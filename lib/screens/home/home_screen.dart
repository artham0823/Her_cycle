import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/period_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/cycle_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final auth = Provider.of<AuthProvider>(context);
    final periods = Provider.of<PeriodProvider>(context);
    final moods = Provider.of<MoodProvider>(context);
    final diaries = Provider.of<DiaryProvider>(context);
    final userName = auth.user?.name ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('HerCycle', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            onPressed: () => Navigator.pushNamed(context, '/insights'),
            tooltip: l.translate('insights'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l.translate('greeting')} $userName 💖',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.translate('tagline'),
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Info Cards Grid
            Row(
              children: [
                Expanded(
                  child: CycleCard(
                    title: l.translate('next_period'),
                    value: periods.nextPeriodDate != null
                        ? DateFormat('dd MMM yyyy').format(periods.nextPeriodDate!)
                        : l.translate('no_data'),
                    icon: Icons.calendar_today_rounded,
                    accentColor: AppColors.primaryPink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CycleCard(
                    title: l.translate('cycle_length'),
                    value: '${periods.averageCycleLength} ${l.translate('days')}',
                    icon: Icons.loop_rounded,
                    accentColor: AppColors.accentPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CycleCard(
              title: l.translate('todays_phase'),
              value: periods.currentPhase.label(l.currentLanguageCode == 'en'),
              icon: Icons.spa_rounded,
              accentColor: AppColors.success,
            ),
            const SizedBox(height: 20),
            // Today's Mood
            if (moods.todaysMood != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softPink.withValues(alpha: 0.5)),
                  boxShadow: [BoxShadow(color: AppColors.primaryPink.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    Text(moods.todaysMood!.mood.emoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.translate('mood'), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.mediumGrey)),
                        Text(
                          '${moods.todaysMood!.mood.label(l.currentLanguageCode == 'en')} • ${l.translate('intensity')}: ${moods.todaysMood!.level}/5',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Quick Log Period
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.softPink.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: AppColors.primaryPink.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.translate('log_period'), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textColor)),
                  const SizedBox(height: 8),
                  Text(DateFormat('dd/MM/yyyy').format(DateTime.now()), style: GoogleFonts.poppins(fontSize: 13, color: AppColors.mediumGrey)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(primary: AppColors.primaryPink, onPrimary: AppColors.white),
                            ),
                            child: child!,
                          ),
                        );
                        if (date != null && context.mounted) {
                          final userId = Provider.of<AuthProvider>(context, listen: false).currentUserId;
                          if (userId != null) {
                            await Provider.of<PeriodProvider>(context, listen: false).addPeriod(userId, date);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Period logged! 🌸'), backgroundColor: AppColors.success),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l.translate('period_start'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Recent Diary Entries
            if (diaries.recentDiaries.isNotEmpty) ...[
              Text(l.translate('diary_entries'), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textColor)),
              const SizedBox(height: 12),
              ...diaries.recentDiaries.take(3).map((diary) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.softPink.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
                      child: Text(DateFormat('dd MMM').format(diary.date), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryPink)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(diary.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textColor)),
                    ),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
