import 'dart:io';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SharingService {
  // Singleton pattern
  static final SharingService _instance = SharingService._internal();
  factory SharingService() => _instance;
  SharingService._internal();

  /// Share to WhatsApp with pre-filled text
  Future<bool> shareToWhatsApp({
    required String message,
    String? phoneNumber,
  }) async {
    try {
      // Build WhatsApp URL
      String url;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Remove any non-digit characters
        final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
        url = 'whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}';
      } else {
        url = 'whatsapp://send?text=${Uri.encodeComponent(message)}';
      }

      final uri = Uri.parse(url);

      // Check if WhatsApp is installed
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to general share if WhatsApp not installed
        await Share.share(message);
        return true;
      }
    } catch (e) {
      throw Exception('Failed to share to WhatsApp: $e');
    }
  }

  /// Copy text to clipboard
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Share text via system share sheet
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      throw Exception('Failed to share text: $e');
    }
  }

  /// Share file via system share sheet
  Future<void> shareFile(String filePath, {String? subject}) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject,
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  /// Open email client with pre-filled content
  Future<bool> openEmailClient({
    required String body,
    String? subject,
    String? recipient,
  }) async {
    try {
      final emailUri = Uri(
        scheme: 'mailto',
        path: recipient ?? '',
        query: _encodeQueryParameters({
          if (subject != null) 'subject': subject,
          'body': body,
        }),
      );

      if (await canLaunchUrl(emailUri)) {
        return await launchUrl(emailUri);
      } else {
        // Fallback to share
        await Share.share(
          body,
          subject: subject,
        );
        return true;
      }
    } catch (e) {
      throw Exception('Failed to open email client: $e');
    }
  }

  /// Export transcript as PDF
  Future<String> exportTranscriptAsPdf({
    required String transcript,
    required Map<String, dynamic> analysis,
    String? callId,
  }) async {
    try {
      final pdf = pw.Document();

      // Create PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Call Transcript & Analysis',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Call Information
            if (callId != null)
              pw.Text(
                'Call ID: $callId',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
            pw.Text(
              'Date: ${DateTime.now().toString().split('.')[0]}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 20),

            // Analysis Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Analysis Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Sentiment: ${analysis['overall_sentiment']}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Confidence: ${(analysis['confidence'] * 100).toStringAsFixed(0)}%',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  if (analysis['risk_flags'] != null &&
                      (analysis['risk_flags'] as List).isNotEmpty)
                    pw.Text(
                      'Risk Flags: ${(analysis['risk_flags'] as List).join(', ')}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Key Points
            if (analysis['summary']?['bullet_points'] != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Key Points:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  ...(analysis['summary']['bullet_points'] as List)
                      .map((point) => pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
                            child: pw.Text('• $point',
                                style: const pw.TextStyle(fontSize: 12)),
                          ))
                      .toList(),
                ],
              ),
            pw.SizedBox(height: 20),

            // Transcript
            pw.Text(
              'Full Transcript:',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                transcript,
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),

            // Footer
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text(
              'Generated by CallCraft - Smart Call Analysis',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      );

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/transcript_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  /// Export transcript as text file
  Future<String> exportTranscriptAsText({
    required String transcript,
    required Map<String, dynamic> analysis,
    String? callId,
  }) async {
    try {
      final buffer = StringBuffer();

      // Header
      buffer.writeln('CALL TRANSCRIPT & ANALYSIS');
      buffer.writeln('=' * 50);
      buffer.writeln();

      // Call info
      if (callId != null) {
        buffer.writeln('Call ID: $callId');
      }
      buffer.writeln('Date: ${DateTime.now()}');
      buffer.writeln();

      // Analysis
      buffer.writeln('ANALYSIS SUMMARY');
      buffer.writeln('-' * 50);
      buffer.writeln('Sentiment: ${analysis['overall_sentiment']}');
      buffer.writeln(
          'Confidence: ${(analysis['confidence'] * 100).toStringAsFixed(0)}%');

      if (analysis['risk_flags'] != null &&
          (analysis['risk_flags'] as List).isNotEmpty) {
        buffer.writeln(
            'Risk Flags: ${(analysis['risk_flags'] as List).join(', ')}');
      }
      buffer.writeln();

      // Key Points
      if (analysis['summary']?['bullet_points'] != null) {
        buffer.writeln('KEY POINTS:');
        for (final point in analysis['summary']['bullet_points'] as List) {
          buffer.writeln('• $point');
        }
        buffer.writeln();
      }

      // Transcript
      buffer.writeln('FULL TRANSCRIPT');
      buffer.writeln('-' * 50);
      buffer.writeln(transcript);
      buffer.writeln();

      // Footer
      buffer.writeln('=' * 50);
      buffer.writeln('Generated by CallCraft - Smart Call Analysis');

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/transcript_$timestamp.txt');
      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      throw Exception('Failed to export text: $e');
    }
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
