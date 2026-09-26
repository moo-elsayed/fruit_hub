import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('TextFormFieldHelper Widget Tests', () {
    testWidgets('should render hint text and label text correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const TextFormFieldHelper(
            hint: 'Enter your email',
            labelText: 'Email',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should trigger onChanged and detect text direction on input', (
      WidgetTester tester,
    ) async {
      // Arrange
      String changedText = '';

      await tester.pumpWidget(
        createWidgetForTesting(
          child: TextFormFieldHelper(
            onChanged: (val) => changedText = val ?? '',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act 1 - Enter English text
      await tester.enterText(find.byType(TextFormField), 'Apple');
      await tester.pumpAndSettle();

      // Assert 1
      expect(changedText, equals('Apple'));
      var textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textDirection, equals(TextDirection.ltr));

      // Act 2 - Enter Arabic text
      await tester.enterText(find.byType(TextFormField), 'تفاح');
      await tester.pumpAndSettle();

      // Assert 2
      expect(changedText, equals('تفاح'));
      textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textDirection, equals(TextDirection.rtl));
    });

    testWidgets('should toggle password visibility when isPassword is true', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const TextFormFieldHelper(isPassword: true, hint: 'Password'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Initially visibility_outlined is shown (obscured)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      // Act - Tap toggle icon
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      // Assert - Now visibility_off_outlined is shown (visible)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });

    testWidgets(
      'should display validation error message when validator returns an error string',
      (WidgetTester tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          createWidgetForTesting(
            child: Form(
              key: formKey,
              child: TextFormFieldHelper(
                onValidate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        formKey.currentState!.validate();
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Field is required'), findsOneWidget);
      },
    );

    testWidgets('should render prefixIcon, suffixWidget, and suffixText', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const TextFormFieldHelper(
            prefixIcon: Icon(Icons.email),
            suffixWidget: Icon(Icons.check),
            suffixText: 'EGP',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('EGP'), findsOneWidget);
    });

    testWidgets('should respect readOnly and trigger onTap callback', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        createWidgetForTesting(
          child: TextFormFieldHelper(
            readOnly: true,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.readOnly, isTrue);

      // Act
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });
  });
}
