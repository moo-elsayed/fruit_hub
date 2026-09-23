import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:fruit_hub/features/profile/data/models/update_profile_input_model.dart';
import 'package:fruit_hub/features/profile/data/repo_imp/profile_repo_imp.dart';
import 'package:fruit_hub/features/profile/domain/entities/update_profile_input_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

class FakeUpdateProfileInputModel extends Fake
    implements UpdateProfileInputModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUpdateProfileInputModel());
  });

  late MockProfileRemoteDataSource mockRemoteDataSource;
  late ProfileRepoImp sut;

  const tServerFailure = ServerFailure(error: 'Operation failed');
  const tCurrentPassword = 'OldPassword123!';
  const tNewPassword = 'NewPassword456!';

  const tInputEntity = UpdateProfileInputEntity(
    uid: 'user_123',
    name: 'أحمد محمود',
    phone: '01012345678',
    image: 'avatar.jpg',
  );

  final tUserModel = UserModel(
    uid: 'user_123',
    name: 'أحمد محمود',
    email: 'ahmed@example.com',
    phone: '01012345678',
    image: 'https://example.com/avatar.jpg',
    isVerified: true,
  );

  const tExpectedUserEntity = UserEntity(
    uid: 'user_123',
    name: 'أحمد محمود',
    email: 'ahmed@example.com',
    phone: '01012345678',
    image: 'https://example.com/avatar.jpg',
    isVerified: true,
  );

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    sut = ProfileRepoImp(mockRemoteDataSource);
  });

  group('updateProfile', () {
    test('should map UpdateProfileInputEntity to UpdateProfileInputModel, call remoteDataSource.updateProfile, and return NetworkSuccess with mapped UserEntity', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateProfile(any()))
          .thenAnswer((_) async => NetworkSuccess(tUserModel));

      // Act
      final result = await sut.updateProfile(tInputEntity);

      // Assert
      expect(result, isA<NetworkSuccess<UserEntity>>());
      final actualUser = (result as NetworkSuccess<UserEntity>).data;
      expect(actualUser, equals(tExpectedUserEntity));

      verify(
        () => mockRemoteDataSource.updateProfile(
          any(
            that: isA<UpdateProfileInputModel>()
                .having((m) => m.uid, 'uid', tInputEntity.uid)
                .having((m) => m.name, 'name', tInputEntity.name)
                .having((m) => m.phone, 'phone', tInputEntity.phone)
                .having((m) => m.image, 'image', tInputEntity.image),
          ),
        ),
      ).called(1);
    });

    test('should return default UserEntity when remoteDataSource returns NetworkSuccess with null data', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateProfile(any()))
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut.updateProfile(tInputEntity);

      // Assert
      expect(result, isA<NetworkSuccess<UserEntity>>());
      final actualUser = (result as NetworkSuccess<UserEntity>).data;
      expect(actualUser, equals(const UserEntity()));
    });

    test('should return NetworkFailure with same failure when remoteDataSource fails during updateProfile', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateProfile(any()))
          .thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut.updateProfile(tInputEntity);

      // Assert
      expect(result, isA<NetworkFailure<UserEntity>>());
      final actualFailure = (result as NetworkFailure<UserEntity>).failure;
      expect(actualFailure, equals(tServerFailure));
    });
  });

  group('changePassword', () {
    test('should call remoteDataSource.changePassword with correct arguments and return NetworkSuccess', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut.changePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(
        () => mockRemoteDataSource.changePassword(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        ),
      ).called(1);
    });

    test('should return NetworkFailure when remoteDataSource fails during changePassword', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut.changePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final actualFailure = (result as NetworkFailure<void>).failure;
      expect(actualFailure, equals(tServerFailure));
    });
  });
}
