import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String audioUrl = "https://codeskulptor-demos.commondatastorage.googleapis.com/descent/background%20music.mp3";
  
  StreamController<List<double>>? _frequencyStreamController;
  
  Future<void> loadAudio() async {
    await _audioPlayer.setUrl(audioUrl);
    _initializeVisualizer();
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<List<double>>? get frequencyStream => _frequencyStreamController?.stream;

  Duration? get duration => _audioPlayer.duration;

  Future<void> _initializeVisualizer() async {
    _frequencyStreamController = StreamController<List<double>>.broadcast();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_frequencyStreamController?.isClosed == false) {
        _frequencyStreamController?.add(_generateDummyFrequencies());
      }
    });
  }

  List<double> _generateDummyFrequencies() {
    final random = Random();
    return List.generate(50, (index) => random.nextDouble());
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _frequencyStreamController?.close();
  }
}