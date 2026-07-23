import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/router/app_router.dart';
import 'package:todo/features/auth/presentation/logic/auth_manager.dart';
import 'package:todo/features/auth/presentation/logic/biometric_auth_service.dart';

enum _LoginMode { signIn, unlock }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final BiometricAuthService _biometricAuthService = BiometricAuthService();

  bool _isLoading = false;
  bool _canUseDeviceAuth = false;
  _LoginMode _mode = _LoginMode.signIn;

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
      _mode = isLoggedIn ? _LoginMode.unlock : _LoginMode.signIn;
      _canUseDeviceAuth = canUseDeviceAuth;
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
        _mode = _LoginMode.unlock;
      });

      await _unlockWithDeviceSecurity();
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

  Future<void> _unlockWithDeviceSecurity() async {
    if (_isLoading) {
      return;
    }

    if (!_canUseDeviceAuth) {
      _showMessage(
        'Set a screen lock on your phone first (PIN, pattern, password, or biometrics).',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bool authenticated =
          await _biometricAuthService.authenticateWithDeviceCredentials();
      if (authenticated) {
        if (mounted) {
          context.go(AppRoutes.home);
        }
      } else {
        _showMessage('Authentication failed. The app remains locked.');
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

  Future<void> _useAnotherGoogleAccount() async {
    if (_isLoading) {
      return;
    }

    await context.read<AuthManager>().logout();

    if (!mounted) {
      return;
    }

    setState(() {
      _mode = _LoginMode.signIn;
    });
  }

  String get _title {
    switch (_mode) {
      case _LoginMode.signIn:
        return 'Sign in with Google';
      case _LoginMode.unlock:
        return 'Unlock with device security';
    }
  }

  String get _description {
    switch (_mode) {
      case _LoginMode.signIn:
        return 'Sign in with Google to continue.';
      case _LoginMode.unlock:
        return 'Use your phone PIN, password, pattern, or biometrics to unlock the app.';
    }
  }

  String get _primaryActionLabel {
    switch (_mode) {
      case _LoginMode.signIn:
        return 'Continue with Google';
      case _LoginMode.unlock:
        return 'Unlock with device security';
    }
  }

  VoidCallback? get _primaryAction {
    if (_isLoading) {
      return null;
    }

    switch (_mode) {
      case _LoginMode.signIn:
        return _handleGoogleSignIn;
      case _LoginMode.unlock:
        return _unlockWithDeviceSecurity;
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
                        _title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _description,
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
                          onPressed: _primaryAction,
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
                                    _mode == _LoginMode.signIn
                                        ? Icons.login_rounded
                                        : Icons.phonelink_lock_rounded,
                                  ),
                          label: Text(
                            _primaryActionLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      if (_mode != _LoginMode.signIn) ...<Widget>[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed:
                              _isLoading ? null : _useAnotherGoogleAccount,
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
