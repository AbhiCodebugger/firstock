import 'dart:async';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/connection/connection_status.dart';
import '../../../../core/reconnect/backoff.dart';
import '../../../../utils/logger.dart';

typedef SocketFactory = WebSocketChannel Function(Uri uri);

/// Owns backoff reconnect. Callers supply [onBeforeConnect] for a snapshot.
class WebSocketService {
  WebSocketService({
    required this.uri,
    required this.backoff,
    this.onBeforeConnect,
    SocketFactory? socketFactory,
    Random? random,
  })  : _socketFactory = socketFactory ?? WebSocketChannel.connect,
        _random = random ?? Random();

  final Uri uri;
  final BackoffPolicy backoff;
  final Future<void> Function()? onBeforeConnect;
  final SocketFactory _socketFactory;
  final Random _random;

  final _messages = StreamController<dynamic>.broadcast();
  final _connection = StreamController<FeedConnectionStatus>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  bool _stopped = false;
  bool _connecting = false;
  int _attempt = 0;
  FeedConnectionStatus? _lastStatus;

  Stream<dynamic> get messages => _messages.stream;
  Stream<FeedConnectionStatus> get connection => _connection.stream;

  Future<void> connect() async {
    _stopped = false;
    await _open(resetAttempt: true);
  }

  Future<void> disconnect() async {
    _stopped = true;
    await _tearDown();
    _emit(FeedConnectionStatus.offline);
  }

  void send(dynamic data) {
    _channel?.sink.add(data);
  }

  /// Force-drop for the Dev "Kill socket" control.
  Future<void> kill() async {
    AppLogger.warning('WebSocket killed for demo');
    await _tearDown();
    if (!_stopped) {
      unawaited(_reconnect());
    }
  }

  Future<void> dispose() async {
    _stopped = true;
    await _tearDown();
    await _messages.close();
    await _connection.close();
  }

  Future<void> _open({required bool resetAttempt}) async {
    if (_stopped || _connecting) {
      return;
    }
    _connecting = true;
    try {
      if (resetAttempt) {
        _attempt = 0;
      }
      if (onBeforeConnect != null) {
        await onBeforeConnect!();
      }
      final channel = _socketFactory(uri);
      _channel = channel;
      _sub = channel.stream.listen(
        _messages.add,
        onError: (Object error, StackTrace stack) {
          AppLogger.error('WebSocket error $error', [error, stack]);
          unawaited(_reconnect());
        },
        onDone: () {
          unawaited(_reconnect());
        },
      );
      _attempt = 0;
      _emit(FeedConnectionStatus.live);
    } catch (error, stack) {
      AppLogger.error('WebSocket connect failed $error', [error, stack]);
      _connecting = false;
      unawaited(_reconnect());
      return;
    }
    _connecting = false;
  }

  Future<void> _reconnect() async {
    if (_stopped) {
      return;
    }
    await _tearDown();
    _emit(FeedConnectionStatus.reconnecting);
    final delay = backoff.delayForAttempt(_attempt, random: _random);
    _attempt += 1;
    AppLogger.info('Reconnecting in ${delay.inMilliseconds}ms');
    await Future<void>.delayed(delay);
    if (_stopped) {
      return;
    }
    await _open(resetAttempt: false);
  }

  Future<void> _tearDown() async {
    await _sub?.cancel();
    _sub = null;
    try {
      await _channel?.sink.close();
    } catch (error, stack) {
      AppLogger.error('WebSocket close failed $error', [error, stack]);
    }
    _channel = null;
  }

  void _emit(FeedConnectionStatus status) {
    if (_lastStatus == status || _connection.isClosed) {
      return;
    }
    _lastStatus = status;
    _connection.add(status);
  }
}
