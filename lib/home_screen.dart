import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'game_logic.dart';
import 'settings_page.dart';
import 'sound_manager.dart';
import 'game_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String activePlayer = 'X';
  bool gameOver = false;
  int turn = 0;
  String result = '';
  Game game = Game();
  late ConfettiController _confettiController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  SoundManager soundManager = SoundManager();
  List<int> winningLine = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
    soundManager.initialize();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeController.dispose();
    soundManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
              const Color(0xFF1a237e),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: MediaQuery.of(context).orientation == Orientation.portrait
                ? Column(
                    children: [
                      ..._buildHeader(),
                      Expanded(child: _buildGameBoard()),
                      ..._buildFooter(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ..._buildHeader(),
                            const SizedBox(height: 20),
                            ..._buildFooter(),
                          ],
                        ),
                      ),
                      Expanded(child: _buildGameBoard()),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeader() {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _showSettings(),
              icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            ),
            Column(
              children: [
                Text(
                  'Tic Tac Toe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    game.gameMode == GameMode.singlePlayer ? 'Single Player' : 'Two Player',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _showHistory(),
                  icon: const Icon(Icons.history, color: Colors.white, size: 28),
                ),
                IconButton(
                  onPressed: () => _showStats(),
                  icon: const Icon(Icons.bar_chart, color: Colors.white, size: 28),
                ),
              ],
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              'It\'s $activePlayer turn'.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerIndicator('X', Player.playerX.length),
                _buildPlayerIndicator('O', Player.playerO.length),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildPlayerIndicator(String player, int moves) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: activePlayer == player 
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activePlayer == player 
              ? Colors.white 
              : Colors.white.withValues(alpha: 0.3),
          width: activePlayer == player ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player,
            style: TextStyle(
              color: player == 'X' ? Colors.blue : Colors.pink,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($moves)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          GridView.count(
            padding: const EdgeInsets.all(8),
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 1.0,
            crossAxisCount: 3,
            children: List.generate(
              9,
              (index) => _buildGameCell(index),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCell(int index) {
    bool isWinningCell = winningLine.contains(index);
    bool isX = Player.playerX.contains(index);
    bool isO = Player.playerO.contains(index);
    bool isEmpty = !isX && !isO;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: gameOver ? null : () => _onTap(index),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isWinningCell
                  ? [Colors.yellow.withValues(alpha: 0.3), Colors.orange.withValues(alpha: 0.3)]
                  : [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWinningCell 
                  ? Colors.yellow 
                  : Colors.white.withValues(alpha: 0.2),
              width: isWinningCell ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AnimatedScale(
              scale: isEmpty ? 0.8 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                isX ? 'X' : isO ? 'O' : '',
                style: TextStyle(
                  color: isX ? Colors.blue : Colors.pink,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFooter() {
    return [
      if (result.isNotEmpty)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Text(
            result,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            'New Game',
            Icons.refresh,
            () => _resetGame(),
            Colors.green,
          ),
          _buildActionButton(
            'Settings',
            Icons.settings,
            () => _showSettings(),
            Colors.blue,
          ),
        ],
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
    );
  }

  void _onTap(int index) async {
    if ((Player.playerX.isEmpty || !Player.playerX.contains(index)) &&
        (Player.playerO.isEmpty || !Player.playerO.contains(index))) {
      
      // Add haptic feedback
      HapticFeedback.lightImpact();
      
      // Play move sound
      await soundManager.playMoveSound();
      
      game.playGame(index, activePlayer);
      _updateState();

      if (game.gameMode == GameMode.singlePlayer && !gameOver && turn != 9) {
        // Add delay for AI move
        await Future.delayed(const Duration(milliseconds: 500));
        await game.autoPlay(activePlayer);
        _updateState();
      }
    }
  }

  void _updateState() {
    setState(() {
      activePlayer = (activePlayer == 'X') ? 'O' : 'X';
      turn++;

      String winnerPlayer = game.checkWinner();

      if (winnerPlayer.isNotEmpty) {
        gameOver = true;
        result = '$winnerPlayer Wins! 🎉';
        winningLine = _getWinningLine(winnerPlayer);
        game.recordGameResult(winnerPlayer);
        _confettiController.play();
        soundManager.playWinSound();
        HapticFeedback.heavyImpact();
      } else if (!gameOver && game.isDraw()) {
        result = 'It\'s a Draw! 🤝';
        game.recordGameResult('');
        soundManager.playDrawSound();
        HapticFeedback.mediumImpact();
      }
    });
  }

  List<int> _getWinningLine(String player) {
    List<int> playerMoves = player == 'X' ? Player.playerX : Player.playerO;
    
    for (List<int> combination in Game.winningCombinations) {
      if (playerMoves.containsAll(combination[0], combination[1], combination[2])) {
        return List<int>.from(combination);
      }
    }
    return <int>[];
  }

  void _resetGame() {
    setState(() {
      game.resetGame();
      activePlayer = 'X';
      gameOver = false;
      turn = 0;
      result = '';
      winningLine = <int>[];
    });
    soundManager.playButtonSound();
    HapticFeedback.lightImpact();
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(game: game),
      ),
    );
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameHistoryPage(game: game),
      ),
    );
  }

  void _showStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total Games', game.stats.totalGames.toString()),
            _buildStatRow('X Wins', '${game.stats.winsX} (${(game.stats.winRateX * 100).toStringAsFixed(1)}%)'),
            _buildStatRow('O Wins', '${game.stats.winsO} (${(game.stats.winRateO * 100).toStringAsFixed(1)}%)'),
            _buildStatRow('Draws', '${game.stats.draws} (${(game.stats.drawRate * 100).toStringAsFixed(1)}%)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
