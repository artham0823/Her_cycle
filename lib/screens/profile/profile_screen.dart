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
import '../../widgets/avatar_selector.dart';
import '../../widgets/cycle_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final auth = Provider.of<AuthProvider>(context);
    final periods = Provider.of<PeriodProvider>(context);
    final moods = Provider.of<MoodProvider>(context);
    final diaries = Provider.of<DiaryProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);

    final user = auth.user;
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';
    final avatarIndex = user?.avatarIndex ?? 0;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l.translate('profile'), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AvatarSelector.buildAvatar(avatarIndex, size: 70),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                          ),
                        ),
                        Text(
                          email,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Joined: ${user != null ? DateFormat('dd MMM yyyy').format(user.createdAt) : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: l.translate('avg_cycle'),
                    value: '${periods.averageCycleLength}d',
                    icon: Icons.loop_rounded,
                    color: AppColors.primaryPink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    title: l.translate('total_moods'),
                    value: '${moods.totalMoods}',
                    icon: Icons.emoji_emotions_rounded,
                    color: AppColors.accentPurple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    title: l.translate('total_diaries'),
                    value: '${diaries.totalDiaries}',
                    icon: Icons.book_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Period History Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.translate('period_history'),
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryPink),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null && auth.currentUserId != null) {
                            await periods.addPeriod(auth.currentUserId!, date);
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  if (periods.periods.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Text(
                          l.translate('no_data'),
                          style: GoogleFonts.poppins(color: AppColors.mediumGrey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: periods.periods.length.clamp(0, 5),
                      itemBuilder: (context, index) {
                        final p = periods.periods[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.water_drop_rounded, color: AppColors.periodRed),
                          title: Text(
                            DateFormat('dd MMMM yyyy').format(p.startDate),
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColor),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            onPressed: () => periods.deletePeriod(auth.currentUserId!, p.id),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.translate('language'),
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColor),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => langProvider.setLanguage('en'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: langProvider.isEnglish ? AppColors.primaryPink : AppColors.lightBackground,
                          foregroundColor: langProvider.isEnglish ? AppColors.white : AppColors.textColor,
                        ),
                        child: Text(l.translate('english')),
                      ),
                      ElevatedButton(
                        onPressed: () => langProvider.setLanguage('id'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !langProvider.isEnglish ? AppColors.primaryPink : AppColors.lightBackground,
                          foregroundColor: !langProvider.isEnglish ? AppColors.white : AppColors.textColor,
                        ),
                        child: Text(l.translate('indonesian')),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.edit_rounded, color: AppColors.primaryPink),
                    title: Text(l.translate('edit_profile'), style: GoogleFonts.poppins(fontSize: 14)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                    title: Text(l.translate('logout'), style: GoogleFonts.poppins(fontSize: 14)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l.translate('logout')),
                          content: Text(l.translate('logout_confirm')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l.translate('cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(l.translate('logout'), style: const TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
