import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/storage_service.dart';
import '../widgets/gradient_background.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Settings screen for app configuration
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Appearance', theme),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildThemeSelector(context, ref, themeMode, theme),
              const SizedBox(height: AppConstants.largePadding),

              _buildSectionTitle('Audio', theme),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildAudioSettings(context, ref, theme),
              const SizedBox(height: AppConstants.largePadding),

              _buildSectionTitle('Notifications', theme),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildNotificationSettings(context, theme),
              const SizedBox(height: AppConstants.largePadding),

              _buildSectionTitle('Data', theme),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildDataSettings(context, theme),
              const SizedBox(height: AppConstants.largePadding),

              _buildSectionTitle('About', theme),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildAboutSection(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final sessions = StorageService.getAllSessions();
      final buffer = StringBuffer();
      buffer.writeln('id,taskType,soundId,startTime,endTime,plannedMinutes,actualMinutes,focusScore,interruptions');
      for (final s in sessions) {
        buffer.writeln('${s.id},${s.taskType.name},${s.soundId},${s.startTime.toIso8601String()},${s.endTime.toIso8601String()},${s.plannedDurationMinutes},${s.actualDurationMinutes},${s.focusScore},${s.interruptions}');
      }
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported to clipboard as CSV')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    String currentTheme,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  'Light',
                  Icons.light_mode,
                  currentTheme == 'light',
                  () => _changeTheme(ref, 'light'),
                  theme,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: _buildThemeOption(
                  'Dark',
                  Icons.dark_mode,
                  currentTheme == 'dark',
                  () => _changeTheme(ref, 'dark'),
                  theme,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: _buildThemeOption(
                  'System',
                  Icons.settings_system_daydream,
                  currentTheme == 'system',
                  () => _changeTheme(ref, 'system'),
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withAlpha((0.1 * 255).round())
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.primary : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSettings(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Consumer(builder: (context, ref, _) {
            final audio = ref.watch(audioServiceProvider);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.volume_up),
              title: const Text('Sound Volume'),
              subtitle: const Text('Adjust ambient sound volume'),
              trailing: SizedBox(
                width: 140,
                child: Slider(
                  value: audio.volume,
                  onChanged: (value) {
                    ref.read(audioServiceProvider.notifier).setVolume(value);
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            );
          }),
          const Divider(),
          Consumer(builder: (context, ref, _) {
            final audio = ref.watch(audioServiceProvider);
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.multitrack_audio_rounded),
              title: const Text('Fade In/Out'),
              subtitle: const Text('Smooth audio transitions'),
              value: audio.fadeEnabled,
              onChanged: (value) {
                ref.read(audioServiceProvider.notifier).setFadeEnabled(value);
              },
              activeThumbColor: AppColors.primary,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.notifications),
            title: const Text('Session Reminders'),
            subtitle: const Text('Get reminded to take focus breaks'),
            value: StorageService.getNotificationsEnabled(),
            onChanged: (value) async {
              await StorageService.saveNotificationsEnabled(value);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value ? 'Reminders enabled' : 'Reminders disabled')),
              );
            },
            activeThumbColor: AppColors.primary,
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.celebration),
            title: const Text('Achievement Notifications'),
            subtitle: const Text('Celebrate your focus milestones'),
            value: StorageService.getNotificationsEnabled(),
            onChanged: (value) async {
              await StorageService.saveNotificationsEnabled(value);
              if (!mounted) return;
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettings(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.file_download),
            title: const Text('Export Data'),
            subtitle: const Text('Download your focus session data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await _exportData(context);
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_forever, color: AppColors.error),
            title: Text('Clear All Data', style: TextStyle(color: AppColors.error)),
            subtitle: const Text('Permanently delete all session data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showClearDataDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: Text(AppConstants.appVersion),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help using Zen Work'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Zen Work',
                applicationVersion: AppConstants.appVersion,
                children: const [
                  Text('Need help? Contact support@zenwork.app'),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            subtitle: const Text('Rate Zen Work on the App Store'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Rate App'),
                  content: const Text('Thanks for using Zen Work! Ratings coming soon.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _changeTheme(WidgetRef ref, String themeMode) {
    ref.read(themeModeProvider.notifier).state = themeMode;
    StorageService.saveThemeMode(themeMode);
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your focus sessions and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearAllData();
              if (!mounted) return;
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared successfully')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}