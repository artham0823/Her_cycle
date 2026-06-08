import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mood_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/mood_emoji.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  MoodType _selectedMood = MoodType.neutral;
  int _selectedIntensity = 3;

  @override
  void initState() {
    super.initState();
    // If user already logged mood today, set selectors to today's values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      final todayMood = moodProvider.todaysMood;
      if (todayMood != null) {
        setState(() {
          _selectedMood = todayMood.mood;
          _selectedIntensity = todayMood.level;
        });
      }
    });
  }

  Future<void> _saveMood() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

    if (auth.currentUserId == null) return;

    await moodProvider.logMood(
      auth.currentUserId!,
      _selectedMood,
      _selectedIntensity,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.translate('mood_logged')),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final moodProvider = Provider.of<MoodProvider>(context);
    final isEn = l.currentLanguageCode == 'en';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l.translate('mood'), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logger Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    l.translate('how_feeling'),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Emoji row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MoodEmoji(
                        moodType: MoodType.happy,
                        isSelected: _selectedMood == MoodType.happy,
                        onTap: () => setState(() => _selectedMood = MoodType.happy),
                      ),
                      MoodEmoji(
                        moodType: MoodType.neutral,
                        isSelected: _selectedMood == MoodType.neutral,
                        onTap: () => setState(() => _selectedMood = MoodType.neutral),
                      ),
                      MoodEmoji(
                        moodType: MoodType.angry,
                        isSelected: _selectedMood == MoodType.angry,
                        onTap: () => setState(() => _selectedMood = MoodType.angry),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Intensity Label
                  Text(
                    '${l.translate('intensity')}: $_selectedIntensity / 5',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Slider Selector
                  IntensitySelector(
                    value: _selectedIntensity,
                    onChanged: (val) => setState(() => _selectedIntensity = val),
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: l.translate('save'),
                    onPressed: _saveMood,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Moods Grid
            Text(
              l.translate('recent_moods'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 12),

            if (moodProvider.recentMoods.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    l.translate('no_data'),
                    style: GoogleFonts.poppins(color: AppColors.mediumGrey),
                  ),
                ),
              )
            else
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: moodProvider.recentMoods.length,
                  itemBuilder: (context, index) {
                    final item = moodProvider.recentMoods[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.mood.emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM').format(item.date),
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGrey, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Lvl ${item.level}',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.primaryPink, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // Mood History List
            Text(
              l.translate('mood_history'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 12),

            if (moodProvider.moods.isEmpty)
              Center(
                child: Text(
                  l.translate('no_data'),
                  style: GoogleFonts.poppins(color: AppColors.mediumGrey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moodProvider.moods.length,
                itemBuilder: (context, index) {
                  final item = moodProvider.moods[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.softPink.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Text(item.mood.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.mood.label(isEn),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMMM yyyy').format(item.date),
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGrey),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.softPink.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${l.translate('intensity')}: ${item.level}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
