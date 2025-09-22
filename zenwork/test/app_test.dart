import 'package:flutter_test/flutter_test.dart';
import 'package:zenwork/models/task_type.dart';
import 'package:zenwork/models/ambient_sound.dart';
import 'package:zenwork/models/focus_session.dart';

void main() {
  group('Zen Work Model Tests', () {

    test('TaskType enum has all expected values', () {
      expect(TaskType.values.length, equals(6));
      expect(TaskType.values, contains(TaskType.writing));
      expect(TaskType.values, contains(TaskType.coding));
      expect(TaskType.values, contains(TaskType.studying));
      expect(TaskType.values, contains(TaskType.reading));
      expect(TaskType.values, contains(TaskType.creative));
      expect(TaskType.values, contains(TaskType.other));
    });

    test('AmbientSound has all expected sounds', () {
      expect(AmbientSound.allSounds.length, equals(10));
      
      final soundIds = AmbientSound.allSounds.map((s) => s.id).toList();
      expect(soundIds, contains('rain'));
      expect(soundIds, contains('lofi'));
      expect(soundIds, contains('piano'));
      expect(soundIds, contains('nature'));
      expect(soundIds, contains('white_noise'));
      expect(soundIds, contains('ocean'));
      expect(soundIds, contains('forest'));
      expect(soundIds, contains('cafe'));
      expect(soundIds, contains('thunder'));
      expect(soundIds, contains('bells'));
    });

    test('Focus score calculation works correctly', () {
      // Test perfect completion
      final perfectScore = FocusSession.calculateFocusScore(
        plannedMinutes: 25,
        actualMinutes: 25,
        interruptions: 0,
      );
      expect(perfectScore, equals(90)); // 70 + 20 + 0

      // Test partial completion
      final partialScore = FocusSession.calculateFocusScore(
        plannedMinutes: 25,
        actualMinutes: 20,
        interruptions: 1,
      );
      expect(partialScore, equals(54)); // 56 + 0 - 2

      // Test over-completion
      final overScore = FocusSession.calculateFocusScore(
        plannedMinutes: 25,
        actualMinutes: 30,
        interruptions: 0,
      );
      expect(overScore, equals(90)); // 70 + 20 + 0 (clamped)
    });
  });
}