import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  var internalThemeMode = ThemeMode.system;

  ThemeBloc({required ThemeMode initialThemeMode})
    : super(ThemeState(initialThemeMode)) {
    var currentMode = state.themeMode;
    on<ChangeTheme>((event, emit) {
      emit(ThemeState(event.themeMode));
    });

    on<ToggleTheme>((event, emit) {
      currentMode = state.themeMode;
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
}
