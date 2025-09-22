import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/focus_session.dart';
import '../providers/app_providers.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_card.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Statistics screen showing detailed session analytics
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(focusSessionsProvider);
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Statistics'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: sessions.isEmpty
            ? _buildEmptyState(theme)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCards(sessions, theme),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildWeeklyChart(sessions, theme),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildTaskTypeDistribution(sessions, theme),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildFocusScoreDistribution(sessions, theme),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildProductivityInsights(sessions, theme),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha((0.3 * 255).round()),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No Statistics Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Complete some focus sessions to see your productivity insights.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha((0.5 * 255).round()),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(List<FocusSession> sessions, ThemeData theme) {
    final totalSessions = sessions.length;
    final totalMinutes = sessions.fold<int>(0, (sum, session) => sum + session.actualDurationMinutes);
    final averageScore = sessions.isEmpty 
        ? 0 
        : sessions.fold<int>(0, (sum, session) => sum + session.focusScore) / sessions.length;
    final streak = _calculateStreak(sessions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Total Sessions',
                totalSessions.toString(),
                Icons.timer_rounded,
                AppColors.primaryGradient,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                'Total Hours',
                '${(totalMinutes / 60).toStringAsFixed(1)}h',
                Icons.access_time_rounded,
                AppColors.secondaryGradient,
                theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Avg Score',
                averageScore.round().toString(),
                Icons.star_rounded,
                AppColors.accentGradient,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                'Current Streak',
                '$streak days',
                Icons.local_fire_department_rounded,
                [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradient,
    ThemeData theme,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withAlpha((0.3 * 255).round()),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: gradient,
            ).createShader(bounds),
            child: Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(List<FocusSession> sessions, ThemeData theme) {
    final weeklyData = _getWeeklyData(sessions);
    
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_view_week_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Activity',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: weeklyData.values.isEmpty ? 10 : weeklyData.values.reduce((a, b) => a > b ? a : b) + 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Text(
                          days[value.toInt()],
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklyData.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTypeDistribution(List<FocusSession> sessions, ThemeData theme) {
    final taskDistribution = _getTaskTypeDistribution(sessions);
    
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.secondaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Task Distribution',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (taskDistribution.isNotEmpty)
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: taskDistribution.entries.map((entry) {
                    final color = AppColors.getTaskTypeColor(entry.key);
                    return PieChartSectionData(
                      color: color,
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: taskDistribution.entries.map((entry) {
              final color = AppColors.getTaskTypeColor(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.key} (${entry.value})',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusScoreDistribution(List<FocusSession> sessions, ThemeData theme) {
    final scoreRanges = _getFocusScoreDistribution(sessions);
    
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Focus Score Distribution',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...scoreRanges.entries.map((entry) {
            final percentage = sessions.isEmpty ? 0.0 : (entry.value / sessions.length);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${entry.value} (${(percentage * 100).toStringAsFixed(1)}%)',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreRangeColor(entry.key),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductivityInsights(List<FocusSession> sessions, ThemeData theme) {
    final insights = _generateInsights(sessions);
    
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Productivity Insights',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Helper methods for data processing
  int _calculateStreak(List<FocusSession> sessions) {
    if (sessions.isEmpty) return 0;
    
    final sortedSessions = sessions.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (int i = 0; i < 30; i++) { // Check last 30 days
      final checkDate = currentDate.subtract(Duration(days: i));
      final hasSessionOnDate = sortedSessions.any((session) =>
          session.startTime.year == checkDate.year &&
          session.startTime.month == checkDate.month &&
          session.startTime.day == checkDate.day);
      
      if (hasSessionOnDate) {
        streak++;
      } else if (i > 0) { // Allow for today to not have a session yet
        break;
      }
    }
    
    return streak;
  }

  Map<int, int> _getWeeklyData(List<FocusSession> sessions) {
    final weeklyData = <int, int>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    for (final session in sessions) {
      final daysDiff = session.startTime.difference(weekStart).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        weeklyData[daysDiff] = (weeklyData[daysDiff] ?? 0) + 1;
      }
    }
    
    return weeklyData;
  }

  Map<String, int> _getTaskTypeDistribution(List<FocusSession> sessions) {
    final distribution = <String, int>{};
    for (final session in sessions) {
      final taskName = session.taskType.displayName;
      distribution[taskName] = (distribution[taskName] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _getFocusScoreDistribution(List<FocusSession> sessions) {
    final ranges = {
      'Excellent (90-100)': 0,
      'Great (80-89)': 0,
      'Good (70-79)': 0,
      'Fair (60-69)': 0,
      'Needs Improvement (0-59)': 0,
    };
    
    for (final session in sessions) {
      if (session.focusScore >= 90) {
        ranges['Excellent (90-100)'] = ranges['Excellent (90-100)']! + 1;
      } else if (session.focusScore >= 80) {
        ranges['Great (80-89)'] = ranges['Great (80-89)']! + 1;
      } else if (session.focusScore >= 70) {
        ranges['Good (70-79)'] = ranges['Good (70-79)']! + 1;
      } else if (session.focusScore >= 60) {
        ranges['Fair (60-69)'] = ranges['Fair (60-69)']! + 1;
      } else {
        ranges['Needs Improvement (0-59)'] = ranges['Needs Improvement (0-59)']! + 1;
      }
    }
    
    return ranges;
  }

  Color _getScoreRangeColor(String range) {
    if (range.contains('Excellent')) return const Color(0xFF10B981);
    if (range.contains('Great')) return const Color(0xFF3B82F6);
    if (range.contains('Good')) return const Color(0xFFF59E0B);
    if (range.contains('Fair')) return const Color(0xFFEF4444);
    return const Color(0xFF6B7280);
  }

  List<String> _generateInsights(List<FocusSession> sessions) {
    if (sessions.isEmpty) {
      return ['Start completing focus sessions to get personalized insights!'];
    }

    final insights = <String>[];
    
    // Most productive task type
    final taskDistribution = _getTaskTypeDistribution(sessions);
    if (taskDistribution.isNotEmpty) {
      final mostProductiveTask = taskDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add('Your most frequent task type is ${mostProductiveTask.key} with ${mostProductiveTask.value} sessions.');
    }
    
    // Average session length
    final avgDuration = sessions.fold<int>(0, (sum, session) => sum + session.actualDurationMinutes) / sessions.length;
    insights.add('Your average session length is ${avgDuration.toStringAsFixed(1)} minutes.');
    
    // Best performing task type
    final taskScores = <String, List<int>>{};
    for (final session in sessions) {
      final taskName = session.taskType.displayName;
      taskScores[taskName] = (taskScores[taskName] ?? [])..add(session.focusScore);
    }
    
    if (taskScores.isNotEmpty) {
      final bestTask = taskScores.entries
          .map((e) => MapEntry(e.key, e.value.reduce((a, b) => a + b) / e.value.length))
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add('You perform best during ${bestTask.key} sessions with an average score of ${bestTask.value.toStringAsFixed(1)}.');
    }
    
    // Improvement suggestion
    final recentSessions = sessions.take(5).toList();
    if (recentSessions.length >= 3) {
      final recentAvg = recentSessions.fold<int>(0, (sum, session) => sum + session.focusScore) / recentSessions.length;
      final overallAvg = sessions.fold<int>(0, (sum, session) => sum + session.focusScore) / sessions.length;
      
      if (recentAvg > overallAvg) {
        insights.add('Great progress! Your recent sessions are performing ${(recentAvg - overallAvg).toStringAsFixed(1)} points better than your overall average.');
      } else if (recentAvg < overallAvg - 5) {
        insights.add('Consider taking breaks between sessions or adjusting your environment to improve focus.');
      }
    }
    
    return insights;
  }
}