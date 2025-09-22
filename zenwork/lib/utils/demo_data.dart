import '../models/focus_session.dart';
import '../models/task_type.dart';

/// Demo data for testing the app functionality
class DemoData {
  static List<FocusSession> generateDemoSessions() {
    final now = DateTime.now();
    
    return [
      FocusSession(
        id: '1',
        taskType: TaskType.coding,
        soundId: 'lofi',
        startTime: now.subtract(const Duration(days: 1, hours: 2)),
        endTime: now.subtract(const Duration(days: 1, hours: 1, minutes: 35)),
        plannedDurationMinutes: 25,
        actualDurationMinutes: 25,
        focusScore: 92,
      ),
      FocusSession(
        id: '2',
        taskType: TaskType.writing,
        soundId: 'rain',
        startTime: now.subtract(const Duration(days: 2, hours: 3)),
        endTime: now.subtract(const Duration(days: 2, hours: 2, minutes: 20)),
        plannedDurationMinutes: 45,
        actualDurationMinutes: 40,
        focusScore: 85,
      ),
      FocusSession(
        id: '3',
        taskType: TaskType.studying,
        soundId: 'piano',
        startTime: now.subtract(const Duration(days: 3, hours: 1)),
        endTime: now.subtract(const Duration(days: 3, minutes: 30)),
        plannedDurationMinutes: 30,
        actualDurationMinutes: 30,
        focusScore: 78,
      ),
      FocusSession(
        id: '4',
        taskType: TaskType.creative,
        soundId: 'nature',
        startTime: now.subtract(const Duration(days: 4, hours: 2)),
        endTime: now.subtract(const Duration(days: 4, hours: 1, minutes: 15)),
        plannedDurationMinutes: 60,
        actualDurationMinutes: 45,
        focusScore: 71,
      ),
      FocusSession(
        id: '5',
        taskType: TaskType.reading,
        soundId: 'ocean',
        startTime: now.subtract(const Duration(days: 5, hours: 1)),
        endTime: now.subtract(const Duration(days: 5, minutes: 35)),
        plannedDurationMinutes: 25,
        actualDurationMinutes: 25,
        focusScore: 88,
      ),
      FocusSession(
        id: '6',
        taskType: TaskType.coding,
        soundId: 'white_noise',
        startTime: now.subtract(const Duration(days: 6, hours: 3)),
        endTime: now.subtract(const Duration(days: 6, hours: 2, minutes: 10)),
        plannedDurationMinutes: 50,
        actualDurationMinutes: 50,
        focusScore: 95,
      ),
      FocusSession(
        id: '7',
        taskType: TaskType.other,
        soundId: 'cafe',
        startTime: now.subtract(const Duration(days: 7, hours: 1)),
        endTime: now.subtract(const Duration(days: 7, minutes: 40)),
        plannedDurationMinutes: 20,
        actualDurationMinutes: 20,
        focusScore: 82,
      ),
    ];
  }

  static void addDemoSessions() {
    // This would be called to populate the app with demo data
    // In a real app, you might want to add this as a debug option
  }
}