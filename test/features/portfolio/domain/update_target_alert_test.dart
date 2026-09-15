import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/portfolio/data/holdings_repository_impl.dart';
import 'package:mindorigin/src/features/portfolio/domain/entities/holding.dart';
import 'package:mindorigin/src/features/portfolio/domain/usecases/update_target_alert.dart';

void main() {
  test('skips repository when snapshot equals draft', () async {
    final repo = HoldingsRepositoryImpl(
      seed: const [
        Holding(
          ticker: 'AAA',
          company: 'Alpha',
          exchange: 'NSE',
          monogram: 'ALP',
          quantity: 1,
          avgBuyPrice: 10,
          previousClose: 10,
          targetAlert: 12,
        ),
      ],
    );
    final useCase = UpdateTargetAlert(repo);
    final wrote = await useCase(ticker: 'AAA', value: 12, snapshot: 12);
    expect(wrote, isFalse);
    expect((await repo.load()).single.targetAlert, 12);
  });

  test('writes when the draft differs', () async {
    final repo = HoldingsRepositoryImpl(
      seed: const [
        Holding(
          ticker: 'AAA',
          company: 'Alpha',
          exchange: 'NSE',
          monogram: 'ALP',
          quantity: 1,
          avgBuyPrice: 10,
          previousClose: 10,
          targetAlert: 12,
        ),
      ],
    );
    final useCase = UpdateTargetAlert(repo);
    final wrote = await useCase(ticker: 'AAA', value: 15, snapshot: 12);
    expect(wrote, isTrue);
    expect((await repo.load()).single.targetAlert, 15);
  });
}
