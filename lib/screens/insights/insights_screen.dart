import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mood_model.dart';
import '../../providers/period_provider.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/insight_card.dart';
import '../../services/cycle_service.dart';
import '../../services/pdf_service.dart';
import '../../providers/auth_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final periods = Provider.of<PeriodProvider>(context);
    final moods = Provider.of<MoodProvider>(context);

    // Dynamic insight generation
    final hasEnoughData = periods.periods.isNotEmpty && moods.moods.isNotEmpty;

    // Pattern analysis
    String moodInsightDesc = '';
    String cycleInsightDesc = '';
    
    if (hasEnoughData) {
      // 1. Analyze mood pattern based on cycle phase
      int happyInFollicular = 0;

      for (final mood in moods.moods) {
        final phase = periods.getPhaseForDate(mood.date);
        if (phase == CyclePhase.follicular || phase == CyclePhase.ovulation) {
          if (mood.mood == MoodType.happy) happyInFollicular++;
        }
      }

      if (happyInFollicular > 0) {
        moodInsightDesc = l.translate('happiest_mid_cycle');
      } else {
        moodInsightDesc = l.translate('emotional_before_period');
      }

      // 2. Analyze cycle regularity
      if (periods.periods.length >= 3) {
        cycleInsightDesc = l.translate('avg_cycle_stable');
      } else {
        cycleInsightDesc = l.translate('avg_cycle_varies');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l.translate('insights'), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final p = Provider.of<PeriodProvider>(context, listen: false);
          final m = Provider.of<MoodProvider>(context, listen: false);
          await PdfService.generateAndPrintReport(
            userName: auth.user?.name ?? 'User',
            periods: p.periods,
            moods: m.moods,
          );
        },
        child: const Icon(Icons.picture_as_pdf_rounded),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner card
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
                    l.translate('your_insights'),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.translate('insights_subtitle'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!hasEnoughData) ...[
              // Prompt tracking card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.softPink.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.favorite_rounded, size: 64, color: AppColors.primaryPink),
                    const SizedBox(height: 16),
                    Text(
                      l.translate('start_tracking'),
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.translate('need_more_data'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.mediumGrey, height: 1.5),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Display Insights
              Text(
                l.translate('insights'),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textColor),
              ),
              const SizedBox(height: 12),

              InsightCard(
                title: l.translate('mood_pattern'),
                description: moodInsightDesc,
                icon: Icons.emoji_emotions_rounded,
                color: AppColors.primaryPink,
              ),

              InsightCard(
                title: l.translate('cycle_pattern'),
                description: cycleInsightDesc,
                icon: Icons.loop_rounded,
                color: AppColors.accentPurple,
              ),

              const SizedBox(height: 24),

              // Recent Moods summary grid
              Text(
                l.translate('recent_moods'),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textColor),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: moods.recentMoods.length.clamp(0, 8),
                itemBuilder: (context, index) {
                  final m = moods.recentMoods[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(m.mood.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          '${m.date.day}/${m.date.month}',
                          style: GoogleFonts.poppins(fontSize: 9, color: AppColors.mediumGrey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
