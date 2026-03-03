import 'package:json_annotation/json_annotation.dart';

part 'call_record.g.dart';

@JsonSerializable()
class CallRecord {
  final String id;
  final String userId;
  final int durationSeconds;
  final String language;
  final DateTime recordedAt;
  final String transcript;
  final List<TranscriptSegment>? segments;
  final String? audioFormat;
  final int? audioSizeBytes;
  final DateTime createdAt;
  final Analysis? analysis;

  CallRecord({
    required this.id,
    required this.userId,
    required this.durationSeconds,
    required this.language,
    required this.recordedAt,
    required this.transcript,
    this.segments,
    this.audioFormat,
    this.audioSizeBytes,
    required this.createdAt,
    this.analysis,
  });

  factory CallRecord.fromJson(Map<String, dynamic> json) =>
      _$CallRecordFromJson(json);

  Map<String, dynamic> toJson() => _$CallRecordToJson(this);

  String get languageName {
    switch (language) {
      case 'gu':
        return 'Gujarati';
      case 'hi':
        return 'Hindi';
      case 'en':
      case 'en-IN':
        return 'Hinglish';
      default:
        return language;
    }
  }

  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

@JsonSerializable()
class TranscriptSegment {
  final String text;
  final double start;
  final double end;

  TranscriptSegment({
    required this.text,
    required this.start,
    required this.end,
  });

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) =>
      _$TranscriptSegmentFromJson(json);

  Map<String, dynamic> toJson() => _$TranscriptSegmentToJson(this);
}

@JsonSerializable()
class Analysis {
  final String id;
  final String callRecordId;
  final String overallSentiment;
  final double confidence;
  final List<String> riskFlags;
  final String reasoning;
  final List<String> summaryPoints;
  final List<String> keyTopics;
  final String? whatsappMessage;
  final String? emailDraft;
  final DateTime createdAt;
  final int? processingTimeMs;

  Analysis({
    required this.id,
    required this.callRecordId,
    required this.overallSentiment,
    required this.confidence,
    required this.riskFlags,
    required this.reasoning,
    required this.summaryPoints,
    required this.keyTopics,
    this.whatsappMessage,
    this.emailDraft,
    required this.createdAt,
    this.processingTimeMs,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) =>
      _$AnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisToJson(this);

  String get sentimentDisplayText {
    switch (overallSentiment) {
      case 'positive':
        return 'Positive';
      case 'neutral':
        return 'Neutral';
      case 'needs_attention':
        return 'Needs Attention';
      default:
        return overallSentiment;
    }
  }
}
