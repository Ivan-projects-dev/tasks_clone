import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasks_clone/main.dart';

void main() {
  testWidgets('Tasks app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Google Tasks Clone'), findsOneWidget);
    expect(find.text('No tasks yet! Add some tasks.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add Task'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Test Task');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Test Task'), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    final completedTask = find.text('Test Task', findRichText: true);
    expect(completedTask, findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    expect(find.text('Test Task'), findsNothing);
  });
}