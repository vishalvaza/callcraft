import 'dart:io';
import 'dart:async';
import '../models/call_record.dart';

/// Transcription Service
///
/// NOTE: This is a mock implementation for testing.
/// In production, this would integrate with Whisper.cpp via FFI.
///
/// To implement real transcription:
/// 1. Add whisper_flutter package or create FFI bindings
/// 2. Download Whisper model (small/medium) on first run
/// 3. Process audio file through Whisper
/// 4. Return transcript with segments and timestamps
class TranscriptionService {
  bool _isTranscribing = false;

  bool get isTranscribing => _isTranscribing;

  // Singleton pattern
  static final TranscriptionService _instance =
      TranscriptionService._internal();
  factory TranscriptionService() => _instance;
  TranscriptionService._internal();

  /// Transcribe audio file
  ///
  /// Returns a transcript with segments.
  /// In production, this would use Whisper.cpp.
  Future<TranscriptionResult> transcribeAudio({
    required String audioPath,
    String language = 'gu', // gu, hi, en-IN, en
    void Function(double progress)? onProgress,
  }) async {
    try {
      _isTranscribing = true;

      // Verify file exists
      final file = File(audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: $audioPath');
      }

      // Get file size
      final fileSize = await file.length();

      // Simulate transcription progress
      // In production, this would be real Whisper processing
      await _simulateTranscription(onProgress);

      // Generate mock transcript based on language
      final transcript = _generateMockTranscript(language);
      final segments = _generateMockSegments(language);

      _isTranscribing = false;

      return TranscriptionResult(
        transcript: transcript,
        segments: segments,
        language: language,
        duration: _estimateDuration(fileSize),
        confidence: 0.92,
      );
    } catch (e) {
      _isTranscribing = false;
      throw Exception('Transcription failed: $e');
    }
  }

  /// Detect language from audio
  /// In production, this would use Whisper's language detection
  Future<String> detectLanguage(String audioPath) async {
    // Mock implementation - randomly detect Gujarati, Hindi, or Hinglish
    final languages = ['gu', 'hi', 'en-IN'];
    await Future.delayed(const Duration(seconds: 1));
    return languages[DateTime.now().millisecond % 3];
  }

  /// Cancel ongoing transcription
  void cancelTranscription() {
    _isTranscribing = false;
  }

  // ==================== Mock Helper Methods ====================

  Future<void> _simulateTranscription(
      void Function(double progress)? onProgress) async {
    // Simulate processing with progress updates
    for (int i = 0; i <= 100; i += 10) {
      if (!_isTranscribing) break;
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress?.call(i / 100);
    }
  }

  String _generateMockTranscript(String language) {
    switch (language) {
      case 'gu':
        return '''સેલ્સપર્સન: નમસ્તે! હું તમને કેવી રીતે મદદ કરી શકું?
ગ્રાહક: નમસ્તે, મને તમારા નવા ડાયમંડ કલેક્શન વિશે જાણવું છે.
સેલ્સપર્સન: ખૂબ સરસ! અમારો નવો કલેક્શન તાજેતરમાં જ આવ્યો છે. તમે કયા પ્રકારના ડિઝાઇનમાં રસ ધરાવો છો?
ગ્રાહક: મને સિંપલ અને એલિગન્ટ કંઈક જોઈએ છે. કિંમત શું રહેશે?
સેલ્સપર્સન: અમારી કિંમત ₹50,000 થી શરૂ થાય છે. હાલમાં 10% ડિસ્કાઉન્ટ પણ ચાલી રહ્યું છે.
ગ્રાહક: એ તો સારું છે. હું એક વખત શોરૂમમાં આવીને જોઈશ.
સેલ્સપર્સન: જરૂર, આવતીકાલે શું સમય સારો રહેશે?
ગ્રાહક: બપોરે 3 વાગ્યે આવી શકીશ.
સેલ્સપર્સન: પરફેક્ટ! મારું નામ રાજેશ છે. તમારો કોન્ટેક્ટ નંબર આપો, હું તમને રિમાઇન્ડર મોકલીશ.
ગ્રાહક: ખૂબ સરસ, મારો નંબર 98765 43210 છે.''';

      case 'hi':
        return '''सेल्सपर्सन: नमस्ते! मैं आपकी कैसे मदद कर सकता हूं?
ग्राहक: नमस्ते, मुझे आपके नए प्रोडक्ट के बारे में जानना है।
सेल्सपर्सन: बिल्कुल! हमारे पास बहुत अच्छे प्रोडक्ट्स हैं। आप क्या खरीदना चाहते हैं?
ग्राहक: मुझे दवाइयों का ऑर्डर देना है। क्या होम डिलीवरी मिलती है?
सेल्सपर्सन: जी हां, हम फ्री होम डिलीवरी करते हैं। कौन सी दवा चाहिए?
ग्राहक: पिछली बार तो डिलीवरी में बहुत देर हो गई थी।
सेल्सपर्सन: मुझे बहुत खेद है। इस बार मैं एक्सप्रेस डिलीवरी का इंतजाम करूंगा।
ग्राहक: ठीक है, मैं भरोसा करता हूं।
सेल्सपर्सन: आप कल ऑर्डर दे सकते हैं, 24 घंटे में मिल जाएगी।
ग्राहक: बहुत अच्छा, धन्यवाद।''';

      case 'en-IN':
      case 'en':
        return '''Salesperson: Hello! How can I help you today?
Customer: Hi, I want to know about your textile collection.
Salesperson: Sure! We have a great range. What type of fabric are you looking for?
Customer: I need cotton fabric for my business. Bulk order possible?
Salesperson: Yes, we do bulk orders. Minimum 1000 meters ke liye discount bhi milta hai.
Customer: What's the price per meter?
Salesperson: It starts from ₹150 per meter, but for bulk discount ke baad ₹120 ho jayega.
Customer: Thik hai, ek sample bhej sakte ho?
Salesperson: Of course! I'll send samples by tomorrow. Aapka address?
Customer: Main Surat mein hoon. WhatsApp pe details bhej deta hoon.
Salesperson: Perfect! Main aapko follow up karunga.''';

      default:
        return 'Mock transcript in English language.';
    }
  }

  List<TranscriptSegment> _generateMockSegments(String language) {
    // Generate mock segments with timestamps
    final lines = _generateMockTranscript(language).split('\n');
    final segments = <TranscriptSegment>[];

    double currentTime = 0.0;
    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      final duration = (line.length / 20).clamp(2.0, 8.0); // Mock duration
      segments.add(TranscriptSegment(
        text: line,
        start: currentTime,
        end: currentTime + duration,
      ));
      currentTime += duration + 0.5; // Add pause
    }

    return segments;
  }

  int _estimateDuration(int fileSize) {
    // Rough estimate: 1MB ≈ 1 minute of audio
    return (fileSize / (1024 * 1024) * 60).round();
  }
}

/// Transcription result
class TranscriptionResult {
  final String transcript;
  final List<TranscriptSegment> segments;
  final String language;
  final int duration; // in seconds
  final double confidence;

  TranscriptionResult({
    required this.transcript,
    required this.segments,
    required this.language,
    required this.duration,
    required this.confidence,
  });
}
