import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/profile/presentation/items/profile_card_item.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/profile_card_tile.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('ProfileCardTile Widget Tests', () {
    testWidgets('should render icon, title, and arrow by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      final item = ProfileCardItem(
        icon: Icons.language_rounded,
        title: AppStrings.language,
      );

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(child: ProfileCardTile(item: item)),
      );
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.language_rounded), findsOneWidget);
      expect(find.text(AppStrings.language), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    });

    testWidgets('should render trailingText when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      const item = ProfileCardItem(
        icon: Icons.language_rounded,
        title: 'اللغة',
        trailingText: 'العربية',
      );

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(child: const ProfileCardTile(item: item)),
      );
      await tester.pump();

      // Assert
      expect(find.text('العربية'), findsOneWidget);
    });

    testWidgets('should render trailingWidget when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      const item = ProfileCardItem(
        icon: Icons.dark_mode_outlined,
        title: 'الوضع الليلي',
        trailingWidget: Icon(Icons.check, key: Key('trailing_icon')),
      );

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(child: const ProfileCardTile(item: item)),
      );
      await tester.pump();

      // Assert
      expect(find.byKey(const Key('trailing_icon')), findsOneWidget);
    });

    testWidgets('should hide arrow when showArrow is false', (
      WidgetTester tester,
    ) async {
      // Arrange
      const item = ProfileCardItem(
        icon: Icons.dark_mode_outlined,
        title: 'الوضع الليلي',
        showArrow: false,
      );

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(child: const ProfileCardTile(item: item)),
      );
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNothing);
    });

    testWidgets('should trigger onTap callback when clicked', (
      WidgetTester tester,
    ) async {
      // Arrange
      var tapped = false;
      final item = ProfileCardItem(
        icon: Icons.person_outline_rounded,
        title: 'الملف الشخصي',
        onTap: () => tapped = true,
      );

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(child: ProfileCardTile(item: item)),
      );
      await tester.pump();

      await tester.tap(find.byType(ProfileCardTile));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });
  });
}
