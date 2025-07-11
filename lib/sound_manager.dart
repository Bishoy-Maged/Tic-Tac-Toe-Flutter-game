import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  AudioPlayer? _audioPlayer;
  bool _soundEnabled = true;

  Future<void> initialize() async {
    _audioPlayer = AudioPlayer();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _saveSettings();
  }

  bool get soundEnabled => _soundEnabled;

  Future<void> playMoveSound() async {
    if (!_soundEnabled) return;
    
    try {
      // For now, we'll use a simple beep sound
      // In a real app, you would have actual sound files
      await _audioPlayer?.play(AssetSource('sounds/move.mp3'));
    } catch (e) {
      // If sound file doesn't exist, we'll just continue
      if (kDebugMode) {
        debugPrint('Sound file not found: $e');
      }
    }
  }

  Future<void> playWinSound() async {
    if (!_soundEnabled) return;
    
    try {
      await _audioPlayer?.play(AssetSource('sounds/win.mp3'));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sound file not found: $e');
      }
    }
  }

  Future<void> playDrawSound() async {
    if (!_soundEnabled) return;
    
    try {
      await _audioPlayer?.play(AssetSource('sounds/draw.mp3'));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sound file not found: $e');
      }
    }
  }

  Future<void> playButtonSound() async {
    if (!_soundEnabled) return;
    
    try {
      await _audioPlayer?.play(AssetSource('sounds/button.mp3'));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sound file not found: $e');
      }
    }
  }

  void dispose() {
    _audioPlayer?.dispose();
  }
} 