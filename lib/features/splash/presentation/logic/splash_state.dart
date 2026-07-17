part of 'splash_manager.dart';

sealed class SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigateToOnboarding extends SplashState {}

class SplashNavigateToLogin extends SplashState {}

class SplashNavigateToHome extends SplashState {}
