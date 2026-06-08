import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/period_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/diary_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final periods = Provider.of<PeriodProvider>(context);
    final moods = Provider.of<MoodProvider>(context);
    final diaries = Provider.of<DiaryProvider>(context);

    // Selected day info
    final isMenstrual =
        _selectedDay != null && periods.isMenstrualDay(_selectedDay!);
    final isFertile =
        _selectedDay != null && periods.isFertileDay(_selectedDay!);
    final isPredicted =
        _selectedDay != null && periods.isPredictedDay(_selectedDay!);
    final phase = _selectedDay != null
        ? periods.getPhaseForDate(_selectedDay!)
        : null;
    final dayOfCycle = _selectedDay != null
        ? periods.getDayOfCycleForDate(_selectedDay!)
        : 0;

    final selectedMood = _selectedDay != null
        ? moods.getMoodForDate(_selectedDay!)
        : null;
    final selectedDiary = _selectedDay != null
        ? diaries.getDiaryForDate(_selectedDay!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l.translate('calendar'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Legend
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.softPink.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem(
                    AppColors.periodRed,
                    l.translate('period_days'),
                  ),
                  _buildLegendItem(
                    AppColors.normalGreen,
                    l.translate('normal_days'),
                  ),
                  _buildLegendItem(
                    AppColors.accentPurple,
                    l.translate('fertile_window'),
                  ),
                  _buildLegendItem(
                    AppColors.predictedBlue,
                    l.translate('predicted_period'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Calendar Card
            Container(
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
                border: Border.all(
                  color: AppColors.softPink.withValues(alpha: 0.3),
                ),
              ),
              child: TableCalendar(
                locale: l.currentLanguageCode,
                firstDay: DateTime(2020),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    color: AppColors.softPink,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  formatButtonTextStyle: GoogleFonts.poppins(
                    color: AppColors.primaryPink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  titleTextStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primaryPink,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primaryPink,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.poppins(
                    color: AppColors.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.softPink.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: GoogleFonts.poppins(
                    color: AppColors.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primaryPink,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  defaultTextStyle: GoogleFonts.poppins(
                    color: AppColors.textColor,
                  ),
                  weekendTextStyle: GoogleFonts.poppins(color: AppColors.error),
                  outsideDaysVisible: false,
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final isWeekend =
                        day.weekday == DateTime.saturday ||
                        day.weekday == DateTime.sunday;
                    return _buildDayCell(day, periods, isWeekend: isWeekend);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Day Details Panel
            if (_selectedDay != null) ...[
              Text(
                DateFormat(
                  'EEEE, dd MMMM yyyy',
                  (l.currentLanguageCode == 'id' ||
                          l.currentLanguageCode == 'en')
                      ? l.currentLanguageCode
                      : 'en_US',
                ).format(_selectedDay!),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 12),

              // Phase Detail Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.softPink.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMenstrual
                                ? AppColors.periodRed
                                : (isFertile
                                      ? AppColors.accentPurple
                                      : (isPredicted
                                            ? AppColors.predictedBlue
                                            : AppColors.normalGreen)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.translate('cycle_phase'),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phase?.label(l.currentLanguageCode == 'en') ??
                          l.translate('normal'),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isMenstrual
                            ? AppColors.periodRed
                            : (isFertile
                                  ? AppColors.primaryPink
                                  : AppColors.textColor),
                      ),
                    ),
                    if (dayOfCycle > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        l
                            .translate('day_of_cycle')
                            .replaceAll('%s', '$dayOfCycle'),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Mood Detail Card
              if (selectedMood != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.softPink.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        selectedMood.mood.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.translate('mood'),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                          Text(
                            '${selectedMood.mood.label(l.currentLanguageCode == 'en')} • ${l.translate('intensity')}: ${selectedMood.level}/5',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Diary Detail Card
              if (selectedDiary != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.softPink.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.translate('your_diary'),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selectedDiary.content,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    DateTime day,
    PeriodProvider periods, {
    bool isWeekend = false,
  }) {
    final isMenstrual = periods.isMenstrualDay(day);
    final isFertile = periods.isFertileDay(day);
    final isPredicted = periods.isPredictedDay(day);

    Color? cellColor;
    Color textColor = isWeekend ? AppColors.error : AppColors.textColor;
    FontWeight fontWeight = FontWeight.normal;

    if (isMenstrual) {
      cellColor = AppColors.periodRed.withValues(alpha: 0.25);
      textColor = AppColors.error;
      fontWeight = FontWeight.bold;
    } else if (isFertile) {
      cellColor = AppColors.accentPurple.withValues(alpha: 0.3);
      textColor = Colors.purple.shade700;
      fontWeight = FontWeight.bold;
    } else if (isPredicted) {
      cellColor = AppColors.predictedBlue.withValues(alpha: 0.3);
      textColor = Colors.blue.shade700;
      fontWeight = FontWeight.bold;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: cellColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: GoogleFonts.poppins(color: textColor, fontWeight: fontWeight),
      ),
    );
  }
}
