import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/portfolio/presentation/cubit/target_alert_edit_cubit.dart';

void main() {
  test('hasChanged is false until the draft differs from the snapshot', () {
    final cubit = TargetAlertEditCubit()..begin('AAA', 310);
    expect(cubit.state.hasChanged, isFalse);
    cubit.setDraft('310');
    expect(cubit.state.hasChanged, isFalse);
    cubit.setDraft('320');
    expect(cubit.state.hasChanged, isTrue);
    cubit.close();
  });
}
