import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/get_user_info_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late GetUserInfoUseCase sut;

  const tUid = 'uid_123';

  const tUserEntity = UserEntity(
    uid: tUid,
    name: 'Test User',
    email: 'test@example.com',
    phone: '01012345678',
    image: 'https://example.com/avatar.png',
    isVerified: true,
  );

  const tServerFailure = ServerFailure(error: 'User not found');

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    sut = GetUserInfoUseCase(mockAuthRepo);
  });

  test(
    'should call getUserInfo on AuthRepo with uid and return NetworkSuccess<UserEntity>',
    () async {
      // Arrange
      when(
        () => mockAuthRepo.getUserInfo(tUid),
      ).thenAnswer((_) async => const NetworkSuccess(tUserEntity));

      // Act
      final result = await sut(tUid);

      // Assert
      expect(result, isA<NetworkSuccess<UserEntity>>());
      final successResult = result as NetworkSuccess<UserEntity>;
      expect(successResult.data, tUserEntity);
      verify(() => mockAuthRepo.getUserInfo(tUid)).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );

  test(
    'should return NetworkFailure when AuthRepo fails to get user info',
    () async {
      // Arrange
      when(
        () => mockAuthRepo.getUserInfo(tUid),
      ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut(tUid);

      // Assert
      expect(result, isA<NetworkFailure<UserEntity>>());
      final failureResult = result as NetworkFailure<UserEntity>;
      expect(failureResult.failure, tServerFailure);
      expect(failureResult.error, tServerFailure.error);
      verify(() => mockAuthRepo.getUserInfo(tUid)).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );
}
