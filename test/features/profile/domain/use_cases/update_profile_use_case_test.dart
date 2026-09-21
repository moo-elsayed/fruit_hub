import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/profile/domain/entities/update_profile_input_entity.dart';
import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepo extends Mock implements ProfileRepo {}

class FakeUpdateProfileInputEntity extends Fake
    implements UpdateProfileInputEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUpdateProfileInputEntity());
  });

  late MockProfileRepo mockProfileRepo;
  late UpdateProfileUseCase sut;

  const tServerFailure = ServerFailure(error: 'Failed to update profile');

  const tInputEntity = UpdateProfileInputEntity(
    uid: 'user_123',
    name: 'أحمد محمود',
    phone: '01012345678',
    image: 'https://example.com/avatar.jpg',
  );

  const tUserEntity = UserEntity(
    uid: 'user_123',
    name: 'أحمد محمود',
    email: 'ahmed@example.com',
    phone: '01012345678',
    image: 'https://example.com/avatar.jpg',
    isVerified: true,
  );

  setUp(() {
    mockProfileRepo = MockProfileRepo();
    sut = UpdateProfileUseCase(mockProfileRepo);
  });

  test(
    'should call updateProfile on ProfileRepo with correct input and return NetworkSuccess<UserEntity>',
    () async {
      // Arrange
      when(
        () => mockProfileRepo.updateProfile(any()),
      ).thenAnswer((_) async => const NetworkSuccess(tUserEntity));

      // Act
      final result = await sut(tInputEntity);

      // Assert
      expect(result, isA<NetworkSuccess<UserEntity>>());
      final actualUser = (result as NetworkSuccess<UserEntity>).data;
      expect(actualUser, equals(tUserEntity));

      verify(() => mockProfileRepo.updateProfile(tInputEntity)).called(1);
    },
  );

  test(
    'should return NetworkFailure when ProfileRepo fails during updateProfile',
    () async {
      // Arrange
      when(
        () => mockProfileRepo.updateProfile(any()),
      ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut(tInputEntity);

      // Assert
      expect(result, isA<NetworkFailure<UserEntity>>());
      final actualFailure = (result as NetworkFailure<UserEntity>).failure;
      expect(actualFailure, equals(tServerFailure));

      verify(() => mockProfileRepo.updateProfile(tInputEntity)).called(1);
    },
  );
}
