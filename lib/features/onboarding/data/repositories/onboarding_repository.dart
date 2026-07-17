import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepository {
  final OnboardingLocalDataSource _dataSource;

  OnboardingRepository(this._dataSource);

  //check if onboarding is completed
  Future<bool> isOnboardingCompleted() => _dataSource.isOnboardingCompleted();

  //set onboarding completed status
  Future<void> setOnboardingCompleted(bool completed) =>
      _dataSource.setOnboardingCompleted(completed);
}
