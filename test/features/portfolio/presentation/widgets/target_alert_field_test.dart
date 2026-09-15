import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/core/money/inr_format.dart';
import 'package:mindorigin/src/features/portfolio/presentation/cubit/target_alert_edit_cubit.dart';
import 'package:mindorigin/src/features/portfolio/presentation/widgets/target_alert_field.dart';
import 'package:mindorigin/src/shared/widgets/app_button.dart';
import 'package:mindorigin/src/theme/color_schemes.dart';

void main() {
  Future<void> pumpAlert(
    WidgetTester tester, {
    double? savedAlert,
  }) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: stitchDarkScheme(),
              extensions: const [AppPalettes.dark],
            ),
            home: BlocProvider(
              create: (_) => TargetAlertEditCubit(),
              child: Scaffold(
                body: TargetAlertField(
                  ticker: 'ZOMATO',
                  savedAlert: savedAlert,
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the stitch title, pill badge, and compact save', (
    tester,
  ) async {
    await pumpAlert(tester, savedAlert: 310);

    expect(find.text('dashboard.target_alert'), findsOneWidget);
    expect(
      find.text('dashboard.active_alert'),
      findsOneWidget,
    );
    expect(find.text('dashboard.save_alert'), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
    expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(formatInr(310, decimals: 0), '₹310');
  });

  testWidgets('empty alert still renders the active badge', (tester) async {
    await pumpAlert(tester);

    expect(find.text('dashboard.active_alert'), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
  });
}
