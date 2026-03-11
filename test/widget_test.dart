// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aiu_church_program_bulletin/main.dart';

void main() {
  testWidgets('App loads and displays Program tab', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app bar title is displayed.
    // Use the exact title string from main.dart or home_screen.dart
    expect(find.text('Church Bulletin'), findsOneWidget);

    // Verify that the Program tab is selected by default and displays content.
    expect(find.text('Program'), findsOneWidget);
    expect(find.byIcon(Icons.list_alt), findsOneWidget);
  });
}
