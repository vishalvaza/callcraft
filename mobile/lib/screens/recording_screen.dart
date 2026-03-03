import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/audio_service.dart';
import '../services/transcription_service.dart';
import '../services/api_service.dart';
import 'analysis_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final _audioService = AudioService();
  final _transcriptionService = TranscriptionService();
  final _apiService = ApiService();

  bool _isRecording = false;
  bool _isProcessing = false;
  int _recordingDuration = 0;
  Timer? _timer;
  String? _recordingPath;
  String _selectedLanguage = 'gu';
  double _transcriptionProgress = 0.0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final path = await _audioService.startRecording();
      if (path != null) {
        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _recordingDuration = 0;
        });

        // Start timer
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration++;
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      final path = await _audioService.stopRecording();

      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });

      if (path != null) {
        await _processRecording(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        await _processRecording(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processRecording(String audioPath) async {
    setState(() {
      _isProcessing = true;
      _transcriptionProgress = 0.0;
    });

    try {
      // Step 1: Transcribe audio
      final transcriptionResult =
          await _transcriptionService.transcribeAudio(
        audioPath: audioPath,
        language: _selectedLanguage,
        onProgress: (progress) {
          setState(() {
            _transcriptionProgress = progress * 0.5; // First 50%
          });
        },
      );

      setState(() {
        _transcriptionProgress = 0.5; // 50% done
      });

      // Step 2: Send to backend for analysis
      final fileSize = await _audioService.getFileSize(audioPath);
      final audioFormat = _audioService.getAudioFormat(audioPath);

      setState(() {
        _transcriptionProgress = 0.6; // 60% done
      });

      final analysisResult = await _apiService.analyzeTranscript(
        transcript: transcriptionResult.transcript,
        language: transcriptionResult.language,
        durationSeconds: transcriptionResult.duration,
        segments: transcriptionResult.segments,
        audioFormat: audioFormat,
        audioSizeBytes: fileSize,
        recordedAt: DateTime.now(),
      );

      setState(() {
        _transcriptionProgress = 1.0; // 100% done
      });

      // Navigate to analysis screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(
              analysis: analysisResult,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Processing failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Call'),
        actions: [
          if (_isRecording)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () async {
                await _audioService.cancelRecording();
                _timer?.cancel();
                setState(() {
                  _isRecording = false;
                  _recordingDuration = 0;
                });
              },
              tooltip: 'Cancel Recording',
            ),
        ],
      ),
      body: _isProcessing ? _buildProcessingView() : _buildRecordingView(),
    );
  }

  Widget _buildRecordingView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recording indicator
            GestureDetector(
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? Colors.red.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  boxShadow: _isRecording
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : Colors.grey[600],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Duration
            Text(
              _formatDuration(_recordingDuration),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _isRecording
                  ? 'Recording in progress...'
                  : 'Tap the microphone to start',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),

            // Control buttons
            if (!_isRecording) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Import button
                  OutlinedButton.icon(
                    onPressed: _importAudio,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Import Audio'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Record button
                  FilledButton.icon(
                    onPressed: _startRecording,
                    icon: const Icon(Icons.fiber_manual_record),
                    label: const Text('Start Recording'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Language selector
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Call Language',
                    prefixIcon: Icon(Icons.language),
                    helperText: 'Select the primary language of the call',
                  ),
                  value: _selectedLanguage,
                  items: const [
                    DropdownMenuItem(
                      value: 'gu',
                      child: Text('Gujarati (ગુજરાતી)'),
                    ),
                    DropdownMenuItem(
                      value: 'hi',
                      child: Text('Hindi (हिन्दी)'),
                    ),
                    DropdownMenuItem(
                      value: 'en-IN',
                      child: Text('Hinglish (Hindi-English Mix)'),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    final percentage = (_transcriptionProgress * 100).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 6,
            ),
            const SizedBox(height: 32),
            Text(
              'Processing Recording...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              _getProcessingMessage(percentage),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: _transcriptionProgress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage% complete',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProcessingMessage(int percentage) {
    if (percentage < 50) {
      return 'Transcribing audio...';
    } else if (percentage < 60) {
      return 'Preparing transcript...';
    } else if (percentage < 100) {
      return 'Analyzing with AI...';
    } else {
      return 'Almost done!';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
