import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ambient_sound.dart';
import 'storage_service.dart';

/// Simple, reliable audio state
class AudioState {
  final AmbientSound? currentSound;
  final bool isPlaying;
  final bool isLoading;
  final double volume;
  final Duration position;
  final Duration duration;
  final bool fadeEnabled;

  const AudioState({
    this.currentSound,
    this.isPlaying = false,
    this.isLoading = false,
    this.volume = 0.7,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.fadeEnabled = true,
  });

  AudioState copyWith({
    AmbientSound? currentSound,
    bool? isPlaying,
    bool? isLoading,
    double? volume,
    Duration? position,
    Duration? duration,
    bool? fadeEnabled,
  }) {
    return AudioState(
      currentSound: currentSound ?? this.currentSound,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      volume: volume ?? this.volume,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      fadeEnabled: fadeEnabled ?? this.fadeEnabled,
    );
  }
}

/// Simple, bulletproof audio service using audioplayers
class AudioService extends StateNotifier<AudioState> {
  AudioService() : super(const AudioState()) {
    _initialize();
  }

  AudioPlayer? _player;

  void _initialize() {
    debugPrint('🎵 Initializing audio service with audioplayers...');
    _player = AudioPlayer();
    
    // Listen to player state
    _player!.onPlayerStateChanged.listen((playerState) {
      debugPrint('🎵 Player state: $playerState');
      final isPlaying = playerState == PlayerState.playing;
      state = state.copyWith(isPlaying: isPlaying);
    });

    // Listen to position
    _player!.onPositionChanged.listen((position) {
      state = state.copyWith(position: position);
    });

    // Listen to duration
    _player!.onDurationChanged.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    // Listen to completion
    _player!.onPlayerComplete.listen((event) {
      debugPrint('🎵 Audio completed');
      if (state.currentSound != null) {
        // Restart if we have a current sound (for looping)
        _player!.resume();
      }
    });

    debugPrint('🎵 Audio service initialized successfully');
  }

  /// Play a sound - SIMPLE VERSION
  Future<void> playSound(AmbientSound sound) async {
    debugPrint('🎵 PLAYING: ${sound.name}');
    
    try {
      state = state.copyWith(isLoading: true);
      
      // Stop current audio
      await _player?.stop();
      
      // Update state
      state = state.copyWith(
        currentSound: sound,
        isLoading: false,
      );
      
      // Play the sound
      debugPrint('📁 Loading: ${sound.assetPath}');
      await _player!.play(AssetSource('audio/${sound.assetPath.split('/').last}'));
      
      // Set volume
      await _player!.setVolume(state.volume);
      
      debugPrint('🎉 Audio should be playing now!');
      
    } catch (e) {
      debugPrint('❌ ERROR playing audio: $e');
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        currentSound: null,
      );
    }
  }

  /// Pause audio
  Future<void> pause() async {
    debugPrint('⏸️ Pausing audio');
    await _player?.pause();
  }

  /// Resume audio
  Future<void> resume() async {
    debugPrint('▶️ Resuming audio');
    await _player?.resume();
  }

  /// Stop audio
  Future<void> stop() async {
    debugPrint('⏹️ Stopping audio');
    await _player?.stop();
    state = state.copyWith(
      currentSound: null,
      isPlaying: false,
      position: Duration.zero,
    );
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    await _player?.setVolume(clampedVolume);
    state = state.copyWith(volume: clampedVolume);
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Set fade enabled
  Future<void> setFadeEnabled(bool enabled) async {
    state = state.copyWith(fadeEnabled: enabled);
    await StorageService.saveFadeEnabled(enabled);
  }

  /// Test if audio works - SIMPLE TEST
  Future<void> testAudio() async {
    debugPrint('🧪 Testing audio system...');
    
    try {
      final rainSound = AmbientSound.allSounds.first;
      debugPrint('🎵 Testing with: ${rainSound.name}');
      
      await _player!.play(AssetSource('audio/rain.mp3'));
      await Future.delayed(const Duration(seconds: 2));
      
      final isPlaying = _player!.state == PlayerState.playing;
      debugPrint('🎵 Playing: $isPlaying');
      
      await _player!.stop();
      
      if (isPlaying) {
        debugPrint('🎉 AUDIO SYSTEM WORKS!');
      } else {
        debugPrint('❌ Audio system has issues');
      }
      
    } catch (e) {
      debugPrint('❌ Test failed: $e');
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}