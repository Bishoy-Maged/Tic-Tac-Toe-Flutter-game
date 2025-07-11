// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:math';

enum GameDifficulty { easy, medium, hard }
enum GameMode { singlePlayer, twoPlayer }

class Player {
  static List<int> playerX = [];
  static List<int> playerO = [];
  
  static void reset() {
    playerX.clear();
    playerO.clear();
  }
}

class GameStats {
  int winsX = 0;
  int winsO = 0;
  int draws = 0;
  int totalGames = 0;
  
  double get winRateX => totalGames > 0 ? winsX / totalGames : 0;
  double get winRateO => totalGames > 0 ? winsO / totalGames : 0;
  double get drawRate => totalGames > 0 ? draws / totalGames : 0;
  
  void recordWin(String winner) {
    totalGames++;
    if (winner == 'X') {
      winsX++;
    } else if (winner == 'O') {
      winsO++;
    }
  }
  
  void recordDraw() {
    totalGames++;
    draws++;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'winsX': winsX,
      'winsO': winsO,
      'draws': draws,
      'totalGames': totalGames,
    };
  }
  
  void fromJson(Map<String, dynamic> json) {
    winsX = json['winsX'] ?? 0;
    winsO = json['winsO'] ?? 0;
    draws = json['draws'] ?? 0;
    totalGames = json['totalGames'] ?? 0;
  }
}

extension ContainsAll on List {
  bool containsAll(int x, int y, [z]) {
    if (z == null) {
      return contains(x) && contains(y);
    } else {
      return contains(x) && contains(y) && contains(z);
    }
  }
}

class Game {
  GameDifficulty difficulty = GameDifficulty.medium;
  GameMode gameMode = GameMode.singlePlayer;
  GameStats stats = GameStats();
  List<Map<String, dynamic>> gameHistory = [];
  
  // Winning combinations
  static const List<List<int>> winningCombinations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6], // Diagonals
  ];

  void playGame(int index, String activePlayer) {
    if (activePlayer == 'X') {
      Player.playerX.add(index);
    } else {
      Player.playerO.add(index);
    }
  }

  String checkWinner() {
    for (List<int> combination in winningCombinations) {
      if (Player.playerX.containsAll(combination[0], combination[1], combination[2])) {
        return 'X';
      }
      if (Player.playerO.containsAll(combination[0], combination[1], combination[2])) {
        return 'O';
      }
    }
    return '';
  }

  bool isDraw() {
    return Player.playerX.length + Player.playerO.length == 9;
  }

  List<int> getEmptyCells() {
    List<int> emptyCells = [];
    for (int i = 0; i < 9; i++) {
      if (!Player.playerX.contains(i) && !Player.playerO.contains(i)) {
        emptyCells.add(i);
      }
    }
    return emptyCells;
  }

  Future<void> autoPlay(String activePlayer) async {
    int index = _getAIMove(activePlayer);
    playGame(index, activePlayer);
  }

  int _getAIMove(String activePlayer) {
    List<int> emptyCells = getEmptyCells();
    if (emptyCells.isEmpty) return -1;

    switch (difficulty) {
      case GameDifficulty.easy:
        return _getEasyMove(emptyCells);
      case GameDifficulty.medium:
        return _getMediumMove(emptyCells, activePlayer);
      case GameDifficulty.hard:
        return _getHardMove(emptyCells, activePlayer);
    }
  }

  int _getEasyMove(List<int> emptyCells) {
    Random random = Random();
    return emptyCells[random.nextInt(emptyCells.length)];
  }

  int _getMediumMove(List<int> emptyCells, String activePlayer) {
    // 70% chance of making a smart move, 30% chance of random
    Random random = Random();
    if (random.nextDouble() < 0.7) {
      return _getSmartMove(emptyCells, activePlayer);
    } else {
      return _getEasyMove(emptyCells);
    }
  }

  int _getHardMove(List<int> emptyCells, String activePlayer) {
    return _getSmartMove(emptyCells, activePlayer);
  }

  int _getSmartMove(List<int> emptyCells, String activePlayer) {
    // First, try to win
    int winningMove = _findWinningMove(activePlayer, emptyCells);
    if (winningMove != -1) return winningMove;

    // Second, block opponent's winning move
    String opponent = activePlayer == 'X' ? 'O' : 'X';
    int blockingMove = _findWinningMove(opponent, emptyCells);
    if (blockingMove != -1) return blockingMove;

    // Third, take center if available
    if (emptyCells.contains(4)) return 4;

    // Fourth, take corners
    List<int> corners = [0, 2, 6, 8];
    List<int> availableCorners = corners.where((corner) => emptyCells.contains(corner)).toList();
    if (availableCorners.isNotEmpty) {
      Random random = Random();
      return availableCorners[random.nextInt(availableCorners.length)];
    }

    // Finally, take any available edge
    List<int> edges = [1, 3, 5, 7];
    List<int> availableEdges = edges.where((edge) => emptyCells.contains(edge)).toList();
    if (availableEdges.isNotEmpty) {
      Random random = Random();
      return availableEdges[random.nextInt(availableEdges.length)];
    }

    // Fallback to random
    return _getEasyMove(emptyCells);
  }

  int _findWinningMove(String player, List<int> emptyCells) {
    List<int> playerMoves = player == 'X' ? Player.playerX : Player.playerO;
    
    for (int cell in emptyCells) {
      List<int> testMoves = List.from(playerMoves)..add(cell);
      
      for (List<int> combination in winningCombinations) {
        if (testMoves.containsAll(combination[0], combination[1], combination[2])) {
          return cell;
        }
      }
    }
    return -1;
  }

  void resetGame() {
    Player.reset();
  }

  void recordGameResult(String winner) {
    if (winner.isNotEmpty) {
      stats.recordWin(winner);
      gameHistory.add({
        'winner': winner,
        'mode': gameMode.toString(),
        'difficulty': difficulty.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      stats.recordDraw();
      gameHistory.add({
        'winner': 'Draw',
        'mode': gameMode.toString(),
        'difficulty': difficulty.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void setDifficulty(GameDifficulty newDifficulty) {
    difficulty = newDifficulty;
  }

  void setGameMode(GameMode newMode) {
    gameMode = newMode;
  }
}
