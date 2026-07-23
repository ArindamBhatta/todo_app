import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/core/theme/app_theme.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({required ThemeMode initialThemeMode})
    : super(ThemeState(initialThemeMode)) {
    on<ChangeTheme>((event, emit) {
      emit(ThemeState(event.themeMode));
    });

    on<ToggleTheme>((event, emit) {
      final currentMode = state.themeMode;
      emit(
        ThemeState(
          currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
        ),
      );
    });
  }
}

abstract class ThemeEvent {}

class ChangeTheme extends ThemeEvent {
  final ThemeMode themeMode;

  ChangeTheme(this.themeMode);
}

class ToggleTheme extends ThemeEvent {}

class ThemeState {
  final ThemeMode themeMode;

  ThemeState(this.themeMode);

  ThemeData get themeData {
    return themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
  }
}
