import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepository {
  final OnboardingLocalDataSource _dataSource;

  OnboardingRepository(this._dataSource);

  Future<bool> isOnboardingCompleted() async {
    return _dataSource.isOnboardingCompleted();
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _dataSource.setOnboardingCompleted(completed);
  }
}

final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>((ref) {
  return OnboardingLocalDataSource();
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final dataSource = ref.watch(onboardingLocalDataSourceProvider);
  return OnboardingRepository(dataSource);
});
