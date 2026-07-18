import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/router/app_router.dart';
import 'package:todo/features/auth/presentation/logic/auth_manager.dart';
import 'package:todo/features/auth/presentation/logic/biometric_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final BiometricAuthService _biometricAuthService = BiometricAuthService();

  bool _isLoading = false;
  bool _isUnlockMode = false;

  @override
  void initState() {
    super.initState();
    _prepareScreen();
  }

  Future<void> _prepareScreen() async {
    final AuthManager authManager = context.read<AuthManager>();
    final bool isLoggedIn = await authManager.isLoggedIn();
    final bool isBiometricEnabled = await authManager.isBiometricEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _isUnlockMode = isLoggedIn && isBiometricEnabled;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthManager authManager = context.read<AuthManager>();
      final bool success = await authManager.signInWithGoogle();
      if (!success) {
        _showMessage('Google sign-in was cancelled.');
        return;
      }

      final bool enrolled = await _enforceMandatoryBiometricEnrollment();
      if (!enrolled) {
        await authManager.logout();
        _showMessage('Biometric setup is required to continue.');
        return;
      }

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (_) {
      _showMessage('Sign-in failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _enforceMandatoryBiometricEnrollment() async {
    final AuthManager authManager = context.read<AuthManager>();
    final bool canUseBiometrics =
        await _biometricAuthService.canUseBiometrics();

    if (!canUseBiometrics) {
      return false;
    }

    if (!mounted) {
      return false;
    }

    final bool? proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable biometric security'),
          content: const Text(
            'Biometric authentication is required for every launch after sign-in.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel sign-in'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (proceed != true) {
      return false;
    }

    final bool authenticated = await _biometricAuthService.authenticate();
    if (!authenticated) {
      return false;
    }

    await authManager.setBiometricEnabled(true);
    return true;
  }

  Future<void> _unlockWithBiometrics() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bool authenticated = await _biometricAuthService.authenticate();
      if (authenticated) {
        if (mounted) {
          context.go(AppRoutes.home);
        }
      } else {
        _showMessage('Authentication failed. The app remains locked.');
      }
    } catch (_) {
      _showMessage('Unable to start biometric authentication.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.lock_person_outlined,
                        size: 52,
                        color: Color(0xFF4F46E5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isUnlockMode
                            ? 'Biometric Unlock Required'
                            : 'Sign in with Google',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isUnlockMode
                            ? 'You are already signed in. Authenticate to continue.'
                            : 'First launch requires Google sign-in and biometric enrollment.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isLoading
                                  ? null
                                  : _isUnlockMode
                                  ? _unlockWithBiometrics
                                  : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Icon(
                                    _isUnlockMode
                                        ? Icons.fingerprint_rounded
                                        : Icons.login_rounded,
                                  ),
                          label: Text(
                            _isUnlockMode
                                ? 'Unlock with biometrics'
                                : 'Continue with Google',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      if (_isUnlockMode) ...<Widget>[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () async {
                                    await context.read<AuthManager>().logout();
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {
                                      _isUnlockMode = false;
                                    });
                                  },
                          child: const Text('Use another Google account'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
