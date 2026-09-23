import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/notifications/domain/entities/notification_entity.dart';
import 'package:fruit_hub/features/notifications/domain/use_cases/get_notifications_stream_use_case.dart';
import 'package:fruit_hub/features/notifications/domain/use_cases/mark_all_notifications_as_read_use_case.dart';
import 'package:fruit_hub/features/notifications/domain/use_cases/mark_notification_as_read_use_case.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_cubit.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetNotificationsStreamUseCase extends Mock
    implements GetNotificationsStreamUseCase {}

class MockMarkNotificationAsReadUseCase extends Mock
    implements MarkNotificationAsReadUseCase {}

class MockMarkAllNotificationsAsReadUseCase extends Mock
    implements MarkAllNotificationsAsReadUseCase {}

void main() {
  late MockGetNotificationsStreamUseCase mockGetNotificationsStreamUseCase;
  late MockMarkNotificationAsReadUseCase mockMarkNotificationAsReadUseCase;
  late MockMarkAllNotificationsAsReadUseCase
  mockMarkAllNotificationsAsReadUseCase;
  late NotificationsCubit sut;

  final tDate = DateTime(2026, 9, 20, 10, 0);

  final tNotification1 = NotificationEntity(
    id: 'notif_1',
    title: 'تم شحن طلبك',
    body: 'طلبك في الطريق إليك الآن',
    titleAr: 'تم شحن طلبك',
    titleEn: 'Your order has been shipped',
    bodyAr: 'طلبك في الطريق إليك الآن',
    bodyEn: 'Your order is on the way',
    type: NotificationType.order,
    isRead: false,
    orderId: '1001',
    status: 'shipped',
    createdAt: tDate,
  );

  final tNotification2 = NotificationEntity(
    id: 'notif_2',
    title: 'خصم خاص',
    body: 'احصل على خصم 20%',
    titleAr: 'خصم خاص',
    titleEn: 'Special Discount',
    bodyAr: 'احصل على خصم 20%',
    bodyEn: 'Get 20% off',
    type: NotificationType.general,
    isRead: true,
    productCode: 'APPLE_01',
    createdAt: tDate,
  );

  final tServerFailure = ServerFailure(error: AppStrings.userNotFound);

  setUp(() {
    mockGetNotificationsStreamUseCase = MockGetNotificationsStreamUseCase();
    mockMarkNotificationAsReadUseCase = MockMarkNotificationAsReadUseCase();
    mockMarkAllNotificationsAsReadUseCase =
        MockMarkAllNotificationsAsReadUseCase();

    sut = NotificationsCubit(
      getNotificationsStreamUseCase: mockGetNotificationsStreamUseCase,
      markNotificationAsReadUseCase: mockMarkNotificationAsReadUseCase,
      markAllNotificationsAsReadUseCase: mockMarkAllNotificationsAsReadUseCase,
    );
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be NotificationsInitial', () {
    // Assert
    expect(sut.state, const NotificationsInitial());
  });

  group('initNotificationsStream', () {
    blocTest<NotificationsCubit, NotificationsState>(
      'should emit [NotificationsLoading, NotificationsSuccess] when use case emits NetworkSuccess',
      build: () {
        when(() => mockGetNotificationsStreamUseCase())
            .thenAnswer((_) => Stream.value(NetworkSuccess([tNotification1])));
        return sut;
      },
      act: (cubit) => cubit.initNotificationsStream(),
      expect: () => [
        const NotificationsLoading(),
        NotificationsSuccess([tNotification1]),
      ],
      verify: (_) {
        verify(() => mockGetNotificationsStreamUseCase()).called(1);
      },
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'should emit [NotificationsLoading, NotificationsFailure] when use case emits NetworkFailure',
      build: () {
        when(() => mockGetNotificationsStreamUseCase())
            .thenAnswer((_) => Stream.value(NetworkFailure(tServerFailure)));
        return sut;
      },
      act: (cubit) => cubit.initNotificationsStream(),
      expect: () => [
        const NotificationsLoading(),
        NotificationsFailure(tServerFailure.error),
      ],
      verify: (_) {
        verify(() => mockGetNotificationsStreamUseCase()).called(1);
      },
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'should emit [NotificationsLoading, NotificationsFailure] when stream throws error via onError',
      build: () {
        when(() => mockGetNotificationsStreamUseCase())
            .thenAnswer((_) => Stream.error(Exception('Connection error')));
        return sut;
      },
      act: (cubit) => cubit.initNotificationsStream(),
      expect: () => [
        const NotificationsLoading(),
        isA<NotificationsFailure>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('Connection error'),
        ),
      ],
      verify: (_) {
        verify(() => mockGetNotificationsStreamUseCase()).called(1);
      },
    );

    test('should emit multiple NotificationsSuccess states in real-time when stream emits updates', () async {
      // Arrange
      final controller =
          StreamController<NetworkResponse<List<NotificationEntity>>>();
      when(() => mockGetNotificationsStreamUseCase())
          .thenAnswer((_) => controller.stream);

      final states = <NotificationsState>[];
      final subscription = sut.stream.listen(states.add);

      // Act
      sut.initNotificationsStream();
      await pumpEventQueue();

      controller.add(NetworkSuccess([tNotification1]));
      await pumpEventQueue();

      controller.add(NetworkSuccess([tNotification1, tNotification2]));
      await pumpEventQueue();

      // Assert
      expect(states, [
        const NotificationsLoading(),
        NotificationsSuccess([tNotification1]),
        NotificationsSuccess([tNotification1, tNotification2]),
      ]);

      await controller.close();
      await subscription.cancel();
    });

    test('NotificationsSuccess unreadCount should return correct count of unread items', () {
      // Arrange & Act
      final successState = NotificationsSuccess([
        tNotification1,
        tNotification2,
      ]);

      // Assert
      expect(successState.unreadCount, 1);
    });
  });

  group('markAsRead', () {
    const tNotifId = 'notif_1';

    test(
      'should delegate to markNotificationAsReadUseCase with notificationId',
      () async {
        // Arrange
        when(() => mockMarkNotificationAsReadUseCase(tNotifId))
            .thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        await sut.markAsRead(tNotifId);

        // Assert
        verify(() => mockMarkNotificationAsReadUseCase(tNotifId)).called(1);
        verifyNoMoreInteractions(mockMarkNotificationAsReadUseCase);
      },
    );
  });

  group('markAllAsRead', () {
    test('should delegate to markAllNotificationsAsReadUseCase', () async {
      // Arrange
      when(() => mockMarkAllNotificationsAsReadUseCase())
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      await sut.markAllAsRead();

      // Assert
      verify(() => mockMarkAllNotificationsAsReadUseCase()).called(1);
      verifyNoMoreInteractions(mockMarkAllNotificationsAsReadUseCase);
    });
  });
}
