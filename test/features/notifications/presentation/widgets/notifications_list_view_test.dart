import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/features/notifications/domain/entities/notification_entity.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_cubit.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_state.dart';
import 'package:fruit_hub/features/notifications/presentation/widgets/notification_item_widget.dart';
import 'package:fruit_hub/features/notifications/presentation/widgets/notifications_list_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

void main() {
  late MockNotificationsCubit mockNotificationsCubit;

  const tNotifications = [
    NotificationEntity(
      id: 'notif_1',
      title: 'First Notification',
      body: 'Body of first notification',
      type: NotificationType.general,
      isRead: false,
    ),
    NotificationEntity(
      id: 'notif_2',
      title: 'Second Notification',
      body: 'Body of second notification',
      type: NotificationType.general,
      isRead: true,
    ),
  ];

  setUp(() {
    mockNotificationsCubit = MockNotificationsCubit();
    when(() => mockNotificationsCubit.markAsRead(any()))
        .thenAnswer((_) async {});
  });

  tearDown(() {
    mockNotificationsCubit.close();
  });

  group('NotificationsListView Widget Tests', () {
    testWidgets('should render all notification items in list', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: BlocProvider<NotificationsCubit>.value(
            value: mockNotificationsCubit,
            child: const NotificationsListView(notifications: tNotifications),
          ),
        ),
      );

      // Assert
      expect(find.byType(NotificationItemWidget), findsNWidgets(2));
      expect(find.text('First Notification'), findsOneWidget);
      expect(find.text('Second Notification'), findsOneWidget);
    });

    testWidgets(
      'should call markAsRead on NotificationsCubit when an item is tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(
            child: BlocProvider<NotificationsCubit>.value(
              value: mockNotificationsCubit,
              child: const NotificationsListView(notifications: tNotifications),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('First Notification'));
        await tester.pump();

        // Assert
        verify(() => mockNotificationsCubit.markAsRead('notif_1')).called(1);
      },
    );
  });
}
