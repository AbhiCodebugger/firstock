import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/shared/wrappers/skeleton_wrapper.dart';

void main() {
  testWidgets('passes isLoading true through to the wrapper', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SkeletonWrapper(isLoading: true, child: Text('Holdings')),
      ),
    );

    expect(
      tester.widget<SkeletonWrapper>(find.byType(SkeletonWrapper)).isLoading,
      isTrue,
    );
  });

  testWidgets('keeps isLoading false when the book is ready', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SkeletonWrapper(isLoading: false, child: Text('Holdings')),
      ),
    );

    expect(
      tester.widget<SkeletonWrapper>(find.byType(SkeletonWrapper)).isLoading,
      isFalse,
    );
  });
}
