import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecircle/shared/widgets/custom_button.dart';
import 'package:safecircle/shared/widgets/trusted_contact_card.dart';
import 'package:safecircle/data/models/contact_model.dart';

void main() {
  group('Design System Widget Tests', () {
    testWidgets('CustomButton renders text and triggers callback when pressed',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Action',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Action'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('CustomButton renders loading indicator when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Test',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Test'), findsNothing);
    });

    testWidgets('TrustedContactCard renders contact name and details correctly',
        (WidgetTester tester) async {
      final testContact = ContactModel(
        id: 'c_test_1',
        name: 'Sarah Connor',
        phone: '+1 555-0192',
        email: 'sarah@example.com',
        relationship: 'Sister',
        addedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: TrustedContactCard(
              contact: testContact,
            ),
          ),
        ),
      );

      expect(find.text('Sarah Connor'), findsOneWidget);
      expect(find.text('+1 555-0192'), findsOneWidget);
      expect(find.text('Sister'), findsOneWidget);
      expect(find.text('S'), findsOneWidget); // Initial avatar
    });
  });
}
