import '../models/ambient_sound.dart';
import '../models/task_type.dart';
import 'storage_service.dart';

/// Service for recommending ambient sounds based on task type and user history
class RecommendationService {
  /// Get recommended sounds for a task type
  static List<AmbientSound> getRecommendedSounds(TaskType taskType) {
    // Get sounds specifically recommended for this task type
    final primaryRecommendations = AmbientSound.allSounds
        .where((sound) => sound.recommendedFor.contains(taskType))
        .toList();

    // Get user's historical preferences for this task type
    final userPreferences = _getUserPreferences(taskType);
    
    // Combine and sort recommendations
    final allRecommendations = <AmbientSound>[];
    
    // Add primary recommendations first
    allRecommendations.addAll(primaryRecommendations);
    
    // Add other sounds that user has used successfully
    for (final soundId in userPreferences) {
      final matching = AmbientSound.allSounds.where((s) => s.id == soundId);
      final sound = matching.isNotEmpty ? matching.first : null;
      if (sound != null && !allRecommendations.contains(sound)) {
        allRecommendations.add(sound);
      }
    }
    
    // Add remaining sounds
    for (final sound in AmbientSound.allSounds) {
      if (!allRecommendations.contains(sound)) {
        allRecommendations.add(sound);
      }
    }

    return allRecommendations;
  }

  /// Get the top recommended sound for a task type
  static AmbientSound getTopRecommendation(TaskType taskType) {
    final recommendations = getRecommendedSounds(taskType);
    return recommendations.isNotEmpty 
        ? recommendations.first 
        : AmbientSound.allSounds.first;
  }

  /// Get user's sound preferences based on successful sessions
  static List<String> _getUserPreferences(TaskType taskType) {
    final sessions = StorageService.getAllSessions()
        .where((session) => 
            session.taskType == taskType && 
            session.focusScore >= 70) // Only consider successful sessions
        .toList();

    // Count sound usage and sort by frequency
    final soundCounts = <String, int>{};
    for (final session in sessions) {
      soundCounts[session.soundId] = (soundCounts[session.soundId] ?? 0) + 1;
    }

    final sortedSounds = soundCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedSounds.map((entry) => entry.key).toList();
  }

  /// Get personalized recommendations based on overall user behavior
  static List<AmbientSound> getPersonalizedRecommendations() {
    final allSessions = StorageService.getAllSessions();
    
    if (allSessions.isEmpty) {
      return AmbientSound.allSounds;
    }

    // Calculate success rate for each sound
    final soundStats = <String, _SoundStats>{};
    
    for (final session in allSessions) {
      final stats = soundStats[session.soundId] ?? _SoundStats();
      stats.totalSessions++;
      if (session.focusScore >= 70) {
        stats.successfulSessions++;
      }
      stats.totalFocusScore += session.focusScore;
      soundStats[session.soundId] = stats;
    }

    // Sort sounds by success rate and average focus score
    final rankedSounds = soundStats.entries.map((entry) {
      final stats = entry.value;
      final successRate = stats.successfulSessions / stats.totalSessions;
      final avgFocusScore = stats.totalFocusScore / stats.totalSessions;
      final combinedScore = (successRate * 0.6) + (avgFocusScore / 100 * 0.4);
      
      return _RankedSound(entry.key, combinedScore);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // Return sounds in order of user success
    final result = <AmbientSound>[];
    
    // Add user's successful sounds first
    for (final rankedSound in rankedSounds) {
      final matching = AmbientSound.allSounds.where((s) => s.id == rankedSound.soundId);
      final sound = matching.isNotEmpty ? matching.first : null;
      if (sound != null) {
        result.add(sound);
      }
    }
    
    // Add remaining sounds
    for (final sound in AmbientSound.allSounds) {
      if (!result.contains(sound)) {
        result.add(sound);
      }
    }

    return result;
  }
}

class _SoundStats {
  int totalSessions = 0;
  int successfulSessions = 0;
  int totalFocusScore = 0;
}

class _RankedSound {
  final String soundId;
  final double score;
  
  _RankedSound(this.soundId, this.score);
}