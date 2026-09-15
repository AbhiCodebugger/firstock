import 'package:fpdart/fpdart.dart';

import '../imports/core_imports.dart';

/// Maps async work to [FutureEither]. Offline gated tasks return
/// [NetworkFailure]; local work (prefs) maps errors to [CacheFailure].
FutureEither<T> runTask<T>(
  Future<T> Function() action, {
  bool requiresNetwork = false,
}) async {
  if (requiresNetwork) {
    final hasNetwork = await InternetConnectionService().hasConnection();

    if (!hasNetwork) {
      AppLogger.warning('Network unavailable for task');
      return left(
        const NetworkFailure(
          'No internet connection. Please check your connection and try again.',
        ),
      );
    }
  }

  try {
    final result = await action();
    return right(result);
  } catch (error, stackTrace) {
    AppLogger.error('Task execution failed $error', error, stackTrace);
    final errorMessage = AppErrorHandler.format(error);
    if (requiresNetwork) {
      return left(ServerFailure(errorMessage, error: error));
    }
    return left(CacheFailure(errorMessage, error: error));
  }
}
