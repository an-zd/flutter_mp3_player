import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/audio_service.dart';
import 'package:just_audio/just_audio.dart';

abstract class AudioEvent {}

class LoadAudio extends AudioEvent {}
class PlayAudio extends AudioEvent {}
class PauseAudio extends AudioEvent {}
class UpdateProgress extends AudioEvent {
  final double progress;
  UpdateProgress(this.progress);
}
class UpdateFrequencies extends AudioEvent {
  final List<double> frequencies;
  UpdateFrequencies(this.frequencies);
}
class UpdateDuration extends AudioEvent {
  final Duration duration;
  UpdateDuration(this.duration);
}
class AudioCompleted extends AudioEvent {}

abstract class AudioState {
  final double progress;
  final List<double> frequencies;
  final Duration? duration;
  AudioState({required this.progress, required this.frequencies, this.duration});
}

class AudioInitial extends AudioState {
  AudioInitial() : super(progress: 0, frequencies: []);
}

class AudioLoading extends AudioState {
  AudioLoading() : super(progress: 0, frequencies: []);
}

class AudioReady extends AudioState {
  AudioReady({required double progress, required List<double> frequencies, Duration? duration}) 
    : super(progress: progress, frequencies: frequencies, duration: duration);
}

class AudioPlaying extends AudioState {
  AudioPlaying({required double progress, required List<double> frequencies, Duration? duration}) 
    : super(progress: progress, frequencies: frequencies, duration: duration);
}

class AudioPaused extends AudioState {
  AudioPaused({required double progress, required List<double> frequencies, Duration? duration}) 
    : super(progress: progress, frequencies: frequencies, duration: duration);
}

class AudioError extends AudioState {
  final String message;
  AudioError(this.message) : super(progress: 0, frequencies: []);
}

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioService _audioService;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _frequencySubscription;

  AudioBloc(this._audioService) : super(AudioInitial()) {
    on<LoadAudio>(_onLoadAudio);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<UpdateProgress>(_onUpdateProgress);
    on<UpdateFrequencies>(_onUpdateFrequencies);
    on<UpdateDuration>(_onUpdateDuration);
    on<AudioCompleted>(_onAudioCompleted);
  }

  void _onLoadAudio(LoadAudio event, Emitter<AudioState> emit) async {
    emit(AudioLoading());
    try {
      await _audioService.loadAudio();
      _initStreams();
      emit(AudioReady(progress: 0, frequencies: [], duration: _audioService.duration));
    } catch (e) {
      emit(AudioError('Failed to load audio: $e'));
    }
  }

  void _onPlayAudio(PlayAudio event, Emitter<AudioState> emit) {
    _audioService.play();
    emit(AudioPlaying(progress: state.progress, frequencies: state.frequencies, duration: state.duration));
  }

  void _onPauseAudio(PauseAudio event, Emitter<AudioState> emit) {
    _audioService.pause();
    emit(AudioPaused(progress: state.progress, frequencies: state.frequencies, duration: state.duration));
  }

  void _onUpdateProgress(UpdateProgress event, Emitter<AudioState> emit) {
    if (state is AudioPlaying) {
      emit(AudioPlaying(progress: event.progress, frequencies: state.frequencies, duration: state.duration));
    } else if (state is AudioPaused) {
      emit(AudioPaused(progress: event.progress, frequencies: state.frequencies, duration: state.duration));
    }
  }

  void _onUpdateFrequencies(UpdateFrequencies event, Emitter<AudioState> emit) {
    if (state is AudioPlaying) {
      emit(AudioPlaying(progress: state.progress, frequencies: event.frequencies, duration: state.duration));
    } else if (state is AudioPaused) {
      emit(AudioPaused(progress: state.progress, frequencies: event.frequencies, duration: state.duration));
    }
  }

  void _onUpdateDuration(UpdateDuration event, Emitter<AudioState> emit) {
    if (state is AudioPlaying) {
      emit(AudioPlaying(progress: state.progress, frequencies: state.frequencies, duration: event.duration));
    } else if (state is AudioPaused) {
      emit(AudioPaused(progress: state.progress, frequencies: state.frequencies, duration: event.duration));
    } else if (state is AudioReady) {
      emit(AudioReady(progress: state.progress, frequencies: state.frequencies, duration: event.duration));
    }
  }

  void _onAudioCompleted(AudioCompleted event, Emitter<AudioState> emit) {
    _audioService.pause();
    emit(AudioPaused(progress: 1, frequencies: state.frequencies, duration: state.duration));
  }

  void _initStreams() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = _audioService.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        add(AudioCompleted());
      } else if (playerState.playing) {
        add(PlayAudio());
      } else {
        add(PauseAudio());
      }
    });

    _positionSubscription?.cancel();
    _positionSubscription = _audioService.positionStream.listen((position) {
      if (_audioService.duration != null) {
        final progress = position.inMilliseconds / _audioService.duration!.inMilliseconds;
        add(UpdateProgress(progress));
      }
    });

    _durationSubscription?.cancel();
    _durationSubscription = _audioService.durationStream.listen((duration) {
      if (duration != null) {
        add(UpdateDuration(duration));
      }
    });

    _frequencySubscription?.cancel();
    _frequencySubscription = _audioService.frequencyStream?.listen((frequencies) {
      add(UpdateFrequencies(frequencies));
    });
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _frequencySubscription?.cancel();
    _audioService.dispose();
    return super.close();
  }
}