import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_service.dart';
import 'api_service.dart';

class SyncService {
  final _databaseService = DatabaseService();
  final _apiService = ApiService();
  final _connectivity = Connectivity();

  bool _isSyncing = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Singleton pattern
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  /// Initialize sync service and listen for connectivity changes
  void initialize() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        if (result != ConnectivityResult.none) {
          // Device is online, attempt sync
          syncPendingAnalyses();
        }
      },
    );
  }

  /// Dispose sync service
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Sync all pending analyses
  Future<SyncResult> syncPendingAnalyses() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
      );
    }

    _isSyncing = true;

    try {
      // Check connectivity
      if (!await isOnline()) {
        return SyncResult(
          success: false,
          message: 'Device is offline',
        );
      }

      // Get pending analyses
      final pending = await _databaseService.getPendingAnalyses();

      if (pending.isEmpty) {
        return SyncResult(
          success: true,
          message: 'No pending analyses',
          synced: 0,
        );
      }

      int successCount = 0;
      int failCount = 0;
      final errors = <String>[];

      for (final item in pending) {
        try {
          // Send to backend
          final result = await _apiService.analyzeTranscript(
            transcript: item['transcript'],
            language: item['language'],
            durationSeconds: item['duration_seconds'],
            audioFormat: item['audio_format'],
            audioSizeBytes: item['audio_size_bytes'],
            recordedAt: DateTime.parse(item['recorded_at']),
          );

          // Save analysis to database
          await _databaseService.insertAnalysis({
            'id': result['call_record_id'],
            'call_record_id': item['call_record_id'],
            'overall_sentiment': result['overall_sentiment'],
            'confidence': result['confidence'],
            'risk_flags': result['risk_flags'],
            'summary_points': result['summary']['bullet_points'],
            'key_topics': result['summary']['key_topics'],
            'reasoning': result['reasoning'],
            'created_at': DateTime.now().toIso8601String(),
            'synced': 1,
          });

          // Update call record sync status
          await _databaseService.updateCallRecordSyncStatus(
            item['call_record_id'],
            true,
          );

          // Delete from pending
          await _databaseService.deletePendingAnalysis(item['id']);

          successCount++;
        } catch (e) {
          failCount++;
          errors.add('Call ${item['call_record_id']}: $e');

          // Increment retry count
          await _databaseService.incrementRetryCount(item['id']);

          // Delete if max retries reached
          if (item['retry_count'] >= 3) {
            await _databaseService.deletePendingAnalysis(item['id']);
            errors.add('Max retries reached for ${item['call_record_id']}');
          }
        }
      }

      return SyncResult(
        success: failCount == 0,
        message: 'Synced $successCount, failed $failCount',
        synced: successCount,
        failed: failCount,
        errors: errors.isEmpty ? null : errors,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Get sync statistics
  Future<Map<String, int>> getSyncStats() async {
    return await _databaseService.getSyncStats();
  }

  /// Check if sync is in progress
  bool get isSyncing => _isSyncing;
}

class SyncResult {
  final bool success;
  final String message;
  final int synced;
  final int failed;
  final List<String>? errors;

  SyncResult({
    required this.success,
    required this.message,
    this.synced = 0,
    this.failed = 0,
    this.errors,
  });
}
