import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../models/call_record.dart';

class ApiService {
  // Update this to your backend URL
  static const String baseUrl =
      kDebugMode ? 'http://localhost:8000' : 'https://api.callcraft.app';

  static const String apiV1 = '$baseUrl/api/v1';

  String? _accessToken;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Set access token after login
  void setAccessToken(String token) {
    _accessToken = token;
  }

  // Clear token on logout
  void clearAccessToken() {
    _accessToken = null;
  }

  // Get headers with auth
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // ==================== Authentication ====================

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$apiV1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      setAccessToken(authResponse.accessToken);
      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$apiV1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      setAccessToken(authResponse.accessToken);
      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }

  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$apiV1/auth/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user profile');
    }
  }

  // ==================== Analysis ====================

  Future<Map<String, dynamic>> analyzeTranscript({
    required String transcript,
    required String language,
    required int durationSeconds,
    List<TranscriptSegment>? segments,
    String? audioFormat,
    int? audioSizeBytes,
    DateTime? recordedAt,
  }) async {
    final body = {
      'transcript': transcript,
      'language': language,
      'duration_seconds': durationSeconds,
      if (segments != null)
        'segments': segments.map((s) => s.toJson()).toList(),
      if (audioFormat != null) 'audio_format': audioFormat,
      if (audioSizeBytes != null) 'audio_size_bytes': audioSizeBytes,
      if (recordedAt != null) 'recorded_at': recordedAt.toIso8601String(),
    };

    final response = await http.post(
      Uri.parse('$apiV1/analyze'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Analysis failed');
    }
  }

  Future<Map<String, dynamic>> getAnalysis(String callRecordId) async {
    final response = await http.get(
      Uri.parse('$apiV1/analyze/$callRecordId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get analysis');
    }
  }

  // ==================== Content Generation ====================

  Future<String> generateWhatsAppMessage({
    required String callRecordId,
    String? customInstructions,
  }) async {
    final body = {
      'call_record_id': callRecordId,
      if (customInstructions != null)
        'custom_instructions': customInstructions,
    };

    final response = await http.post(
      Uri.parse('$apiV1/analyze/generate/whatsapp'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'];
    } else {
      throw Exception('Failed to generate WhatsApp message');
    }
  }

  Future<String> generateEmailDraft({
    required String callRecordId,
    String? customInstructions,
  }) async {
    final body = {
      'call_record_id': callRecordId,
      if (customInstructions != null)
        'custom_instructions': customInstructions,
    };

    final response = await http.post(
      Uri.parse('$apiV1/analyze/generate/email'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'];
    } else {
      throw Exception('Failed to generate email draft');
    }
  }

  // ==================== Health Check ====================

  Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
