import 'dart:io';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentRecordingPath => _currentRecordingPath;

  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  /// Check and request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start recording audio
  Future<String?> startRecording() async {
    try {
      // Check permission
      if (!await requestPermission()) {
        throw Exception('Microphone permission denied');
      }

      // Check if already recording
      if (_isRecording) {
        throw Exception('Already recording');
      }

      // Get temporary directory
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${dir.path}/call_$timestamp.m4a';

      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _isRecording = true;
      _currentRecordingPath = path;

      return path;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        throw Exception('Not currently recording');
      }

      final path = await _recorder.stop();
      _isRecording = false;

      if (path == null) {
        throw Exception('Recording path is null');
      }

      // Verify file exists
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('Recording file not found');
      }

      return path;
    } catch (e) {
      _isRecording = false;
      throw Exception('Failed to stop recording: $e');
    }
  }

  /// Cancel recording without saving
  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;

      // Delete the file if it exists
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _currentRecordingPath = null;
    }
  }

  /// Play audio file
  Future<void> playAudio(String path) async {
    try {
      if (_isPlaying) {
        await stopPlayback();
      }

      await _player.setFilePath(path);
      await _player.play();
      _isPlaying = true;

      // Listen for completion
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
        }
      });
    } catch (e) {
      throw Exception('Failed to play audio: $e');
    }
  }

  /// Pause playback
  Future<void> pausePlayback() async {
    if (_isPlaying) {
      await _player.pause();
      _isPlaying = false;
    }
  }

  /// Resume playback
  Future<void> resumePlayback() async {
    if (!_isPlaying) {
      await _player.play();
      _isPlaying = true;
    }
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    await _player.stop();
    _isPlaying = false;
  }

  /// Get playback position
  Stream<Duration> get positionStream => _player.positionStream;

  /// Get playback duration
  Duration? get duration => _player.duration;

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Get file size in bytes
  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Get audio format from file path
  String getAudioFormat(String path) {
    final extension = path.split('.').last.toLowerCase();
    return extension;
  }

  /// Delete audio file
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
