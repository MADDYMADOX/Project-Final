import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zenwork/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  bool _busy = false;

  Future<void> _googleLogin() async {
    setState(() => _busy = true);
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) return; // cancelled

      final auth = await user.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final result = await _auth.signInWithCredential(cred);
      if (!mounted) return;

      if (result.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _busy
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _googleLogin,
                child: const Text('Sign in with Google'),
              ),
      ),
    );
  }
}
