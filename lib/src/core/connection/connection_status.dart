/// Visible feed state. Chip copy must stay exactly these three strings.
enum FeedConnectionStatus { live, reconnecting, offline }

/// Assignment-mandated connection chip labels.
abstract final class ConnectionLabels {
  static const String live = 'Live';
  static const String reconnecting = 'Reconnecting…';
  static const String offline = 'Offline';
}

extension FeedConnectionStatusX on FeedConnectionStatus {
  String get label => switch (this) {
    FeedConnectionStatus.live => ConnectionLabels.live,
    FeedConnectionStatus.reconnecting => ConnectionLabels.reconnecting,
    FeedConnectionStatus.offline => ConnectionLabels.offline,
  };
}
