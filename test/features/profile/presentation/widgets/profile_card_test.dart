import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/profile_card.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/profile_card_tile.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('ProfileCard Widget Tests', () {
    testWidgets('should render all items and dividers between them', (
      WidgetTester tester,
    ) async {
      // Arrange
      final items = [
        const ProfileCardItem(icon: Icons.person, title: 'Item 1'),
        const ProfileCardItem(icon: Icons.settings, title: 'Item 2'),
        const ProfileCardItem(icon: Icons.info, title: 'Item 3'),
      ];

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(child: ProfileCard(items: items)),
      );
      await tester.pump();

      // Assert
      expect(find.byType(ProfileCardTile), findsNWidgets(3));
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('should render 0 dividers when only 1 item is passed', (
      WidgetTester tester,
    ) async {
      // Arrange
      final items = [
        const ProfileCardItem(icon: Icons.person, title: 'Solo Item'),
      ];

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(child: ProfileCard(items: items)),
      );
      await tester.pump();

      // Assert
      expect(find.byType(ProfileCardTile), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
    });
  });
}
