import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms/widgets/custom_widgets.dart';

void main() {
  testWidgets('CustomTextField renders correctly', (WidgetTester tester) async {
    final controller = TextEditingController();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: controller,
            label: 'Test Label',
            prefixIcon: Icons.email,
          ),
        ),
      ),
    );

    // Verify label is rendered
    expect(find.text('Test Label'), findsOneWidget);
    
    // Verify icon is rendered
    expect(find.byIcon(Icons.email), findsOneWidget);
    
    // Enter text
    await tester.enterText(find.byType(TextField), 'Hello World');
    expect(controller.text, 'Hello World');
  });

  testWidgets('CustomTextField handles password visibility', (WidgetTester tester) async {
    final controller = TextEditingController();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: controller,
            label: 'Password',
            prefixIcon: Icons.lock,
            isPassword: true,
          ),
        ),
      ),
    );

    // Initial state should be obscured (visibility icon off)
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    
    // Tap the visibility toggle
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    
    // Now it should show visibility icon on
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });
}
