import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'game_logic.dart';

class SettingsPage extends StatefulWidget {
  final Game game;
  
  const SettingsPage({super.key, required this.game});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setBool('vibrationEnabled', vibrationEnabled);
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gameStats', jsonEncode(widget.game.stats.toJson()));
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('gameStats');
    if (statsJson != null) {
      final statsMap = jsonDecode(statsJson);
      widget.game.stats.fromJson(statsMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Game Settings',
                [
                  _buildDifficultySelector(),
                  _buildGameModeSelector(),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Preferences',
                [
                  _buildSwitchTile(
                    'Sound Effects',
                    'Enable sound effects during gameplay',
                    soundEnabled,
                    (value) {
                      setState(() {
                        soundEnabled = value;
                      });
                      _saveSettings();
                    },
                    Icons.volume_up,
                  ),
                  _buildSwitchTile(
                    'Vibration',
                    'Enable vibration feedback',
                    vibrationEnabled,
                    (value) {
                      setState(() {
                        vibrationEnabled = value;
                      });
                      _saveSettings();
                    },
                    Icons.vibration,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Statistics',
                [
                  _buildStatsCard(),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Data Management',
                [
                  _buildButton(
                    'Reset Statistics',
                    Icons.refresh,
                    () => _showResetDialog(),
                    Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildButton(
                    'Export Statistics',
                    Icons.download,
                    () => _exportStats(),
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return ListTile(
      title: const Text(
        'AI Difficulty',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _getDifficultyText(widget.game.difficulty),
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: () => _showDifficultyDialog(),
    );
  }

  Widget _buildGameModeSelector() {
    return ListTile(
      title: const Text(
        'Game Mode',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        widget.game.gameMode == GameMode.singlePlayer ? 'Single Player' : 'Two Player',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: () => _showGameModeDialog(),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatRow('Total Games', widget.game.stats.totalGames.toString()),
          _buildStatRow('X Wins', '${widget.game.stats.winsX} (${(widget.game.stats.winRateX * 100).toStringAsFixed(1)}%)'),
          _buildStatRow('O Wins', '${widget.game.stats.winsO} (${(widget.game.stats.winRateO * 100).toStringAsFixed(1)}%)'),
          _buildStatRow('Draws', '${widget.game.stats.draws} (${(widget.game.stats.drawRate * 100).toStringAsFixed(1)}%)'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String title, IconData icon, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _getDifficultyText(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Easy - Random moves';
      case GameDifficulty.medium:
        return 'Medium - Smart with randomness';
      case GameDifficulty.hard:
        return 'Hard - Unbeatable AI';
    }
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GameDifficulty.values.map((difficulty) {
            return ListTile(
              title: Text(_getDifficultyText(difficulty)),
              leading: Radio<GameDifficulty>(
                value: difficulty,
                groupValue: widget.game.difficulty,
                onChanged: (value) {
                  setState(() {
                    widget.game.setDifficulty(value!);
                  });
                  Navigator.pop(context);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showGameModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Game Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Single Player'),
              subtitle: const Text('Play against AI'),
              leading: Radio<GameMode>(
                value: GameMode.singlePlayer,
                groupValue: widget.game.gameMode,
                onChanged: (value) {
                  setState(() {
                    widget.game.setGameMode(value!);
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Two Player'),
              subtitle: const Text('Play with a friend'),
              leading: Radio<GameMode>(
                value: GameMode.twoPlayer,
                groupValue: widget.game.gameMode,
                onChanged: (value) {
                  setState(() {
                    widget.game.setGameMode(value!);
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text('Are you sure you want to reset all game statistics? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.game.stats = GameStats();
                widget.game.gameHistory.clear();
              });
              _saveStats();
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportStats() {
    // In a real app, you would implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statistics export feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
} 