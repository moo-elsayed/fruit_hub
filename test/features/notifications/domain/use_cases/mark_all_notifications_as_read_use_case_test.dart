import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/notifications/domain/repo/notifications_repo.dart';
import 'package:fruit_hub/features/notifications/domain/use_cases/mark_all_notifications_as_read_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRepo extends Mock implements NotificationsRepo {}

void main() {
  late MockNotificationsRepo mockNotificationsRepo;
  late MarkAllNotificationsAsReadUseCase sut;

  const tFailure = ServerFailure(
    error: 'Failed to mark all notifications as read',
  );

  setUp(() {
    mockNotificationsRepo = MockNotificationsRepo();
    sut = MarkAllNotificationsAsReadUseCase(mockNotificationsRepo);
  });

  group('MarkAllNotificationsAsReadUseCase', () {
    test(
      'should return NetworkSuccess when repo.markAllAsRead succeeds',
      () async {
        // Arrange
        when(() => mockNotificationsRepo.markAllAsRead())
            .thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut();

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(() => mockNotificationsRepo.markAllAsRead()).called(1);
        verifyNoMoreInteractions(mockNotificationsRepo);
      },
    );

    test('should return NetworkFailure with same failure when repo.markAllAsRead fails', () async {
      // Arrange
      when(() => mockNotificationsRepo.markAllAsRead())
          .thenAnswer((_) async => const NetworkFailure(tFailure));

      // Act
      final result = await sut();

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure, equals(tFailure));
      expect(failure.error, equals(tFailure.error));
      verify(() => mockNotificationsRepo.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockNotificationsRepo);
    });
  });
}
