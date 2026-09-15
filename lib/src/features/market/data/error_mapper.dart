import '../../../utils/failure.dart';

Failure mapFeedFailure(Object error) {
  final message = error.toString();
  if (message.contains('SocketException') ||
      message.contains('Failed host lookup') ||
      message.contains('Connection refused')) {
    return NetworkFailure(message, error: error);
  }
  return ServerFailure(message, error: error);
}
