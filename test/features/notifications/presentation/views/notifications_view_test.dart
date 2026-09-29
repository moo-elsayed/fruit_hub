import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/features/notifications/domain/entities/notification_entity.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_cubit.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_state.dart';
import 'package:fruit_hub/features/notifications/presentation/views/notifications_view.dart';
import 'package:fruit_hub/features/notifications/presentation/widgets/notifications_list_view.dart';
import 'package:fruit_hub/features/notifications/presentation/widgets/notifications_loading_skeleton.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

void main() {
  late MockNotificationsCubit mockNotificationsCubit;

  const tUnreadNotification = NotificationEntity(
    id: 'n1',
    title: 'New Offer',
    body: 'Discount available now',
    type: NotificationType.general,
    isRead: false,
  );

  const tReadNotification = NotificationEntity(
    id: 'n2',
    title: 'Order Status',
    body: 'Your order was delivered',
    type: NotificationType.order,
    isRead: true,
  );

  setUp(() {
    mockNotificationsCubit = MockNotificationsCubit();
    when(() => mockNotificationsCubit.markAllAsRead()).thenAnswer((_) async {});
  });

  tearDown(() {
    mockNotificationsCubit.close();
  });

  Widget buildTestWidget() => createWidgetForTesting(
    child: BlocProvider<NotificationsCubit>.value(
      value: mockNotificationsCubit,
      child: const NotificationsView(),
    ),
  );

  group('NotificationsView Widget Tests', () {
    testWidgets(
      'should render CustomAppBar with notifications title and back button',
      (tester) async {
        // Arrange
        when(() => mockNotificationsCubit.state)
            .thenReturn(const NotificationsInitial());

        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.text(AppStrings.notifications), findsOneWidget);
        expect(find.byType(CustomArrowBack), findsOneWidget);
      },
    );

    testWidgets(
      'should render NotificationsLoadingSkeleton when state is NotificationsLoading',
      (tester) async {
        // Arrange
        when(() => mockNotificationsCubit.state)
            .thenReturn(const NotificationsLoading());

        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(NotificationsLoadingSkeleton), findsOneWidget);
      },
    );

    testWidgets(
      'should render CustomEmptyStateWidget when state is NotificationsSuccess with empty list',
      (tester) async {
        // Arrange
        when(() => mockNotificationsCubit.state)
            .thenReturn(const NotificationsSuccess([]));

        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(CustomEmptyStateWidget), findsOneWidget);
        expect(find.text(AppStrings.noNotifications), findsOneWidget);
        expect(find.text(AppStrings.noNotificationsDesc), findsOneWidget);
        expect(find.byType(NotificationsListView), findsNothing);
      },
    );

    testWidgets(
      'should render NotificationsListView and markAllAsRead when there are unread items',
      (tester) async {
        // Arrange
        when(() => mockNotificationsCubit.state).thenReturn(
          const NotificationsSuccess([tUnreadNotification, tReadNotification]),
        );

        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(NotificationsListView), findsOneWidget);
        expect(find.text(AppStrings.markAllAsRead), findsOneWidget);
        expect(find.text('New Offer'), findsOneWidget);
      },
    );

    testWidgets(
      'should not render markAllAsRead when all notifications are read',
      (tester) async {
        // Arrange
        when(() => mockNotificationsCubit.state)
            .thenReturn(const NotificationsSuccess([tReadNotification]));

        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(NotificationsListView), findsOneWidget);
        expect(find.text(AppStrings.markAllAsRead), findsNothing);
      },
    );

    testWidgets(
      'should call markAllAsRead on cubit when markAllAsRead action is tapped',
      (tester) async {
        // Arrange
        when(() => mockNotificationsCubit.state)
            .thenReturn(const NotificationsSuccess([tUnreadNotification]));

        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.tap(find.text(AppStrings.markAllAsRead));
        await tester.pump();

        // Assert
        verify(() => mockNotificationsCubit.markAllAsRead()).called(1);
      },
    );

    testWidgets('should pop NotificationsView when back arrow is tapped', (
      tester,
    ) async {
      // Arrange
      when(() => mockNotificationsCubit.state)
          .thenReturn(const NotificationsInitial());

      await tester.pumpWidget(
        createWidgetForTesting(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider<NotificationsCubit>.value(
                    value: mockNotificationsCubit,
                    child: const NotificationsView(),
                  ),
                ),
              ),
              child: const Text('Open Notifications'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open NotificationsView
      await tester.tap(find.text('Open Notifications'));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsView), findsOneWidget);

      // Act - Tap back arrow
      await tester.tap(find.byType(CustomArrowBack));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NotificationsView), findsNothing);
      expect(find.text('Open Notifications'), findsOneWidget);
    });
  });
}
