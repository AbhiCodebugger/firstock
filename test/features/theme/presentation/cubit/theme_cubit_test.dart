import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/theme/domain/repositories/theme_repository.dart';
import 'package:mindorigin/src/features/theme/presentation/cubit/theme_cubit.dart';

class _FakeThemeRepository implements ThemeRepository {
  String? mode;

  @override
  Future<String?> loadMode() async => mode;

  @override
  Future<void> saveMode(String value) async {
    mode = value;
  }
}

void main() {
  test('initialMode skips a first-frame flash', () async {
    final cubit = ThemeCubit(
      _FakeThemeRepository(),
      initialMode: ThemeMode.light,
    );
    expect(cubit.state.mode, ThemeMode.light);
    await cubit.close();
  });

  test('parseMode falls back to dark', () {
    expect(ThemeCubit.parseMode(null), ThemeMode.dark);
    expect(ThemeCubit.parseMode('nope'), ThemeMode.dark);
    expect(ThemeCubit.parseMode('light'), ThemeMode.light);
  });

  test('toggle persists light and dark', () async {
    final repo = _FakeThemeRepository()..mode = 'dark';
    final cubit = ThemeCubit(repo);
    await cubit.load();
    expect(cubit.state.mode, ThemeMode.dark);
    await cubit.toggle();
    expect(cubit.state.mode, ThemeMode.light);
    expect(repo.mode, 'light');
    await cubit.close();
  });
}
