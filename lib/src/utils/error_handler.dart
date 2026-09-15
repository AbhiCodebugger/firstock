import 'package:dio/dio.dart';

import 'failure.dart';

class AppErrorHandler {
  static String format(Object error) {
    if (error is Failure) {
      return error.message;
    }
    if (error is DioException) {
      return error.message ?? error.toString();
    }
    if (error is String) {
      return error;
    }
    return error.toString();
  }
}
