import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseService {
  static Database? _database;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'callcraft.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Call records table
    await db.execute('''
      CREATE TABLE call_records (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        transcript TEXT NOT NULL,
        language TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        recorded_at TEXT NOT NULL,
        audio_path TEXT,
        audio_format TEXT,
        audio_size_bytes INTEGER,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Analysis table
    await db.execute('''
      CREATE TABLE analyses (
        id TEXT PRIMARY KEY,
        call_record_id TEXT NOT NULL,
        overall_sentiment TEXT NOT NULL,
        confidence REAL NOT NULL,
        risk_flags TEXT,
        summary_points TEXT NOT NULL,
        key_topics TEXT,
        reasoning TEXT,
        whatsapp_message TEXT,
        email_draft TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (call_record_id) REFERENCES call_records (id)
      )
    ''');

    // Pending analyses queue
    await db.execute('''
      CREATE TABLE pending_analyses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        call_record_id TEXT NOT NULL,
        transcript TEXT NOT NULL,
        language TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        segments TEXT,
        audio_format TEXT,
        audio_size_bytes INTEGER,
        recorded_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        FOREIGN KEY (call_record_id) REFERENCES call_records (id)
      )
    ''');

    // User cache
    await db.execute('''
      CREATE TABLE user_cache (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        full_name TEXT,
        subscription_tier TEXT NOT NULL,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // ==================== Call Records ====================

  Future<int> insertCallRecord(Map<String, dynamic> callRecord) async {
    final db = await database;
    return await db.insert('call_records', callRecord);
  }

  Future<Map<String, dynamic>?> getCallRecord(String id) async {
    final db = await database;
    final results = await db.query(
      'call_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllCallRecords({
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      'call_records',
      orderBy: 'recorded_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedCallRecords() async {
    final db = await database;
    return await db.query(
      'call_records',
      where: 'synced = 0',
    );
  }

  Future<int> updateCallRecordSyncStatus(String id, bool synced) async {
    final db = await database;
    return await db.update(
      'call_records',
      {'synced': synced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Analyses ====================

  Future<int> insertAnalysis(Map<String, dynamic> analysis) async {
    final db = await database;

    // Convert lists to JSON strings
    final data = Map<String, dynamic>.from(analysis);
    if (data['risk_flags'] is List) {
      data['risk_flags'] = jsonEncode(data['risk_flags']);
    }
    if (data['summary_points'] is List) {
      data['summary_points'] = jsonEncode(data['summary_points']);
    }
    if (data['key_topics'] is List) {
      data['key_topics'] = jsonEncode(data['key_topics']);
    }

    return await db.insert('analyses', data);
  }

  Future<Map<String, dynamic>?> getAnalysis(String callRecordId) async {
    final db = await database;
    final results = await db.query(
      'analyses',
      where: 'call_record_id = ?',
      whereArgs: [callRecordId],
    );

    if (results.isEmpty) return null;

    // Parse JSON strings back to lists
    final data = Map<String, dynamic>.from(results.first);
    if (data['risk_flags'] is String) {
      data['risk_flags'] = jsonDecode(data['risk_flags']);
    }
    if (data['summary_points'] is String) {
      data['summary_points'] = jsonDecode(data['summary_points']);
    }
    if (data['key_topics'] is String) {
      data['key_topics'] = jsonDecode(data['key_topics']);
    }

    return data;
  }

  // ==================== Pending Analyses ====================

  Future<int> addPendingAnalysis(Map<String, dynamic> request) async {
    final db = await database;

    // Convert lists to JSON strings
    final data = Map<String, dynamic>.from(request);
    if (data['segments'] is List) {
      data['segments'] = jsonEncode(data['segments']);
    }

    return await db.insert('pending_analyses', data);
  }

  Future<List<Map<String, dynamic>>> getPendingAnalyses() async {
    final db = await database;
    final results = await db.query(
      'pending_analyses',
      orderBy: 'created_at ASC',
    );

    // Parse JSON strings
    return results.map((row) {
      final data = Map<String, dynamic>.from(row);
      if (data['segments'] is String) {
        data['segments'] = jsonDecode(data['segments']);
      }
      return data;
    }).toList();
  }

  Future<int> deletePendingAnalysis(int id) async {
    final db = await database;
    return await db.delete(
      'pending_analyses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> incrementRetryCount(int id) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE pending_analyses SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  // ==================== User Cache ====================

  Future<int> cacheUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      'user_cache',
      {
        ...user,
        'data': jsonEncode(user),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCachedUser(String id) async {
    final db = await database;
    final results = await db.query(
      'user_cache',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;

    return jsonDecode(results.first['data'] as String);
  }

  // ==================== Sync Management ====================

  Future<Map<String, int>> getSyncStats() async {
    final db = await database;

    final unsyncedCalls = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM call_records WHERE synced = 0'),
    );

    final pendingAnalyses = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM pending_analyses'),
    );

    return {
      'unsynced_calls': unsyncedCalls ?? 0,
      'pending_analyses': pendingAnalyses ?? 0,
    };
  }

  // ==================== Database Management ====================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('call_records');
    await db.delete('analyses');
    await db.delete('pending_analyses');
    await db.delete('user_cache');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
