import 'task_type.dart';

/// Represents an ambient sound track
class AmbientSound {
  final String id;
  final String name;
  final String description;
  final String assetPath;
  final List<TaskType> recommendedFor;

  const AmbientSound({
    required this.id,
    required this.name,
    required this.description,
    required this.assetPath,
    required this.recommendedFor,
  });

  static const List<AmbientSound> allSounds = [
    AmbientSound(
      id: 'rain',
      name: 'Rain Sounds',
      description: 'Gentle rainfall for deep focus',
      assetPath: 'assets/audio/rain.mp3',
      recommendedFor: [TaskType.writing, TaskType.reading],
    ),
    AmbientSound(
      id: 'lofi',
      name: 'Lo-fi Beats',
      description: 'Chill beats for coding sessions',
      assetPath: 'assets/audio/lofi_beats.mp3',
      recommendedFor: [TaskType.coding, TaskType.creative],
    ),
    AmbientSound(
      id: 'piano',
      name: 'Soft Piano',
      description: 'Peaceful piano melodies',
      assetPath: 'assets/audio/soft_piano.mp3',
      recommendedFor: [TaskType.studying, TaskType.reading],
    ),
    AmbientSound(
      id: 'nature',
      name: 'Nature Sounds',
      description: 'Birds and forest ambience',
      assetPath: 'assets/audio/nature_sounds.mp3',
      recommendedFor: [TaskType.creative, TaskType.other],
    ),
    AmbientSound(
      id: 'white_noise',
      name: 'White Noise',
      description: 'Pure white noise for concentration',
      assetPath: 'assets/audio/white_noise.mp3',
      recommendedFor: [TaskType.studying, TaskType.coding],
    ),
    AmbientSound(
      id: 'ocean',
      name: 'Ocean Waves',
      description: 'Calming ocean waves',
      assetPath: 'assets/audio/ocean_waves.mp3',
      recommendedFor: [TaskType.writing, TaskType.other],
    ),
    AmbientSound(
      id: 'forest',
      name: 'Forest Ambience',
      description: 'Deep forest sounds',
      assetPath: 'assets/audio/forest_ambience.mp3',
      recommendedFor: [TaskType.creative, TaskType.reading],
    ),
    AmbientSound(
      id: 'cafe',
      name: 'Cafe Ambience',
      description: 'Coffee shop atmosphere',
      assetPath: 'assets/audio/cafe_ambience.mp3',
      recommendedFor: [TaskType.writing, TaskType.studying],
    ),
    AmbientSound(
      id: 'thunder',
      name: 'Thunderstorm',
      description: 'Distant thunder and rain',
      assetPath: 'assets/audio/thunderstorm.mp3',
      recommendedFor: [TaskType.coding, TaskType.writing],
    ),
    AmbientSound(
      id: 'bells',
      name: 'Meditation Bells',
      description: 'Gentle meditation bells',
      assetPath: 'assets/audio/meditation_bells.mp3',
      recommendedFor: [TaskType.other, TaskType.creative],
    ),
  ];
}