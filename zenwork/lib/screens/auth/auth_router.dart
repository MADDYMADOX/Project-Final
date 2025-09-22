import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'reset_password_screen.dart';

/// Authentication router for handling navigation between auth screens
class AuthRouter {
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  /// Generate routes for authentication screens
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );
      
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
      
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      
      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            token: args?['token'] as String?,
            email: args?['email'] as String?,
          ),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );
    }
  }

  /// Navigate to login screen
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      login,
      (route) => false,
    );
  }

  /// Navigate to signup screen
  static void navigateToSignUp(BuildContext context) {
    Navigator.of(context).pushNamed(signup);
  }

  /// Navigate to forgot password screen
  static void navigateToForgotPassword(BuildContext context) {
    Navigator.of(context).pushNamed(forgotPassword);
  }

  /// Navigate to reset password screen
  static void navigateToResetPassword(
    BuildContext context, {
    String? token,
    String? email,
  }) {
    Navigator.of(context).pushNamed(
      resetPassword,
      arguments: {
        'token': token,
        'email': email,
      },
    );
  }
}

/// Authentication wrapper widget for managing auth state
class AuthWrapper extends StatefulWidget {
  final Widget child;
  final bool isAuthenticated;

  const AuthWrapper({
    super.key,
    required this.child,
    required this.isAuthenticated,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isAuthenticated) {
      return LoginScreen();
    }
    
    return widget.child;
  }
}

/// Authentication flow manager
class AuthFlowManager {
  static bool _isAuthenticated = false;
  static String? _currentUser;
  static String? _userToken;

  /// Check if user is authenticated
  static bool get isAuthenticated => _isAuthenticated;

  /// Get current user
  static String? get currentUser => _currentUser;

  /// Get user token
  static String? get userToken => _userToken;

  /// Set authentication state
  static void setAuthenticated({
    required bool isAuthenticated,
    String? user,
    String? token,
  }) {
    _isAuthenticated = isAuthenticated;
    _currentUser = user;
    _userToken = token;
  }

  /// Clear authentication state
  static void clearAuth() {
    _isAuthenticated = false;
    _currentUser = null;
    _userToken = null;
  }

  /// Handle successful login
  static void handleLoginSuccess({
    required String user,
    required String token,
  }) {
    setAuthenticated(
      isAuthenticated: true,
      user: user,
      token: token,
    );
  }

  /// Handle logout
  static void handleLogout() {
    clearAuth();
  }
}
