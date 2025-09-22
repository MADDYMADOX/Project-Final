import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenwork/firebase_options.dart';

import 'services/storage_service.dart';
import 'utils/app_theme.dart';
import 'utils/app_colors.dart';
import 'utils/constants.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/auth_router.dart';
import 'screens/auth/login_screen.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await StorageService.initialize();

  runApp(const ProviderScope(child: ZenWorkApp()));
}

class ZenWorkApp extends ConsumerWidget {
  const ZenWorkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(themeMode),
      home: const _RootRouter(),
      onGenerateRoute: AuthRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeMode _getThemeMode(String themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class _RootRouter extends ConsumerWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedOnboarding = StorageService.getOnboardingCompleted();
    final isAuthenticated = AuthFlowManager.isAuthenticated;

    // Check authentication first
    if (!isAuthenticated) {
      return LoginScreen();
    }

    // Then check onboarding
    if (hasCompletedOnboarding) {
      return const MainNavigationScreen();
    }

    return OnboardingScreen(
      onComplete: () async {
        await StorageService.saveOnboardingCompleted(true);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    AppColors.surfaceDark.withOpacity(0.95),
                    AppColors.backgroundDark.withOpacity(0.95),
                  ]
                : [
                    AppColors.surface.withOpacity(0.95),
                    AppColors.background.withOpacity(0.95),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              letterSpacing: 0.25,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 24),
                activeIcon: Icon(Icons.home_rounded, size: 26),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined, size: 24),
                activeIcon: Icon(Icons.history_rounded, size: 26),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined, size: 24),
                activeIcon: Icon(Icons.bar_chart_rounded, size: 26),
                label: 'Stats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined, size: 24),
                activeIcon: Icon(Icons.settings_rounded, size: 26),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
