
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/period_model.dart';
import '../models/mood_model.dart';

class PdfService {
  static Future<void> generateAndPrintReport({
    required String userName,
    required List<PeriodModel> periods,
    required List<MoodModel> moods,
  }) async {
    final pdf = pw.Document();

    final ttf = await PdfGoogleFonts.poppinsRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Text(
                  'HerCycle Wellness Report',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.pink,
                  ),
                ),
              ),
              pw.Text(
                'User: $userName',
                style: pw.TextStyle(font: ttf, fontSize: 16),
              ),
              pw.Text(
                'Generated on: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 30),

              // Periods Section
              pw.Text(
                'Recent Periods',
                style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.pink700),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              ...periods.take(5).map((p) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '${DateFormat('MMM dd').format(p.startDate)} - ${DateFormat('MMM dd').format(p.startDate.add(const Duration(days: 4)))}',
                        style: pw.TextStyle(font: ttf),
                      ),
                      pw.Text(
                        '5 days',
                        style: pw.TextStyle(font: ttf),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 30),

              // Moods Section
              pw.Text(
                'Recent Moods',
                style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.pink700),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              ...moods.take(10).map((m) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        DateFormat('MMM dd').format(m.date),
                        style: pw.TextStyle(font: ttf),
                      ),
                      pw.Text(
                        m.mood.name.toUpperCase(),
                        style: pw.TextStyle(font: ttf),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'HerCycle_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
}
