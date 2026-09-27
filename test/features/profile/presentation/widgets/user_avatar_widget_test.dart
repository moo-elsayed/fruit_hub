import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_avatar_widget.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('UserAvatarWidget Tests', () {
    testWidgets('should render fallback person icon when imagePath is null', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(child: const UserAvatarWidget(imagePath: null)),
      );
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets(
      'should render fallback person icon when imagePath is empty or whitespace',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const UserAvatarWidget(imagePath: '   '),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.person_rounded), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);
      },
    );

    testWidgets(
      'should render CachedNetworkImage when imagePath starts with http',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const UserAvatarWidget(
              imagePath: 'https://example.com/user.jpg',
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CachedNetworkImage), findsOneWidget);
        final cachedImage = tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        );
        expect(cachedImage.imageUrl, 'https://example.com/user.jpg');
      },
    );

    testWidgets(
      'should render Image widget when imagePath is a local file path',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const UserAvatarWidget(
              imagePath: '/data/user/0/cache/avatar.png',
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets('should respect custom size dimensions', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const UserAvatarWidget(imagePath: null, size: 80),
        ),
      );
      await tester.pump();

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.minWidth, closeTo(80.r, 0.1));
      expect(container.constraints?.minHeight, closeTo(80.r, 0.1));
    });
  });
}
