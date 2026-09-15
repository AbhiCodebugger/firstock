import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/utils.dart';

/// HTTP verbs over [AppConfig.dio], mapped through [runTask].
class DioService {
  DioService._();
  static final DioService instance = DioService._();

  FutureEither<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool allowClientError = false,
  }) {
    return runTask(
      () => AppConfig.dio.get(
        path,
        queryParameters: queryParameters,
        options: allowClientError
            ? Options(
                validateStatus: (status) => status != null && status < 500)
            : null,
      ),
      requiresNetwork: true,
    );
  }

  FutureEither<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return runTask(
        () => AppConfig.dio
            .post(path, data: data, queryParameters: queryParameters),
        requiresNetwork: true);
  }

  FutureEither<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return runTask(
        () => AppConfig.dio
            .put(path, data: data, queryParameters: queryParameters),
        requiresNetwork: true);
  }

  FutureEither<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return runTask(
        () => AppConfig.dio
            .patch(path, data: data, queryParameters: queryParameters),
        requiresNetwork: true);
  }

  FutureEither<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return runTask(
        () => AppConfig.dio
            .delete(path, data: data, queryParameters: queryParameters),
        requiresNetwork: true);
  }
}
