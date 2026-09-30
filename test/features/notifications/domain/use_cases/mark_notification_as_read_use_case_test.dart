import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/notifications/domain/repo/notifications_repo.dart';
import 'package:fruit_hub/features/notifications/domain/use_cases/mark_notification_as_read_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRepo extends Mock implements NotificationsRepo {}

void main() {
  late MockNotificationsRepo mockNotificationsRepo;
  late MarkNotificationAsReadUseCase sut;

  const tNotificationId = 'notif_123';
  const tFailure = ServerFailure(error: 'Failed to mark notification as read');

  setUp(() {
    mockNotificationsRepo = MockNotificationsRepo();
    sut = MarkNotificationAsReadUseCase(mockNotificationsRepo);
  });

  group('MarkNotificationAsReadUseCase', () {
    test(
      'should return NetworkSuccess when repo.markAsRead succeeds',
      () async {
        // Arrange
        when(() => mockNotificationsRepo.markAsRead(tNotificationId))
            .thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut(tNotificationId);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(() => mockNotificationsRepo.markAsRead(tNotificationId))
            .called(1);
        verifyNoMoreInteractions(mockNotificationsRepo);
      },
    );

    test('should return NetworkFailure with same failure when repo.markAsRead fails', () async {
      // Arrange
      when(() => mockNotificationsRepo.markAsRead(tNotificationId))
          .thenAnswer((_) async => const NetworkFailure(tFailure));

      // Act
      final result = await sut(tNotificationId);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure, equals(tFailure));
      expect(failure.error, equals(tFailure.error));
      verify(() => mockNotificationsRepo.markAsRead(tNotificationId)).called(1);
      verifyNoMoreInteractions(mockNotificationsRepo);
    });
  });
}
