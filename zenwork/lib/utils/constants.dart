/// App constants and configuration
class AppConstants {
  // App info
  static const String appName = 'Zen Work';
  static const String appVersion = '1.0.0';
  
  // Timer durations (in minutes)
  static const List<int> timerDurations = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120];
  static const int defaultTimerDuration = 25;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Focus score thresholds
  static const int excellentScoreThreshold = 90;
  static const int greatScoreThreshold = 80;
  static const int goodScoreThreshold = 70;
  static const int fairScoreThreshold = 60;
  
  // Chart colors
  static const List<String> chartColors = [
    '#6366F1', // Indigo
    '#8B5CF6', // Purple
    '#10B981', // Emerald
    '#F59E0B', // Amber
    '#EF4444', // Red
    '#3B82F6', // Blue
  ];
  
  // Onboarding
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // Storage keys
  static const String themeKey = 'theme_mode';
  static const String lastTaskTypeKey = 'last_task_type';
  static const String defaultSoundKey = 'default_sound';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String soundVolumeKey = 'sound_volume';
}

/// Format duration to readable string
extension DurationExtension on Duration {
  String toReadableString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  String toTimerString() {
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Format DateTime to readable string
extension DateTimeExtension on DateTime {
  String toDateString() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }
  
  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  
  String toRelativeString() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}