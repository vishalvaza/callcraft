import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/sharing_service.dart';

class AnalysisScreen extends StatefulWidget {
  final Map<String, dynamic> analysis;
  final String? transcript;

  const AnalysisScreen({
    super.key,
    required this.analysis,
    this.transcript,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _apiService = ApiService();
  final _sharingService = SharingService();

  bool _isGeneratingWhatsApp = false;
  bool _isGeneratingEmail = false;
  bool _isExporting = false;
  String? _whatsappMessage;
  String? _emailDraft;

  @override
  Widget build(BuildContext context) {
    final sentiment = widget.analysis['overall_sentiment'] as String;
    final confidence = widget.analysis['confidence'] as double;
    final riskFlags = widget.analysis['risk_flags'] as List<dynamic>;
    final summaryPoints =
        widget.analysis['summary']['bullet_points'] as List<dynamic>;
    final reasoning = widget.analysis['reasoning'] as String;
    final callRecordId = widget.analysis['call_record_id'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        actions: [
          if (widget.transcript != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleMenuAction(value, callRecordId),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export_pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text('Export as PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export_text',
                  child: Row(
                    children: [
                      Icon(Icons.text_snippet),
                      SizedBox(width: 8),
                      Text('Export as Text'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share Analysis'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sentiment Card
            _buildSentimentCard(sentiment, confidence),
            const SizedBox(height: 16),

            // Risk Flags
            if (riskFlags.isNotEmpty) ...[
              _buildSectionTitle('Risk Flags'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: riskFlags.map((flag) {
                  return Chip(
                    label: Text(
                      _formatRiskFlag(flag as String),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.red.shade100,
                    labelStyle: TextStyle(color: Colors.red.shade900),
                    avatar: const Icon(Icons.warning_amber_rounded, size: 16),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Summary
            _buildSectionTitle('Summary'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: summaryPoints.map((point) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(child: Text(point as String)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reasoning
            _buildSectionTitle('Reasoning'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(reasoning),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            _buildSectionTitle('Follow-up Actions'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isGeneratingWhatsApp
                        ? null
                        : () => _generateWhatsAppMessage(callRecordId),
                    icon: _isGeneratingWhatsApp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isGeneratingEmail
                        ? null
                        : () => _generateEmailDraft(callRecordId),
                    icon: _isGeneratingEmail
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.email),
                    label: const Text('Email'),
                  ),
                ),
              ],
            ),

            // Generated content
            if (_whatsappMessage != null) ...[
              const SizedBox(height: 16),
              _buildGeneratedContent(
                'WhatsApp Message',
                _whatsappMessage!,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.send),
                    tooltip: 'Send to WhatsApp',
                    onPressed: () => _shareToWhatsApp(_whatsappMessage!),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy to clipboard',
                    onPressed: () => _copyToClipboard(_whatsappMessage!),
                  ),
                ],
              ),
            ],
            if (_emailDraft != null) ...[
              const SizedBox(height: 16),
              _buildGeneratedContent(
                'Email Draft',
                _emailDraft!,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.mail),
                    tooltip: 'Open in email app',
                    onPressed: () => _openEmailClient(_emailDraft!),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy to clipboard',
                    onPressed: () => _copyToClipboard(_emailDraft!),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentCard(String sentiment, double confidence) {
    final color = _getSentimentColor(sentiment);
    final icon = _getSentimentIcon(sentiment);
    final displayText = _getSentimentDisplayText(sentiment);

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildGeneratedContent(
    String title,
    String content, {
    List<Widget> actions = const [],
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(children: actions),
              ],
            ),
            const Divider(),
            Text(content),
          ],
        ),
      ),
    );
  }

  Future<void> _generateWhatsAppMessage(String callRecordId) async {
    setState(() => _isGeneratingWhatsApp = true);

    try {
      final message = await _apiService.generateWhatsAppMessage(
        callRecordId: callRecordId,
      );

      setState(() {
        _whatsappMessage = message;
        _isGeneratingWhatsApp = false;
      });
    } catch (e) {
      setState(() => _isGeneratingWhatsApp = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate WhatsApp message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateEmailDraft(String callRecordId) async {
    setState(() => _isGeneratingEmail = true);

    try {
      final email = await _apiService.generateEmailDraft(
        callRecordId: callRecordId,
      );

      setState(() {
        _emailDraft = email;
        _isGeneratingEmail = false;
      });
    } catch (e) {
      setState(() => _isGeneratingEmail = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate email draft: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareToWhatsApp(String message) async {
    try {
      await _sharingService.shareToWhatsApp(message: message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share to WhatsApp: $e')),
        );
      }
    }
  }

  Future<void> _openEmailClient(String email) async {
    try {
      // Extract subject and body from email draft
      final lines = email.split('\n');
      String? subject;
      String body = email;

      if (lines.first.startsWith('Subject:')) {
        subject = lines.first.substring(9).trim();
        body = lines.skip(1).join('\n').trim();
      }

      await _sharingService.openEmailClient(
        body: body,
        subject: subject,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open email: $e')),
        );
      }
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await _sharingService.copyToClipboard(text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  Future<void> _handleMenuAction(String action, String callRecordId) async {
    setState(() => _isExporting = true);

    try {
      switch (action) {
        case 'export_pdf':
          final pdfPath = await _sharingService.exportTranscriptAsPdf(
            transcript: widget.transcript!,
            analysis: widget.analysis,
            callId: callRecordId,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF exported: $pdfPath')),
            );
            await _sharingService.shareFile(pdfPath, subject: 'Call Transcript');
          }
          break;

        case 'export_text':
          final textPath = await _sharingService.exportTranscriptAsText(
            transcript: widget.transcript!,
            analysis: widget.analysis,
            callId: callRecordId,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Text exported: $textPath')),
            );
            await _sharingService.shareFile(textPath, subject: 'Call Transcript');
          }
          break;

        case 'share':
          final summary = (widget.analysis['summary']['bullet_points'] as List)
              .map((p) => '• $p')
              .join('\n');
          final shareText = '''
Call Analysis Summary

Sentiment: ${widget.analysis['overall_sentiment']}
Confidence: ${(widget.analysis['confidence'] * 100).toStringAsFixed(0)}%

Key Points:
$summary

Generated by CallCraft
''';
          await _sharingService.shareText(shareText, subject: 'Call Analysis');
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to $action: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green;
      case 'needs_attention':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getSentimentIcon(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Icons.sentiment_satisfied;
      case 'needs_attention':
        return Icons.warning_amber_rounded;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _getSentimentDisplayText(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return 'Positive';
      case 'needs_attention':
        return 'Needs Attention';
      default:
        return 'Neutral';
    }
  }

  String _formatRiskFlag(String flag) {
    return flag.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
