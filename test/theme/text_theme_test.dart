import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/portfolio/presentation/widgets/summary_metric_card.dart';
import 'package:mindorigin/src/theme/color_schemes.dart';
import 'package:mindorigin/src/theme/text_theme.dart';

void main() {
  test('withOnSurfaceInk paints titles and body with on-surface', () {
    final scheme = stitchDarkScheme();
    final painted =
        withOnSurfaceInk(ThemeData.light().textTheme, scheme.onSurface);

    expect(painted.titleMedium?.color, scheme.onSurface);
    expect(painted.bodyMedium?.color, scheme.onSurface);
    expect(painted.labelSmall?.color, scheme.onSurface);
    expect(painted.headlineSmall?.color, scheme.onSurface);
  });

  test('withOnSurfaceInk uses light on-surface on the light scheme', () {
    final scheme = stitchLightScheme();
    final painted =
        withOnSurfaceInk(ThemeData.light().textTheme, scheme.onSurface);

    expect(painted.titleMedium?.color, scheme.onSurface);
    expect(painted.bodyMedium?.color, scheme.onSurface);
  });

  testWidgets('metric card copy uses stitch on-surface roles in dark mode', (
    tester,
  ) async {
    final scheme = stitchDarkScheme();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: scheme,
              extensions: const [AppPalettes.dark],
            ),
            home: const Scaffold(
              body: SummaryMetricCard(
                label: 'Total Invested',
                value: '₹1,00,000',
                subtitle: 'Across 8 equities',
              ),
            ),
          );
        },
      ),
    );

    expect(
      tester.widget<Text>(find.text('TOTAL INVESTED')).style?.color,
      scheme.onSurfaceVariant,
    );
    expect(
      tester.widget<Text>(find.text('₹1,00,000')).style?.color,
      scheme.onSurface,
    );
    expect(
      tester.widget<Text>(find.text('Across 8 equities')).style?.color,
      scheme.onSurfaceVariant,
    );
  });
}
