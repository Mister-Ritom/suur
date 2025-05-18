import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  int _currentPos = 0;
  int get currentPos => _currentPos;
  int _duration = 0;
  int get duration => _duration;
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

  PlayerProvider() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _isPlaying = false;
        notifyListeners();
      }
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration.inSeconds;
      notifyListeners();
    });
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPos = position.inSeconds;
      notifyListeners();
    });
  }

  void play() {
    _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }
}
