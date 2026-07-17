import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepository {
  final OnboardingLocalDataSource _dataSource;

  OnboardingRepository(this._dataSource);

  Future<bool> isOnboardingCompleted() => _dataSource.isOnboardingCompleted();

  Future<void> setOnboardingCompleted(bool completed) =>
      _dataSource.setOnboardingCompleted(completed);
}
