import 'package:flutter/material.dart';
import 'package:todo/features/vault/presentation/logic/vault_cubit.dart';
import 'package:todo/features/vault/presentation/logic/vault_state.dart';

class VaultLockScreen extends StatefulWidget {
  final VaultLockedState state;
  final VaultCubit cubit;

  const VaultLockScreen({
    super.key,
    required this.state,
    required this.cubit,
  });

  @override
  State<VaultLockScreen> createState() => _VaultLockScreenState();
}

class _VaultLockScreenState extends State<VaultLockScreen> {
  String _pinBuffer = '';

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'DEL') {
        if (_pinBuffer.isNotEmpty) {
          _pinBuffer = _pinBuffer.substring(0, _pinBuffer.length - 1);
        }
      } else if (value == 'CLEAR') {
        _pinBuffer = '';
      } else {
        if (_pinBuffer.length < 4) {
          _pinBuffer += value;
        }
      }
    });

    if (_pinBuffer.length == 4) {
      final pin = _pinBuffer;
      setState(() {
        _pinBuffer = '';
      });
      widget.cubit.processPinInput(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    String subtitle = 'Enter your 4-digit Security PIN';
    if (!state.isPinSet) {
      subtitle = state.tempFirstPin == null
          ? 'Set up a 4-digit PIN for your Private Vault'
          : 'Re-enter your 4-digit PIN to confirm';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),
            // Header & Lock Icon
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF5E42EB).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF5E42EB).withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5E42EB).withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 36,
                  color: Color(0xFF818CF8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Private Vault',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // PIN Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pinBuffer.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? const Color(0xFF6366F1)
                        : Colors.transparent,
                    border: Border.all(
                      color: isFilled
                          ? const Color(0xFF818CF8)
                          : const Color(0xFF475569),
                      width: 2,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),

            if (state.error != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF87171),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Biometric button (if available & PIN set)
            if (state.isPinSet && state.supportsBiometrics)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton.icon(
                  onPressed: () => widget.cubit.authenticateBiometrics(),
                  icon: const Icon(
                    Icons.fingerprint_rounded,
                    color: Color(0xFF818CF8),
                    size: 26,
                  ),
                  label: const Text(
                    'Unlock with Biometrics',
                    style: TextStyle(
                      color: Color(0xFF818CF8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Numpad Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              child: Column(
                children: [
                  _buildNumpadRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildNumpadRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildNumpadRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  _buildNumpadRow(['CLEAR', '0', 'DEL']),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key == 'CLEAR') {
          return SizedBox(
            width: 68,
            height: 68,
            child: IconButton(
              onPressed: () => _onKeyPress('CLEAR'),
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF94A3B8),
                size: 24,
              ),
            ),
          );
        }
        if (key == 'DEL') {
          return SizedBox(
            width: 68,
            height: 68,
            child: IconButton(
              onPressed: () => _onKeyPress('DEL'),
              icon: const Icon(
                Icons.backspace_outlined,
                color: Color(0xFF94A3B8),
                size: 24,
              ),
            ),
          );
        }

        return Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E293B),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1,
            ),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _onKeyPress(key),
            child: Center(
              child: Text(
                key,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
