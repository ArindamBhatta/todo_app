import 'package:todo/features/vault/data/models/vault_item.dart';

abstract class VaultState {
  const VaultState();
}

class VaultLockedState extends VaultState {
  final bool isPinSet;
  final bool supportsBiometrics;
  final String? error;
  final bool isCreatingPin;
  final String? tempFirstPin;

  const VaultLockedState({
    required this.isPinSet,
    required this.supportsBiometrics,
    this.error,
    this.isCreatingPin = false,
    this.tempFirstPin,
  });

  VaultLockedState copyWith({
    bool? isPinSet,
    bool? supportsBiometrics,
    String? error,
    bool? isCreatingPin,
    String? tempFirstPin,
  }) {
    return VaultLockedState(
      isPinSet: isPinSet ?? this.isPinSet,
      supportsBiometrics: supportsBiometrics ?? this.supportsBiometrics,
      error: error,
      isCreatingPin: isCreatingPin ?? this.isCreatingPin,
      tempFirstPin: tempFirstPin ?? this.tempFirstPin,
    );
  }
}

class VaultUnlockedState extends VaultState {
  final List<VaultItem> items;
  final String selectedCategory;
  final bool isLoading;
  final String? statusMessage;

  const VaultUnlockedState({
    required this.items,
    this.selectedCategory = 'all',
    this.isLoading = false,
    this.statusMessage,
  });

  VaultUnlockedState copyWith({
    List<VaultItem>? items,
    String? selectedCategory,
    bool? isLoading,
    String? statusMessage,
  }) {
    return VaultUnlockedState(
      items: items ?? this.items,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      statusMessage: statusMessage,
    );
  }
}
