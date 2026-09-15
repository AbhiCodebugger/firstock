import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/connection_status.dart';
import '../../domain/repositories/price_feed.dart';

class ConnectionViewState extends Equatable {
  const ConnectionViewState({this.status = FeedConnectionStatus.offline});

  final FeedConnectionStatus status;

  String get label => status.label;

  @override
  List<Object?> get props => [status];
}

class ConnectionCubit extends Cubit<ConnectionViewState> {
  ConnectionCubit({required PriceFeed feed})
      : _feed = feed,
        super(const ConnectionViewState()) {
    _sub = _feed.connection.listen((status) {
      if (!isClosed) {
        emit(ConnectionViewState(status: status));
      }
    });
  }

  final PriceFeed _feed;
  StreamSubscription<FeedConnectionStatus>? _sub;

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
