import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/diary_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diary_provider.dart';
import '../../providers/period_provider.dart';
import '../../providers/mood_provider.dart';

class DiaryDetailScreen extends StatefulWidget {
  final DiaryModel diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  late TextEditingController _contentCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _contentCtrl = TextEditingController(text: widget.diary.content);
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diaryDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(diaryDate).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  Future<void> _updateDiary() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);

    if (auth.currentUserId != null) {
      await diaryProvider.updateDiary(
        auth.currentUserId!,
        widget.diary.id,
        _contentCtrl.text,
      );
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.translate('diary_saved')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final periods = Provider.of<PeriodProvider>(context);
    final moods = Provider.of<MoodProvider>(context);

    final isMenstrual = periods.isMenstrualDay(widget.diary.date);
    final isFertile = periods.isFertileDay(widget.diary.date);
    final phase = periods.getPhaseForDate(widget.diary.date);
    final dayOfCycle = periods.getDayOfCycleForDate(widget.diary.date);

    final mood = moods.getMoodForDate(widget.diary.date);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l.translate('diary'), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded),
            onPressed: () {
              if (_isEditing) {
                _updateDiary();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(widget.diary.date),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeAgo(widget.diary.date),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.softPink.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  // Cycle Phase Row
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMenstrual
                              ? AppColors.periodRed
                              : (isFertile ? AppColors.accentPurple : AppColors.normalGreen),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.translate('cycle_phase'),
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGrey),
                          ),
                          Text(
                            '${phase.label(l.currentLanguageCode == 'en')} • Day $dayOfCycle',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (mood != null) ...[
                    const Divider(height: 24),
                    // Mood Row
                    Row(
                      children: [
                        Text(mood.mood.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.translate('mood'),
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGrey),
                            ),
                            Text(
                              '${mood.mood.label(l.currentLanguageCode == 'en')} • Lvl ${mood.level}',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.softPink.withValues(alpha: 0.5)),
              ),
              child: _isEditing
                  ? TextField(
                      controller: _contentCtrl,
                      maxLines: null,
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textColor, height: 1.6),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Text(
                      _contentCtrl.text,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textColor,
                        height: 1.6,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
