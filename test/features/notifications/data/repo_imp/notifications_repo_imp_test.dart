import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/notifications/data/data_sources/remote/notifications_remote_data_source.dart';
import 'package:fruit_hub/features/notifications/data/models/notification_model.dart';
import 'package:fruit_hub/features/notifications/data/repo_imp/notifications_repo_imp.dart';
import 'package:fruit_hub/features/notifications/domain/entities/notification_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRemoteDataSource extends Mock
    implements NotificationsRemoteDataSource {}

void main() {
  late MockNotificationsRemoteDataSource mockNotificationsRemoteDataSource;
  late NotificationsRepoImp sut;

  final tDate = DateTime(2026, 9, 20, 10, 0);

  final tNotificationModel1 = NotificationModel(
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

  final tNotificationModel2 = NotificationModel(
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

  final tNotificationEntity1 = NotificationEntity(
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

  final tNotificationEntity2 = NotificationEntity(
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

  setUp(() {
    mockNotificationsRemoteDataSource = MockNotificationsRemoteDataSource();
    sut = NotificationsRepoImp(mockNotificationsRemoteDataSource);
  });

  group('getNotificationsStream', () {
    test('should emit NetworkSuccess with mapped entities when remoteDataSource emits list of NotificationModels', () async {
      // Arrange
      when(() => mockNotificationsRemoteDataSource.getNotificationsStream())
          .thenAnswer(
            (_) => Stream.value([tNotificationModel1, tNotificationModel2]),
          );

      // Act
      final stream = sut.getNotificationsStream();

      // Assert
      await expectLater(
        stream,
        emits(
          isA<NetworkSuccess<List<NotificationEntity>>>().having(
            (res) => res.data,
            'data',
            [tNotificationEntity1, tNotificationEntity2],
          ),
        ),
      );
      verify(() => mockNotificationsRemoteDataSource.getNotificationsStream())
          .called(1);
      verifyNoMoreInteractions(mockNotificationsRemoteDataSource);
    });

    test('should emit NetworkFailure when remoteDataSource stream emits BusinessException', () async {
      // Arrange
      when(() => mockNotificationsRemoteDataSource.getNotificationsStream())
          .thenAnswer(
            (_) => Stream.error(BusinessException(AppStrings.userNotFound)),
          );

      // Act
      final stream = sut.getNotificationsStream();

      // Assert
      await expectLater(
        stream,
        emits(
          isA<NetworkFailure<List<NotificationEntity>>>().having(
            (res) => res.failure.error,
            'error',
            AppStrings.userNotFound,
          ),
        ),
      );
      verify(() => mockNotificationsRemoteDataSource.getNotificationsStream())
          .called(1);
      verifyNoMoreInteractions(mockNotificationsRemoteDataSource);
    });

    test('should emit NetworkFailure with ServerFailure when remoteDataSource stream emits generic Exception', () async {
      // Arrange
      when(() => mockNotificationsRemoteDataSource.getNotificationsStream())
          .thenAnswer((_) => Stream.error(Exception('Firestore stream error')));

      // Act
      final stream = sut.getNotificationsStream();

      // Assert
      await expectLater(
        stream,
        emits(
          isA<NetworkFailure<List<NotificationEntity>>>().having(
            (res) => res.failure.error,
            'error',
            AppStrings.unexpectedError,
          ),
        ),
      );
      verify(() => mockNotificationsRemoteDataSource.getNotificationsStream())
          .called(1);
      verifyNoMoreInteractions(mockNotificationsRemoteDataSource);
    });

    test('should emit multiple NetworkSuccess states in real-time when stream emits updates', () async {
      // Arrange
      final streamController = StreamController<List<NotificationModel>>();
      when(() => mockNotificationsRemoteDataSource.getNotificationsStream())
          .thenAnswer((_) => streamController.stream);

      // Act & Assert
      final expectation = expectLater(
        sut.getNotificationsStream(),
        emitsInOrder([
          isA<NetworkSuccess<List<NotificationEntity>>>().having(
            (res) => res.data,
            'data',
            [tNotificationEntity1],
          ),
          isA<NetworkSuccess<List<NotificationEntity>>>().having(
            (res) => res.data,
            'data',
            [tNotificationEntity1, tNotificationEntity2],
          ),
        ]),
      );

      streamController.add([tNotificationModel1]);
      streamController.add([tNotificationModel1, tNotificationModel2]);

      await expectation;
      await streamController.close();
    });
  });

  group('markAsRead', () {
    const tNotifId = 'notif_1';
    final tFailure = ServerFailure(error: AppStrings.userNotFound);

    test('should call remoteDataSource.markAsRead and return NetworkSuccess<void> when remoteDataSource succeeds', () async {
      // Arrange
      when(() => mockNotificationsRemoteDataSource.markAsRead(tNotifId))
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut.markAsRead(tNotifId);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockNotificationsRemoteDataSource.markAsRead(tNotifId))
          .called(1);
      verifyNoMoreInteractions(mockNotificationsRemoteDataSource);
    });

    test('should return NetworkFailure when remoteDataSource fails to mark as read', () async {
      // Arrange
      when(() => mockNotificationsRemoteDataSource.markAsRead(tNotifId))
          .thenAnswer((_) async => NetworkFailure(tFailure));

      // Act
      final result = await sut.markAsRead(tNotifId);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, tFailure.error);
      verify(() => mockNotificationsRemoteDataSource.markAsRead(tNotifId))
          .called(1);
      verifyNoMoreInteractions(mockNotificationsRemoteDataSource);
    });
  });

  group('markAllAsRead', () {
    final tFailure = ServerFailure(error: AppStrings.userNotFound);

    test('should call remoteDataSource.markAllAsRead and return NetworkSuccess<void> when remoteDataSource succeeds', () async {
      // Arrange
      when(() => mockNotificationsRemoteDataSource.markAllAsRead())
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut.markAllAsRead();

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockNotificationsRemoteDataSource.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockNotificationsRemoteDataSource);
    });

    test('should return NetworkFailure when remoteDataSource fails to mark all as read', () async {
      // Arrange
      when(() => mockNotificationsRemoteDataSource.markAllAsRead())
          .thenAnswer((_) async => NetworkFailure(tFailure));

      // Act
      final result = await sut.markAllAsRead();

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, tFailure.error);
      verify(() => mockNotificationsRemoteDataSource.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockNotificationsRemoteDataSource);
    });
  });
}
