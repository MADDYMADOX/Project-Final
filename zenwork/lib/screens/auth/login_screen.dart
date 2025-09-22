import 'package:flutter/material.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/auth/social_login_button.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import 'auth_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final result = await authService.signInWithGoogle();
      
      if (mounted) {
        if (result.isSuccess) {
          AuthFlowManager.handleLoginSuccess(
            user: result.user ?? 'google_user@example.com',
            token: result.token ?? 'mock_token',
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google login successful!'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Navigate to main app
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Google login failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google login failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo/icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.spa,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: AppConstants.largePadding * 2),
                
                // Welcome text
                Text(
                  'Welcome to Zen Work',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                Text(
                  'Sign in to start your focus journey',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.largePadding * 3),
                
                // Google login button
                SocialLoginButton(
                  text: 'Login with Google',
                  assetPath: 'assets/icons/google.png',
                  provider: SocialProvider.google,
                  onPressed: _handleGoogleLogin,
                  isLoading: _isLoading,
                  isEnabled: !_isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleLoginPage extends StatefulWidget {
  const GoogleLoginPage({super.key});

  @override
  State<GoogleLoginPage> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  bool _isLoading = false;

  void _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement Google sign-in logic here
    await Future.delayed(const Duration(seconds: 2)); // Mock delay

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged in with Google!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                onPressed: _handleGoogleLogin,
                icon: Image.asset(
                  'assets/google_logo.png', // Add Google logo in assets
                  height: 24.0,
                  width: 24.0,
                ),
                label: const Text(
                  'Login with Google',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
      ),
    );
  }
}
