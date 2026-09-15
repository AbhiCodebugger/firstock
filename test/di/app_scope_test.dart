import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/di/app_scope.dart';
import 'package:mindorigin/src/features/theme/domain/repositories/theme_repository.dart';
import 'package:mindorigin/src/flavors.dart';

import '../support/fake_price_feed.dart';

class _FakeThemeRepository implements ThemeRepository {
  @override
  Future<String?> loadMode() async => 'light';

  @override
  Future<void> saveMode(String mode) async {}
}

void main() {
  test('AppScope.create wires seven root providers and the given feed', () async {
    FlavorConfig.load(Flavor.dev);
    final feed = FakePriceFeed();
    addTearDown(feed.dispose);

    final scope = await AppScope.create(
      themeRepository: _FakeThemeRepository(),
      feed: feed,
    );

    expect(scope.feed, same(feed));
    expect(scope.providers, hasLength(7));

    final types = scope.providers
        .map((provider) => provider.runtimeType.toString())
        .join(' ');
    expect(types, contains('ThemeCubit'));
    expect(types, contains('HoldingsUiCubit'));
    expect(types, contains('HoldingsCubit'));
    expect(types, contains('ChartCubit'));
    expect(types, contains('TargetAlertEditCubit'));
    expect(types, contains('LivePricesCubit'));
    expect(types, contains('ConnectionCubit'));
  });
}
