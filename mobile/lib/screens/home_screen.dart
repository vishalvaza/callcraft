import 'package:flutter/material.dart';
import 'recording_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _callHistory = [
    {
      'id': '1',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'duration': 180,
      'sentiment': 'positive',
      'language': 'Gujarati',
    },
    {
      'id': '2',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'duration': 240,
      'sentiment': 'needs_attention',
      'language': 'Hindi',
    },
    {
      'id': '3',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'duration': 120,
      'sentiment': 'neutral',
      'language': 'Hinglish',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CallCraft'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Navigate to profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _callHistory.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _callHistory.length,
              itemBuilder: (context, index) {
                return _buildCallCard(_callHistory[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RecordingScreen()),
          );
        },
        icon: const Icon(Icons.mic),
        label: const Text('Record Call'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_callback,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No calls yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to record your first call',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCallCard(Map<String, dynamic> call) {
    final sentiment = call['sentiment'] as String;
    final sentimentColor = _getSentimentColor(sentiment);
    final sentimentIcon = _getSentimentIcon(sentiment);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sentimentColor.withOpacity(0.2),
          child: Icon(sentimentIcon, color: sentimentColor),
        ),
        title: Text(
          call['language'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatDateTime(call['date'] as DateTime),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          _formatDuration(call['duration'] as int),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        onTap: () {
          // TODO: Navigate to analysis screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening call ${call['id']}')),
          );
        },
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green;
      case 'needs_attention':
        return Colors.red;
      case 'neutral':
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
      case 'neutral':
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
