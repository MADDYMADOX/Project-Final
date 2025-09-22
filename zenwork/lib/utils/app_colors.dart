import 'package:flutter/material.dart';

/// Premium app color scheme with modern gradients
class AppColors {
  // Primary colors - Deep Blue to Violet gradient
  static const Color primary = Color(0xFF667EEA); // Soft Blue
  static const Color primaryLight = Color(0xFF764BA2); // Violet
  static const Color primaryDark = Color(0xFF4C63D2); // Deep Blue
  static const Color primaryAccent = Color(0xFF9BB5FF); // Light Blue

  // Secondary colors - Aqua/Teal
  static const Color secondary = Color(0xFF06D6A0); // Aqua
  static const Color secondaryLight = Color(0xFF40E0D0); // Turquoise
  static const Color secondaryDark = Color(0xFF059669); // Dark Teal

  // Accent colors - Purple/Pink
  static const Color accent = Color(0xFFB794F6); // Soft Purple
  static const Color accentLight = Color(0xFFE879F9); // Pink
  static const Color accentDark = Color(0xFF9F7AEA); // Deep Purple

  // Neutral colors with glassmorphism support
  static const Color background = Color(0xFFF8FAFF); // Very light blue-white
  static const Color backgroundDark = Color(0xFF0A0E1A); // Deep navy
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1F2E); // Dark blue-grey
  static const Color surfaceVariant = Color(0xFFF0F4FF); // Light blue tint
  static const Color surfaceVariantDark = Color(0xFF252B3D); // Medium dark blue

  // Glass effect colors
  static const Color glassLight = Color(0x1AFFFFFF); // 10% white
  static const Color glassDark = Color(0x1A000000); // 10% black
  static const Color glassBlur = Color(0x40FFFFFF); // 25% white for blur

  // Text colors with better contrast
  static const Color textPrimary = Color(0xFF1A1D29); // Dark blue-grey
  static const Color textPrimaryDark = Color(0xFFF8FAFF); // Light blue-white
  static const Color textSecondary = Color(0xFF6B7280); // Medium grey
  static const Color textSecondaryDark = Color(0xFFB8BCC8); // Light grey
  static const Color textTertiary = Color(0xFF9CA3AF); // Light grey
  static const Color textTertiaryDark = Color(0xFF6B7280); // Medium grey

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Premium gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF667EEA), // Soft Blue
    Color(0xFF764BA2), // Violet
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF06D6A0), // Aqua
    Color(0xFF40E0D0), // Turquoise
  ];

  static const List<Color> accentGradient = [
    Color(0xFFB794F6), // Soft Purple
    Color(0xFFE879F9), // Pink
  ];

  // Background gradients with depth
  static const List<Color> backgroundGradient = [
    Color(0xFFF8FAFF), // Very light blue
    Color(0xFFE8F2FF), // Light blue
    Color(0xFFDDD6FE), // Light purple
  ];

  static const List<Color> backgroundGradientDark = [
    Color(0xFF0A0E1A), // Deep navy
    Color(0xFF1A1F2E), // Dark blue-grey
    Color(0xFF2D1B69), // Dark purple
  ];

  // Card gradients for glassmorphism
  static const List<Color> cardGradientLight = [
    Color(0x20FFFFFF), // 12% white
    Color(0x10FFFFFF), // 6% white
  ];

  static const List<Color> cardGradientDark = [
    Color(0x20FFFFFF), // 12% white
    Color(0x10FFFFFF), // 6% white
  ];

  // Focus score colors
  static Color getFocusScoreColor(int score) {
    if (score >= 90) return const Color(0xFF10B981); // Green
    if (score >= 80) return const Color(0xFF3B82F6); // Blue
    if (score >= 70) return const Color(0xFFF59E0B); // Amber
    if (score >= 60) return const Color(0xFFEF4444); // Red
    return const Color(0xFF6B7280); // Gray
  }

  // Task type colors with gradients
  static const Map<String, List<Color>> taskTypeGradients = {
    'Writing': [Color(0xFF8B5CF6), Color(0xFFB794F6)], // Purple gradient
    'Coding': [Color(0xFF667EEA), Color(0xFF764BA2)], // Blue-violet gradient
    'Studying': [Color(0xFF06D6A0), Color(0xFF40E0D0)], // Aqua gradient
    'Reading': [Color(0xFFF093FB), Color(0xFFF5576C)], // Pink gradient
    'Creative': [Color(0xFFFFD89B), Color(0xFF19547B)], // Orange-blue gradient
    'Other': [Color(0xFF9BB5FF), Color(0xFF6B7280)], // Blue-grey gradient
  };

  static const Map<String, Color> taskTypeColors = {
    'Writing': Color(0xFF8B5CF6), // Purple
    'Coding': Color(0xFF667EEA), // Blue
    'Studying': Color(0xFF06D6A0), // Aqua
    'Reading': Color(0xFFF093FB), // Pink
    'Creative': Color(0xFFFFD89B), // Orange
    'Other': Color(0xFF9BB5FF), // Light Blue
  };

  static Color getTaskTypeColor(String taskType) {
    return taskTypeColors[taskType] ?? const Color(0xFF9BB5FF);
  }

  static List<Color> getTaskTypeGradient(String taskType) {
    return taskTypeGradients[taskType] ?? [const Color(0xFF9BB5FF), const Color(0xFF6B7280)];
  }
}