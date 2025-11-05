import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late SignOutUseCase sut;
  late MockAuthRepo mockAuthRepo;

  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tException = Exception('DataSource error');
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(tException);

  setUpAll(() {
    registerFallbackValue(const NetworkSuccess<void>());
    registerFallbackValue(NetworkFailure<void>(tException));
  });

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    sut = SignOutUseCase(mockAuthRepo);
  });

  group('signOut UseCase', () {
    test(
      'should call [AuthRepo.signOut] and return NetworkSuccess<void> when successful',
      () async {
        // Arrange
        when(
          () => mockAuthRepo.signOut(),
        ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);

        // Act
        final result = await sut.call();

        // Assert
        expect(result, tSuccessResponseOfTypeVoid);
        verify(() => mockAuthRepo.signOut()).called(1);
        verifyNoMoreInteractions(mockAuthRepo);
      },
    );

    test(
      'should call [AuthRepo.signOut] and return NetworkFailure<void> when failed',
      () async {
        // Arrange
        when(
          () => mockAuthRepo.signOut(),
        ).thenAnswer((_) async => tFailureResponseOfTypeVoid);

        // Act
        final result = await sut.call();

        // Assert
        expect(result, tFailureResponseOfTypeVoid);
        verify(() => mockAuthRepo.signOut()).called(1);
        verifyNoMoreInteractions(mockAuthRepo);
      },
    );
  });
}
