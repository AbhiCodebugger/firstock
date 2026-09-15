import 'config/env.dart';
import 'core/reconnect/backoff.dart';

enum Flavor { dev, qa, prod }

enum FeedType { simulated, finnhub }

class FlavorConfig {
  FlavorConfig({
    required this.flavor,
    required this.feedType,
    required this.wsUrl,
    required this.apiBaseUrl,
    required this.backoff,
    required this.simulateDisconnect,
    required this.showKillSocket,
    required this.showRebuildCounters,
  });

  final Flavor flavor;
  final FeedType feedType;
  final String wsUrl;
  final String apiBaseUrl;
  final BackoffPolicy backoff;
  final bool simulateDisconnect;
  final bool showKillSocket;
  final bool showRebuildCounters;

  static FlavorConfig? _current;

  static FlavorConfig get current {
    final value = _current;
    if (value == null) {
      throw StateError('FlavorConfig.loadFromEnv has not run');
    }
    return value;
  }

  static bool get isLoaded => _current != null;

  static void load(Flavor flavor) {
    _current = FlavorConfig(
      flavor: flavor,
      feedType: FeedType.simulated,
      wsUrl: '',
      apiBaseUrl: 'https://finnhub.io/api/v1',
      backoff: const BackoffPolicy(),
      simulateDisconnect: flavor != Flavor.prod,
      showKillSocket: flavor == Flavor.dev,
      showRebuildCounters: flavor == Flavor.dev,
    );
  }

  static void loadFromEnv(Flavor flavor) {
    final feedRaw = Env.get('FEED_TYPE', fallback: 'simulated').toLowerCase();
    _current = FlavorConfig(
      flavor: flavor,
      feedType: feedRaw == 'finnhub' ? FeedType.finnhub : FeedType.simulated,
      wsUrl: Env.get('WS_URL', fallback: 'wss://simulated.mindorigin.local/ws'),
      apiBaseUrl: Env.get(
        'API_BASE_URL',
        fallback: 'https://finnhub.io/api/v1',
      ),
      backoff: BackoffPolicy(
        initial: Duration(
          milliseconds: Env.integer('BACKOFF_INITIAL_MS', fallback: 1000),
        ),
        max: Duration(
          milliseconds: Env.integer('BACKOFF_MAX_MS', fallback: 30000),
        ),
        jitter: Env.decimal('BACKOFF_JITTER', fallback: 0.2),
      ),
      simulateDisconnect: Env.flag(
        'SIMULATE_DISCONNECT',
        fallback: flavor != Flavor.prod,
      ),
      showKillSocket: Env.flag(
        'SHOW_KILL_SOCKET',
        fallback: flavor == Flavor.dev,
      ),
      showRebuildCounters: Env.flag(
        'SHOW_REBUILD_COUNTERS',
        fallback: flavor == Flavor.dev,
      ),
    );
  }

  static String get name => current.flavor.name;
}

extension FlavorX on Flavor {
  String get envFile => switch (this) {
        Flavor.dev => '.env.dev',
        Flavor.qa => '.env.qa',
        Flavor.prod => '.env.prod',
      };
}
