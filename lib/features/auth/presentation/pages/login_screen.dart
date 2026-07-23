import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/router/app_router.dart';
import 'package:todo/features/auth/presentation/logic/auth_manager.dart';
import 'package:todo/features/auth/presentation/logic/biometric_auth_service.dart';

enum _LoginMode { signIn, setupCredential, unlock }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  final TextEditingController _secretController = TextEditingController();
  final TextEditingController _confirmSecretController =
      TextEditingController();

  bool _isLoading = false;
  bool _isBiometricShortcutAvailable = false;
  bool _obscureSecret = true;
  bool _obscureConfirmSecret = true;
  _LoginMode _mode = _LoginMode.signIn;

  @override
  void initState() {
    super.initState();
    _prepareScreen();
  }

  @override
  void dispose() {
    _secretController.dispose();
    _confirmSecretController.dispose();
    super.dispose();
  }

  Future<void> _prepareScreen() async {
    final AuthManager authManager = context.read<AuthManager>();
    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      authManager.isLoggedIn(),
      authManager.hasAppLockCredential(),
      authManager.isBiometricEnabled(),
      _biometricAuthService.isBiometricAvailable(),
    ]);
    final bool isLoggedIn = results[0] as bool;
    final bool hasAppLockCredential = results[1] as bool;
    final bool isBiometricEnabled = results[2] as bool;
    final bool isBiometricAvailable = results[3] as bool;

    if (!mounted) {
      return;
    }

    setState(() {
      if (!isLoggedIn) {
        _mode = _LoginMode.signIn;
      } else if (!hasAppLockCredential) {
        _mode = _LoginMode.setupCredential;
      } else {
        _mode = _LoginMode.unlock;
      }

      _isBiometricShortcutAvailable =
          isLoggedIn &&
          hasAppLockCredential &&
          isBiometricEnabled &&
          isBiometricAvailable;
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
        _mode = _LoginMode.setupCredential;
        _isBiometricShortcutAvailable = false;
        _secretController.clear();
        _confirmSecretController.clear();
      });
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

  Future<void> _saveAppLockCredential() async {
    if (_isLoading) {
      return;
    }

    final String secret = _secretController.text;
    final String confirmSecret = _confirmSecretController.text;
    final String? validationMessage = _validateSecret(secret);

    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }

    if (secret != confirmSecret) {
      _showMessage('PIN or password confirmation does not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthManager authManager = context.read<AuthManager>();
      await authManager.saveAppLockCredential(secret);
      await _offerBiometricShortcut();

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (_) {
      _showMessage('Unable to save your app lock. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _offerBiometricShortcut() async {
    final AuthManager authManager = context.read<AuthManager>();
    final bool canUseBiometrics =
        await _biometricAuthService.isBiometricAvailable();

    await authManager.setBiometricEnabled(false);

    if (!canUseBiometrics) {
      return;
    }

    if (!mounted) {
      return;
    }

    final bool? enableShortcut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable biometric shortcut'),
          content: const Text(
            'Your PIN or password will remain the default unlock method. Biometrics can be added as a faster shortcut.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );

    if (enableShortcut != true) {
      return;
    }

    final bool authenticated =
        await _biometricAuthService.authenticateWithBiometrics();
    if (!authenticated) {
      _showMessage(
        'Biometric shortcut was not enabled. Use your PIN or password to unlock.',
      );
      return;
    }

    await authManager.setBiometricEnabled(true);

    if (!mounted) {
      return;
    }

    setState(() {
      _isBiometricShortcutAvailable = true;
    });
  }

  Future<void> _unlockWithCredential() async {
    if (_isLoading) {
      return;
    }

    final String secret = _secretController.text;
    if (secret.isEmpty) {
      _showMessage('Enter your PIN or password to continue.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bool isValid = await context
          .read<AuthManager>()
          .verifyAppLockCredential(secret);

      if (!isValid) {
        _showMessage('Incorrect PIN or password.');
        return;
      }

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (_) {
      _showMessage('Unable to unlock the app. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unlockWithBiometrics() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bool authenticated =
          await _biometricAuthService.authenticateWithBiometrics();
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

  Future<void> _useAnotherGoogleAccount() async {
    if (_isLoading) {
      return;
    }

    await context.read<AuthManager>().logout();
    _secretController.clear();
    _confirmSecretController.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _mode = _LoginMode.signIn;
      _isBiometricShortcutAvailable = false;
    });
  }

  String? _validateSecret(String secret) {
    if (secret.isEmpty) {
      return 'Enter a PIN or password.';
    }

    final bool isNumeric = RegExp(r'^\d+$').hasMatch(secret);
    if (isNumeric) {
      return secret.length >= 4 ? null : 'PIN must be at least 4 digits.';
    }

    return secret.length >= 8
        ? null
        : 'Password must be at least 8 characters.';
  }

  String get _title {
    switch (_mode) {
      case _LoginMode.signIn:
        return 'Sign in with Google';
      case _LoginMode.setupCredential:
        return 'Create your app lock';
      case _LoginMode.unlock:
        return 'Unlock with PIN or password';
    }
  }

  String get _description {
    switch (_mode) {
      case _LoginMode.signIn:
        return 'Sign in first. Then create a PIN or password as the default unlock method.';
      case _LoginMode.setupCredential:
        return 'Set the PIN or password you want to use every time the app opens. Biometrics stay optional.';
      case _LoginMode.unlock:
        return 'Enter your PIN or password to continue. If you enabled biometrics, you can use that shortcut instead.';
    }
  }

  String get _primaryActionLabel {
    switch (_mode) {
      case _LoginMode.signIn:
        return 'Continue with Google';
      case _LoginMode.setupCredential:
        return 'Save PIN or password';
      case _LoginMode.unlock:
        return 'Unlock app';
    }
  }

  VoidCallback? get _primaryAction {
    if (_isLoading) {
      return null;
    }

    switch (_mode) {
      case _LoginMode.signIn:
        return _handleGoogleSignIn;
      case _LoginMode.setupCredential:
        return _saveAppLockCredential;
      case _LoginMode.unlock:
        return _unlockWithCredential;
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
                      if (_mode != _LoginMode.signIn) ...<Widget>[
                        const SizedBox(height: 24),
                        TextField(
                          controller: _secretController,
                          obscureText: _obscureSecret,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction:
                              _mode == _LoginMode.setupCredential
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'PIN or password',
                            hintText: 'Enter your app lock',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureSecret = !_obscureSecret;
                                });
                              },
                              icon: Icon(
                                _obscureSecret
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (_mode == _LoginMode.setupCredential) ...<Widget>[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmSecretController,
                          obscureText: _obscureConfirmSecret,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Confirm PIN or password',
                            hintText: 'Re-enter your app lock',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmSecret =
                                      !_obscureConfirmSecret;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmSecret
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                                        : Icons.lock_open_rounded,
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
                      if (_mode == _LoginMode.unlock &&
                          _isBiometricShortcutAvailable) ...<Widget>[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed:
                                _isLoading ? null : _unlockWithBiometrics,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            icon: const Icon(Icons.fingerprint_rounded),
                            label: const Text('Use biometric shortcut'),
                          ),
                        ),
                      ],
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
