import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/focus_session.dart';
import '../models/task_type.dart';

/// Service for managing local data storage
class StorageService {
  static const String _sessionsBoxName = 'focus_sessions';
  static const String _lastTaskTypeKey = 'last_task_type';
  static const String _themeKey = 'theme_mode';
  static const String _defaultSoundKey = 'default_sound';
  static const String _soundVolumeKey = 'sound_volume';
  static const String _fadeEnabledKey = 'fade_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  static Box<FocusSession>? _sessionsBox;
  static SharedPreferences? _prefs;

  /// Initialize storage
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FocusSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskTypeAdapter());
    }

    _sessionsBox = await Hive.openBox<FocusSession>(_sessionsBoxName);
    _prefs = await SharedPreferences.getInstance();
    
    // Add demo data if no sessions exist (for testing)
    if (_sessionsBox?.isEmpty ?? true) {
      await _addDemoData();
    }
  }

  /// Add demo data for testing
  static Future<void> _addDemoData() async {
    final now = DateTime.now();
    
    final demoSessions = [
      FocusSession(
        id: 'demo_1',
        taskType: TaskType.coding,
        soundId: 'lofi',
        startTime: now.subtract(const Duration(days: 1, hours: 2)),
        endTime: now.subtract(const Duration(days: 1, hours: 1, minutes: 35)),
        plannedDurationMinutes: 25,
        actualDurationMinutes: 25,
        focusScore: 92,
      ),
      FocusSession(
        id: 'demo_2',
        taskType: TaskType.writing,
        soundId: 'rain',
        startTime: now.subtract(const Duration(days: 2, hours: 3)),
        endTime: now.subtract(const Duration(days: 2, hours: 2, minutes: 20)),
        plannedDurationMinutes: 45,
        actualDurationMinutes: 40,
        focusScore: 85,
      ),
      FocusSession(
        id: 'demo_3',
        taskType: TaskType.studying,
        soundId: 'piano',
        startTime: now.subtract(const Duration(days: 3, hours: 1)),
        endTime: now.subtract(const Duration(days: 3, minutes: 30)),
        plannedDurationMinutes: 30,
        actualDurationMinutes: 30,
        focusScore: 78,
      ),
      FocusSession(
        id: 'demo_4',
        taskType: TaskType.creative,
        soundId: 'nature',
        startTime: now.subtract(const Duration(days: 4, hours: 2)),
        endTime: now.subtract(const Duration(days: 4, hours: 1, minutes: 15)),
        plannedDurationMinutes: 60,
        actualDurationMinutes: 45,
        focusScore: 71,
      ),
      FocusSession(
        id: 'demo_5',
        taskType: TaskType.reading,
        soundId: 'ocean',
        startTime: now.subtract(const Duration(days: 5, hours: 1)),
        endTime: now.subtract(const Duration(days: 5, minutes: 35)),
        plannedDurationMinutes: 25,
        actualDurationMinutes: 25,
        focusScore: 88,
      ),
    ];

    for (final session in demoSessions) {
      await _sessionsBox?.put(session.id, session);
    }
  }

  /// Save a focus session
  static Future<void> saveFocusSession(FocusSession session) async {
    await _sessionsBox?.put(session.id, session);
  }

  /// Get all focus sessions
  static List<FocusSession> getAllSessions() {
    return _sessionsBox?.values.toList() ?? [];
  }

  /// Get recent sessions (last 30 days)
  static List<FocusSession> getRecentSessions() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return getAllSessions()
        .where((session) => session.startTime.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Get sessions for a specific date
  static List<FocusSession> getSessionsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getAllSessions()
        .where((session) => 
            session.startTime.isAfter(startOfDay) && 
            session.startTime.isBefore(endOfDay))
        .toList();
  }

  /// Save last used task type
  static Future<void> saveLastTaskType(String taskTypeName) async {
    await _prefs?.setString(_lastTaskTypeKey, taskTypeName);
  }

  /// Get last used task type
  static String? getLastTaskType() {
    return _prefs?.getString(_lastTaskTypeKey);
  }

  /// Save last used duration
  static Future<void> saveLastDuration(int duration) async {
    await _prefs?.setInt('last_duration', duration);
  }

  /// Get last used duration
  static int? getLastDuration() {
    return _prefs?.getInt('last_duration');
  }

  /// Save theme preference
  static Future<void> saveThemeMode(String themeMode) async {
    await _prefs?.setString(_themeKey, themeMode);
  }

  /// Get theme preference
  static String getThemeMode() {
    return _prefs?.getString(_themeKey) ?? 'system';
  }

  /// Save default sound preference
  static Future<void> saveDefaultSound(String soundId) async {
    await _prefs?.setString(_defaultSoundKey, soundId);
  }

  /// Get default sound preference
  static String? getDefaultSound() {
    return _prefs?.getString(_defaultSoundKey);
  }

  /// Volume persistence (0.0 - 1.0)
  static Future<void> saveSoundVolume(double volume) async {
    await _prefs?.setDouble(_soundVolumeKey, volume.clamp(0.0, 1.0));
  }

  static double getSoundVolume() {
    return _prefs?.getDouble(_soundVolumeKey) ?? 0.7;
  }

  /// Fade setting
  static Future<void> saveFadeEnabled(bool enabled) async {
    await _prefs?.setBool(_fadeEnabledKey, enabled);
  }

  static bool getFadeEnabled() {
    return _prefs?.getBool(_fadeEnabledKey) ?? true;
  }

  /// Notifications setting
  static Future<void> saveNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_notificationsEnabledKey, enabled);
  }

  static bool getNotificationsEnabled() {
    return _prefs?.getBool(_notificationsEnabledKey) ?? false;
  }

  /// Onboarding flag
  static Future<void> saveOnboardingCompleted(bool completed) async {
    await _prefs?.setBool(_onboardingCompletedKey, completed);
  }

  static bool getOnboardingCompleted() {
    return _prefs?.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Clear all data
  static Future<void> clearAllData() async {
    await _sessionsBox?.clear();
    await _prefs?.clear();
  }
}

/// Hive adapter for TaskType enum
class TaskTypeAdapter extends TypeAdapter<TaskType> {
  @override
  final int typeId = 1;

  @override
  TaskType read(BinaryReader reader) {
    final index = reader.readByte();
    return TaskType.values[index];
  }

  @override
  void write(BinaryWriter writer, TaskType obj) {
    writer.writeByte(obj.index);
  }
}