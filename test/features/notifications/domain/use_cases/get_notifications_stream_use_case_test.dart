import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/notifications/domain/entities/notification_entity.dart';
import 'package:fruit_hub/features/notifications/domain/repo/notifications_repo.dart';
import 'package:fruit_hub/features/notifications/domain/use_cases/get_notifications_stream_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRepo extends Mock implements NotificationsRepo {}

void main() {
  late MockNotificationsRepo mockNotificationsRepo;
  late GetNotificationsStreamUseCase sut;

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

  const tFailure = ServerFailure(error: 'Failed to fetch notifications');

  setUp(() {
    mockNotificationsRepo = MockNotificationsRepo();
    sut = GetNotificationsStreamUseCase(mockNotificationsRepo);
  });

  group('GetNotificationsStreamUseCase', () {
    test('should forward stream from repo and emit NetworkSuccess<List<NotificationEntity>> when repo succeeds', () async {
      // Arrange
      when(() => mockNotificationsRepo.getNotificationsStream()).thenAnswer(
        (_) => Stream.value(NetworkSuccess([tNotification1, tNotification2])),
      );

      // Act & Assert
      await expectLater(
        sut(),
        emits(
          isA<NetworkSuccess<List<NotificationEntity>>>().having(
            (res) => res.data,
            'data',
            [tNotification1, tNotification2],
          ),
        ),
      );
      verify(() => mockNotificationsRepo.getNotificationsStream()).called(1);
      verifyNoMoreInteractions(mockNotificationsRepo);
    });

    test('should forward stream from repo and emit NetworkFailure<List<NotificationEntity>> when repo emits failure', () async {
      // Arrange
      when(() => mockNotificationsRepo.getNotificationsStream())
          .thenAnswer((_) => Stream.value(const NetworkFailure(tFailure)));

      // Act & Assert
      await expectLater(
        sut(),
        emits(
          isA<NetworkFailure<List<NotificationEntity>>>().having(
            (res) => res.failure.error,
            'error',
            tFailure.error,
          ),
        ),
      );
      verify(() => mockNotificationsRepo.getNotificationsStream()).called(1);
      verifyNoMoreInteractions(mockNotificationsRepo);
    });

    test(
      'should emit real-time updates when repo stream emits multiple responses',
      () async {
        // Arrange
        final controller =
            StreamController<NetworkResponse<List<NotificationEntity>>>();
        when(() => mockNotificationsRepo.getNotificationsStream())
            .thenAnswer((_) => controller.stream);

        // Act & Assert
        final expectation = expectLater(
          sut(),
          emitsInOrder([
            isA<NetworkSuccess<List<NotificationEntity>>>().having(
              (res) => res.data,
              'data',
              [tNotification1],
            ),
            isA<NetworkSuccess<List<NotificationEntity>>>().having(
              (res) => res.data,
              'data',
              [tNotification1, tNotification2],
            ),
          ]),
        );

        controller.add(NetworkSuccess([tNotification1]));
        controller.add(NetworkSuccess([tNotification1, tNotification2]));

        await expectation;
        await controller.close();
        verify(() => mockNotificationsRepo.getNotificationsStream()).called(1);
        verifyNoMoreInteractions(mockNotificationsRepo);
      },
    );
  });
}
