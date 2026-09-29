import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/notification_widget.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_home_app_bar.dart';
import 'package:fruit_hub/features/notifications/domain/entities/notification_entity.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_cubit.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_state.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_avatar_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

void main() {
  late MockUserInfoCubit mockUserInfoCubit;
  late MockNotificationsCubit mockNotificationsCubit;

  const tUser = UserEntity(
    uid: 'user_123',
    name: 'أحمد علي',
    email: 'ahmed@example.com',
  );

  const tUnreadNotification = NotificationEntity(
    id: 'notif_1',
    title: 'تنبيه',
    body: 'محتوى التنبيه',
    type: NotificationType.general,
    isRead: false,
  );

  setUp(() {
    mockUserInfoCubit = MockUserInfoCubit();
    mockNotificationsCubit = MockNotificationsCubit();

    when(() => mockUserInfoCubit.state).thenReturn(UserInfoInitial());
    when(() => mockUserInfoCubit.currentUser).thenReturn(tUser);

    when(() => mockNotificationsCubit.state)
        .thenReturn(const NotificationsInitial());
  });

  tearDown(() {
    mockUserInfoCubit.close();
    mockNotificationsCubit.close();
  });

  Widget buildTestWidget({NavigatorObserver? navigatorObserver}) =>
      createWidgetForTesting(
        navigatorObserver: navigatorObserver,
        routes: {
          Routes.notificationsView: (context) =>
              const Scaffold(body: Text('Notifications Screen')),
        },
        child: MultiBlocProvider(
          providers: [
            BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
            BlocProvider<NotificationsCubit>.value(
              value: mockNotificationsCubit,
            ),
          ],
          child: const CustomHomeAppBar(),
        ),
      );

  group('CustomHomeAppBar Widget Tests', () {
    testWidgets('should render greeting and user name when user is logged in', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppStrings.greeting), findsOneWidget);
      expect(find.text(tUser.name), findsOneWidget);
      expect(find.byType(UserAvatarWidget), findsOneWidget);
      expect(find.byType(NotificationWidget), findsOneWidget);
    });

    testWidgets('should render empty string for user name when user is null', (
      tester,
    ) async {
      // Arrange
      when(() => mockUserInfoCubit.currentUser).thenReturn(null);

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppStrings.greeting), findsOneWidget);
      expect(find.text(tUser.name), findsNothing);
      expect(find.byType(UserAvatarWidget), findsOneWidget);
    });

    testWidgets(
      'should render notification badge with count when unreadCount > 0',
      (tester) async {
        // Arrange
        when(() => mockNotificationsCubit.state).thenReturn(
          const NotificationsSuccess([
            tUnreadNotification,
            tUnreadNotification,
            tUnreadNotification,
          ]),
        );

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('3'), findsOneWidget);
      },
    );

    testWidgets('should not render notification badge when unreadCount is 0', (
      tester,
    ) async {
      // Arrange
      when(() => mockNotificationsCubit.state)
          .thenReturn(const NotificationsSuccess([]));

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('0'), findsNothing);
    });

    testWidgets(
      'should navigate to notificationsView when notification icon is tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byType(NotificationWidget));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Notifications Screen'), findsOneWidget);
      },
    );
  });
}
