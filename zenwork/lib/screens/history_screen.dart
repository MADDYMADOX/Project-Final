import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/focus_session.dart';
import '../providers/app_providers.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_card.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Screen showing session history and statistics
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(focusSessionsProvider);
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Focus History'),
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
                    _buildStatsCards(sessions, theme),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildFocusScoreChart(sessions, theme),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildRecentSessions(sessions, theme),
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
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha((0.3 * 255).round()),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No Focus Sessions Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Start your first focus session to see your progress here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha((0.5 * 255).round()),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<FocusSession> sessions, ThemeData theme) {
    final totalSessions = sessions.length;
    final totalMinutes = sessions.fold<int>(0, (sum, session) => sum + session.actualDurationMinutes);
    final averageScore = sessions.isEmpty 
        ? 0 
        : sessions.fold<int>(0, (sum, session) => sum + session.focusScore) / sessions.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Sessions',
            totalSessions.toString(),
            Icons.timer_rounded,
            AppColors.primaryGradient,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Time',
            '${(totalMinutes / 60).toStringAsFixed(1)}h',
            Icons.access_time_rounded,
            AppColors.secondaryGradient,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Score',
            averageScore.round().toString(),
            Icons.star_rounded,
            AppColors.accentGradient,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
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

  Widget _buildFocusScoreChart(List<FocusSession> sessions, ThemeData theme) {
    if (sessions.length < 2) return const SizedBox.shrink();

    final recentSessions = sessions.take(10).toList().reversed.toList();
    
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
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Focus Score Trend',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outline.withAlpha((0.1 * 255).round()),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: recentSessions.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.focusScore.toDouble());
                    }).toList(),
                    isCurved: true,
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: AppColors.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withAlpha((0.2 * 255).round()),
                          AppColors.primary.withAlpha((0.05 * 255).round()),
                        ],
                      ),
                    ),
                    shadow: Shadow(
                      color: AppColors.primary.withAlpha((0.3 * 255).round()),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ),
                ],
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(List<FocusSession> sessions, ThemeData theme) {
    final recentSessions = sessions.take(10).toList();

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
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Sessions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentSessions.length,
            separatorBuilder: (context, index) => Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            itemBuilder: (context, index) {
              final session = recentSessions[index];
              return _buildSessionTile(session, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(FocusSession session, ThemeData theme) {
    final scoreColor = AppColors.getFocusScoreColor(session.focusScore);
    final taskGradient = AppColors.getTaskTypeGradient(session.taskType.displayName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            taskGradient.first.withAlpha((0.05 * 255).round()),
            taskGradient.last.withAlpha((0.02 * 255).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: taskGradient.first.withAlpha((0.1 * 255).round()),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: taskGradient),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: taskGradient.first.withAlpha((0.3 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getTaskIcon(session.taskType.displayName),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.taskType.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${session.actualDurationMinutes}min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session.startTime.toRelativeString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scoreColor.withAlpha((0.2 * 255).round()),
                  scoreColor.withAlpha((0.1 * 255).round()),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scoreColor.withAlpha((0.3 * 255).round()),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${session.focusScore}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Score',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scoreColor.withAlpha((0.8 * 255).round()),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTaskIcon(String taskType) {
    switch (taskType) {
      case 'Writing':
        return Icons.edit_outlined;
      case 'Coding':
        return Icons.code_outlined;
      case 'Studying':
        return Icons.school_outlined;
      case 'Reading':
        return Icons.menu_book_outlined;
      case 'Creative':
        return Icons.palette_outlined;
      case 'Other':
        return Icons.work_outline;
      default:
        return Icons.work_outline;
    }
  }
}