import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/onboarding_repository.dart';

class OnboardingManager extends Cubit<bool> {
  final OnboardingRepository _repository;

  OnboardingManager(this._repository) : super(false);

  Future<void> syncOnboardingState() async {
    final bool isCompleted = await _repository.isOnboardingCompleted();
    emit(isCompleted);
  }

  Future<void> completeOnboarding() async {
    await _repository.setOnboardingCompleted(true);
    emit(true);
  }
}
