import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/diary_model.dart';

class DiaryCard extends StatelessWidget {
  final DiaryModel diary;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DiaryCard({
    super.key,
    required this.diary,
    this.onTap,
    this.onDelete,
  });

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diaryDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(diaryDate).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.softPink.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softPink.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(diary.date),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _getTimeAgo(diary.date),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.mediumGrey,
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              diary.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
