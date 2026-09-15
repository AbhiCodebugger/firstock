import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/theme/data/theme_repository_impl.dart';
import '../features/theme/domain/repositories/theme_repository.dart';
import '../features/theme/presentation/cubit/theme_cubit.dart';
import '../services/storage_service.dart';

/// Theme repository + first-frame mode. Prefs are read here so [ThemeCubit]
/// can use `create` without flashing the default after splash.
class ThemeBindings {
  ThemeBindings._({required this.providers});

  final List<BlocProvider> providers;

  static Future<ThemeBindings> create({
    ThemeRepository? repository,
  }) async {
    final repo = repository ?? ThemeRepositoryImpl(StorageService.instance);
    final initialMode = ThemeCubit.parseMode(await repo.loadMode());
    return ThemeBindings._(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(repo, initialMode: initialMode),
          lazy: false,
        ),
      ],
    );
  }
}
