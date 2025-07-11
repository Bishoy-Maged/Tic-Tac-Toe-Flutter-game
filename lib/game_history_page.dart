import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'game_logic.dart';

class GameHistoryPage extends StatelessWidget {
  final Game game;
  
  const GameHistoryPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text(
          'Game History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: game.gameHistory.isEmpty
            ? _buildEmptyState()
            : _buildHistoryList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No games played yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start playing to see your game history!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: game.gameHistory.length,
      itemBuilder: (context, index) {
        final gameRecord = game.gameHistory[game.gameHistory.length - 1 - index];
        return _buildHistoryItem(gameRecord, index);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> gameRecord, int index) {
    final winner = gameRecord['winner'] as String;
    final mode = gameRecord['mode'] as String;
    final difficulty = gameRecord['difficulty'] as String;
    final timestamp = DateTime.parse(gameRecord['timestamp'] as String);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getResultColor(winner),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            _getResultIcon(winner),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          winner == 'Draw' ? 'Draw Game' : '$winner Wins!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${_formatMode(mode)} • ${_formatDifficulty(difficulty)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(timestamp),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#${game.gameHistory.length - index}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getResultColor(String winner) {
    switch (winner) {
      case 'X':
        return Colors.blue;
      case 'O':
        return Colors.pink;
      case 'Draw':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getResultIcon(String winner) {
    switch (winner) {
      case 'X':
        return Icons.close;
      case 'O':
        return Icons.circle_outlined;
      case 'Draw':
        return Icons.remove;
      default:
        return Icons.help_outline;
    }
  }

  String _formatMode(String mode) {
    return mode.contains('singlePlayer') ? 'Single Player' : 'Two Player';
  }

  String _formatDifficulty(String difficulty) {
    switch (difficulty) {
      case 'GameDifficulty.easy':
        return 'Easy';
      case 'GameDifficulty.medium':
        return 'Medium';
      case 'GameDifficulty.hard':
        return 'Hard';
      default:
        return 'Unknown';
    }
  }
} 