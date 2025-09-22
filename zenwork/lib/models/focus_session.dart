import 'package:hive/hive.dart';
import 'task_type.dart';

part 'focus_session.g.dart';

/// Represents a completed focus session
@HiveType(typeId: 0)
class FocusSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final TaskType taskType;

  @HiveField(2)
  final String soundId;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime endTime;

  @HiveField(5)
  final int plannedDurationMinutes;

  @HiveField(6)
  final int actualDurationMinutes;

  @HiveField(7)
  final int focusScore;

  @HiveField(8)
  final int interruptions;

  FocusSession({
    required this.id,
    required this.taskType,
    required this.soundId,
    required this.startTime,
    required this.endTime,
    required this.plannedDurationMinutes,
    required this.actualDurationMinutes,
    required this.focusScore,
    this.interruptions = 0,
  });

  /// Calculate focus score based on session completion and interruptions
  static int calculateFocusScore({
    required int plannedMinutes,
    required int actualMinutes,
    required int interruptions,
  }) {
    if (plannedMinutes == 0) return 0;
    
    // Base score from completion percentage (0-70 points)
    final completionRatio = (actualMinutes / plannedMinutes).clamp(0.0, 1.0);
    final completionScore = (completionRatio * 70).round();
    
    // Bonus for full completion (0-20 points)
    final completionBonus = actualMinutes >= plannedMinutes ? 20 : 0;
    
    // Penalty for interruptions (0-10 points deducted)
    final interruptionPenalty = (interruptions * 2).clamp(0, 10);
    
    final totalScore = (completionScore + completionBonus - interruptionPenalty).clamp(0, 100);
    return totalScore;
  }

  /// Get a descriptive label for the focus score
  String get focusScoreLabel {
    if (focusScore >= 90) return 'Excellent';
    if (focusScore >= 80) return 'Great';
    if (focusScore >= 70) return 'Good';
    if (focusScore >= 60) return 'Fair';
    return 'Needs Improvement';
  }
}