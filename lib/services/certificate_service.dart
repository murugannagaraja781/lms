import 'package:flutter/material.dart' hide Theme, Page; // hide to avoid conflict with pdf widgets
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class CertificateService {
  static Future<void> generateAndShowCertificate({
    required BuildContext context,
    required String studentName,
    required String courseTitle,
    required String instructorName,
  }) async {
    final pdf = pw.Document();
    
    final String dateStr = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue900, width: 10),
              color: PdfColors.white,
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'CERTIFICATE OF COMPLETION',
                  style: pw.TextStyle(
                    fontSize: 40,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'This is to certify that',
                  style: const pw.TextStyle(fontSize: 20),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  studentName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 35,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'has successfully completed the course',
                  style: const pw.TextStyle(fontSize: 20),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  courseTitle,
                  style: pw.TextStyle(
                    fontSize: 25,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(dateStr, style: const pw.TextStyle(fontSize: 16)),
                        pw.Container(width: 150, height: 1, color: PdfColors.black),
                        pw.Text('Date', style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(instructorName, style: pw.TextStyle(fontSize: 16, fontStyle: pw.FontStyle.italic)),
                        pw.Container(width: 150, height: 1, color: PdfColors.black),
                        pw.Text('Instructor', style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${studentName}_${courseTitle}_Certificate.pdf',
    );
  }
}
