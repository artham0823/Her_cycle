import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/diary_card.dart';
import 'diary_detail_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _contentCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _contentCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveDiary() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);

    if (auth.currentUserId == null) return;

    await diaryProvider.addDiary(auth.currentUserId!, content);
    _contentCtrl.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.translate('diary_saved')),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final diaryProvider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l.translate('diary'), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logger Form
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.translate('write_diary'),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: DateFormat('dd MMMM yyyy').format(DateTime.now()),
                    hint: l.translate('diary_hint'),
                    controller: _contentCtrl,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: l.translate('save_diary'),
                    onPressed: _saveDiary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Diary Search
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.translate('diary_entries'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => diaryProvider.setSearchQuery(v),
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textColor),
              decoration: InputDecoration(
                hintText: l.translate('search'),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryPink),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.mediumGrey),
                        onPressed: () {
                          _searchCtrl.clear();
                          diaryProvider.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.softPink.withValues(alpha: 0.3)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Entries List
            if (diaryProvider.filteredDiaries.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    l.translate('no_entries'),
                    style: GoogleFonts.poppins(color: AppColors.mediumGrey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: diaryProvider.filteredDiaries.length,
                itemBuilder: (context, index) {
                  final entry = diaryProvider.filteredDiaries[index];
                  return DiaryCard(
                    diary: entry,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryDetailScreen(diary: entry),
                        ),
                      );
                    },
                    onDelete: () async {
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final userId = auth.currentUserId;
                      if (userId == null) return;

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l.translate('delete')),
                          content: Text(l.translate('delete_account_desc')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l.translate('cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(l.translate('delete'), style: const TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await diaryProvider.deleteDiary(userId, entry.id);
                      }
                    },
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
