// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fenglingmusic/main.dart';

void main() {
  testWidgets('Home hub renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('FENGLING'), findsOneWidget);
    expect(find.text('MUSIC'), findsOneWidget);

    // A couple of key destinations.
    expect(find.text('PLAYLISTS'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('SETTINGS'), findsOneWidget);
  });
}
