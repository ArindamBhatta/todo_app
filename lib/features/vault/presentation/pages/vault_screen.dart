import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/vault/presentation/logic/vault_cubit.dart';
import 'package:todo/features/vault/presentation/logic/vault_state.dart';
import 'package:todo/features/vault/presentation/pages/vault_lock_screen.dart';
import 'package:todo/features/vault/presentation/pages/vault_main_screen.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VaultCubit>(
      create: (context) => VaultCubit()..initialize(),
      child: BlocBuilder<VaultCubit, VaultState>(
        builder: (context, state) {
          final cubit = context.read<VaultCubit>();

          if (state is VaultLockedState) {
            return VaultLockScreen(state: state, cubit: cubit);
          } else if (state is VaultUnlockedState) {
            return VaultMainScreen(state: state, cubit: cubit);
          }

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF5E42EB)),
            ),
          );
        },
      ),
    );
  }
}
