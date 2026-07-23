import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/router/app_router.dart';
import 'package:todo/features/auth/presentation/logic/auth_manager.dart';
import 'package:todo/features/auth/presentation/logic/biometric_auth_service.dart';

enum _AuthStep { signIn, verifyingBiometric }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final BiometricAuthService _biometricAuthService = BiometricAuthService();

  bool _isLoading = false;

  bool _canUseDeviceAuth = false;

  _AuthStep _authStep = _AuthStep.signIn;

  @override
  void initState() {
    super.initState();
    _prepareScreen();
  }

  Future<void> _prepareScreen() async {
    final AuthManager authManager = context.read<AuthManager>();

    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      authManager.isLoggedIn(),
      _biometricAuthService.canUseDeviceAuth(),
    ]);

    final bool isLoggedIn = results[0] as bool;

    final bool canUseDeviceAuth = results[1] as bool;

    if (!mounted) {
      return;
    }

    setState(() {
      _canUseDeviceAuth = canUseDeviceAuth;
      // If already logged in and device auth available, jump straight to verification
      if (isLoggedIn && canUseDeviceAuth) {
        _authStep = _AuthStep.verifyingBiometric;
        // Auto-trigger biometric verification
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _verifyBiometric();
        });
      }
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

      if (!mounted) {
        return;
      }

      setState(() {
        _authStep = _AuthStep.verifyingBiometric;
      });

      // Auto-trigger biometric without showing a button

      await _verifyBiometric();
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

  Future<void> _verifyBiometric() async {
    if (!_canUseDeviceAuth) {
      _showMessage(
        'Set a screen lock on your phone first (PIN, pattern, password, or biometrics).',
      );
      return;
    }
    context.push(AppRoutes.verifyingBiometric);

    try {
      final bool authenticated =
          await _biometricAuthService.authenticateWithDeviceCredentials();

      if (authenticated) {
        if (mounted) {
          context.go(AppRoutes.home);
        }
      } else {
        if (mounted) context.go(AppRoutes.verifyingBiometric);
      }
    } catch (_) {
      _showMessage('Unable to start device authentication.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String get _title {
    switch (_authStep) {
      case _AuthStep.signIn:
        return 'Sign in with Google';
      case _AuthStep.verifyingBiometric:
        return 'Unlock with device security';
    }
  }

  String get _description {
    switch (_authStep) {
      case _AuthStep.signIn:
        return 'Sign in with Google to continue.';
      case _AuthStep.verifyingBiometric:
        return 'Use your phone PIN, password, pattern, or biometrics to unlock the app.';
    }
  }

  String get _primaryActionLabel {
    switch (_authStep) {
      case _AuthStep.signIn:
        return 'Continue with Google';
      case _AuthStep.verifyingBiometric:
        return 'Unlock with device security';
    }
  }

  VoidCallback? get _primaryAction {
    if (_isLoading) {
      return null;
    }

    switch (_authStep) {
      case _AuthStep.signIn:
        return _handleGoogleSignIn;
      case _AuthStep.verifyingBiometric:
        return _verifyBiometric;
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
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Icon with subtle background
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 40,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    _description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Primary Action Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _primaryAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _authStep == _AuthStep.signIn
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    _authStep == _AuthStep.signIn
                                        ? Icons.login_rounded
                                        : Icons.fingerprint_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _primaryActionLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),

                  // Secondary action (show another account button only on verify step)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
