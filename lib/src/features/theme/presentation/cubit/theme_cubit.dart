import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/theme_repository.dart';

class ThemeState extends Equatable {
  const ThemeState({this.mode = ThemeMode.dark});

  final ThemeMode mode;

  @override
  List<Object?> get props => [mode];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._repository, {ThemeMode initialMode = ThemeMode.dark})
    : super(ThemeState(mode: initialMode));

  final ThemeRepository _repository;

  /// Parses a persisted mode name. Unknown or null values stay dark.
  static ThemeMode parseMode(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  Future<void> load() async {
    emit(ThemeState(mode: parseMode(await _repository.loadMode())));
  }

  Future<void> toggle() {
    final next = state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    return setMode(next);
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(ThemeState(mode: mode));
    await _repository.saveMode(mode.name);
  }
}
