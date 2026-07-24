import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/vault/data/datasources/vault_storage.dart';
import 'package:todo/features/vault/presentation/logic/vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  final VaultStorage _storage;

  VaultCubit({VaultStorage? storage})
      : _storage = storage ?? VaultStorage.instance,
        super(const VaultLockedState(isPinSet: false, supportsBiometrics: false));

  Future<void> initialize() async {
    final isPinSet = await _storage.isPinSet();
    final supportsBiometrics = await _storage.canCheckBiometrics();

    emit(VaultLockedState(
      isPinSet: isPinSet,
      supportsBiometrics: supportsBiometrics,
    ));

    // Try biometric automatically if configured & PIN exists
    if (isPinSet && supportsBiometrics) {
      final success = await _storage.authenticateBiometrics();
      if (success) {
        await unlockVault();
      }
    }
  }

  Future<void> processPinInput(String pin) async {
    final currentState = state;
    if (currentState is! VaultLockedState) return;

    if (currentState.isPinSet) {
      final isValid = await _storage.verifyPin(pin);
      if (isValid) {
        await unlockVault();
      } else {
        emit(currentState.copyWith(error: 'Incorrect PIN. Try again.'));
      }
    } else {
      // PIN Setup flow
      if (currentState.tempFirstPin == null) {
        // First entry
        emit(currentState.copyWith(
          tempFirstPin: pin,
          isCreatingPin: true,
          error: null,
        ));
      } else {
        // Confirmation entry
        if (pin == currentState.tempFirstPin) {
          await _storage.setPin(pin);
          await unlockVault();
        } else {
          emit(currentState.copyWith(
            tempFirstPin: null,
            isCreatingPin: false,
            error: 'PINs did not match. Please start again.',
          ));
        }
      }
    }
  }

  Future<void> authenticateBiometrics() async {
    final currentState = state;
    if (currentState is VaultLockedState && currentState.isPinSet) {
      final success = await _storage.authenticateBiometrics();
      if (success) {
        await unlockVault();
      } else {
        emit(currentState.copyWith(error: 'Biometric verification failed.'));
      }
    }
  }

  Future<void> unlockVault() async {
    emit(const VaultUnlockedState(items: [], isLoading: true));
    await loadVaultItems();
  }

  void lockVault() {
    initialize();
  }

  Future<void> loadVaultItems() async {
    final currentState = state;
    final category = currentState is VaultUnlockedState ? currentState.selectedCategory : 'all';

    emit(VaultUnlockedState(
      items: currentState is VaultUnlockedState ? currentState.items : [],
      selectedCategory: category,
      isLoading: true,
    ));

    final items = await _storage.getVaultItems(category: category);

    emit(VaultUnlockedState(
      items: items,
      selectedCategory: category,
      isLoading: false,
    ));
  }

  Future<void> setCategoryFilter(String category) async {
    emit(VaultUnlockedState(items: [], selectedCategory: category, isLoading: true));
    final items = await _storage.getVaultItems(category: category);
    emit(VaultUnlockedState(items: items, selectedCategory: category, isLoading: false));
  }

  Future<void> addSecretNote({
    required String title,
    required String content,
  }) async {
    if (title.trim().isEmpty) return;
    await _storage.addSecretNote(
      title: title.trim(),
      content: content.trim(),
    );
    await loadVaultItems();
  }

  Future<void> addVaultFile({
    required String title,
    required String category,
    required String filePath,
  }) async {
    if (title.trim().isEmpty || filePath.isEmpty) return;
    await _storage.addFileItem(
      title: title.trim(),
      category: category,
      sourceFilePath: filePath,
    );
    await loadVaultItems();
  }

  Future<void> deleteItem(String id) async {
    await _storage.deleteVaultItem(id);
    await loadVaultItems();
  }
}
