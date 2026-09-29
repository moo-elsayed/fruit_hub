import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });
  group('DateTimeExtension Tests', () {
    test('toFormattedDate should format DateTime to dd/MM/yyyy by default', () {
      final dateTime = DateTime(2026, 9, 28, 14, 30);
      expect(dateTime.toFormattedDate(), equals('28/09/2026'));
    });

    test('toFormattedDate should format DateTime with custom pattern', () {
      final dateTime = DateTime(2026, 9, 28, 14, 30);
      expect(
        dateTime.toFormattedDate(pattern: 'yyyy-MM-dd'),
        equals('2026-09-28'),
      );
    });

    testWidgets('toLocalizedDate should format DateTime with context locale', (
      tester,
    ) async {
      final dateTime = DateTime(2026, 9, 28);
      String? result;

      await tester.pumpWidget(
        createWidgetForTesting(
          locale: const Locale('en'),
          child: Builder(
            builder: (context) {
              result = dateTime.toLocalizedDate(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(result, isNotNull);
      expect(result, contains('September 28, 2026'));
    });
  });

  group('StringDateExtension Tests', () {
    test('toDateTime should parse valid ISO 8601 string', () {
      const dateStr = '2026-09-28T10:00:00.000Z';
      final parsed = dateStr.toDateTime;
      expect(parsed, isNotNull);
      expect(parsed!.year, equals(2026));
      expect(parsed.month, equals(9));
      expect(parsed.day, equals(28));
    });

    test('toDateTime should return null for invalid date string', () {
      const invalid = 'not-a-date';
      expect(invalid.toDateTime, isNull);
    });

    test('toFormattedDate should format valid ISO string to dd/MM/yyyy', () {
      const dateStr = '2026-09-28T10:00:00.000Z';
      expect(dateStr.toFormattedDate(), equals('28/09/2026'));
    });

    test('toFormattedDate should return empty string if input is empty', () {
      expect(''.toFormattedDate(), equals(''));
    });

    test(
      'toFormattedDate should return fallback if string is not parseable',
      () {
        const unparseable = 'invalid_date_sample';
        expect(unparseable.toFormattedDate(), equals('invalid_da'));
      },
    );

    testWidgets(
      'toLocalizedDate should format valid date string with context locale',
      (tester) async {
        const dateStr = '2026-09-28T10:00:00.000Z';
        String? result;

        await tester.pumpWidget(
          createWidgetForTesting(
            locale: const Locale('en'),
            child: Builder(
              builder: (context) {
                result = dateStr.toLocalizedDate(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isNotNull);
        expect(result, contains('September 28, 2026'));
      },
    );

    testWidgets(
      'toLocalizedDate should return empty string if input is empty',
      (tester) async {
        String? result;

        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) {
                result = ''.toLocalizedDate(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, equals(''));
      },
    );
  });
}
