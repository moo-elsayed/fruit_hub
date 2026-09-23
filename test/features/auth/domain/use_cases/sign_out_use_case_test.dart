import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late SignOutUseCase sut;

  const tServerFailure = ServerFailure(error: 'Sign out failed');

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    sut = SignOutUseCase(mockAuthRepo);
  });

  test(
    'should call signOut on AuthRepo and return NetworkSuccess<void>',
    () async {
      // Arrange
      when(() => mockAuthRepo.signOut())
          .thenAnswer((_) async => const NetworkSuccess<void>());

      // Act
      final result = await sut();

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockAuthRepo.signOut()).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );

  test(
    'should return NetworkFailure when AuthRepo fails during signOut',
    () async {
      // Arrange
      when(() => mockAuthRepo.signOut())
          .thenAnswer((_) async => const NetworkFailure<void>(tServerFailure));

      // Act
      final result = await sut();

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failureResult = result as NetworkFailure<void>;
      expect(failureResult.failure, tServerFailure);
      expect(failureResult.error, tServerFailure.error);
      verify(() => mockAuthRepo.signOut()).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );
}
