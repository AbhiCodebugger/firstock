import 'package:dio/dio.dart';

import '../services/dio_service.dart';
import '../utils/typedefs.dart';

/// Shared HTTP boundary. Feeds must not construct [Dio] themselves.
class AppHttpClient {
  AppHttpClient({DioService? dioService})
      : _dio = dioService ?? DioService.instance;

  final DioService _dio;

  FutureEither<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool allowClientError = false,
  }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      allowClientError: allowClientError,
    );
  }
}
