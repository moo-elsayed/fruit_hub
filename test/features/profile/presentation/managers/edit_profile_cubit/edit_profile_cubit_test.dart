import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/profile/domain/entities/update_profile_input_entity.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:fruit_hub/features/profile/presentation/managers/edit_profile_cubit/edit_profile_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockUserInfoCubit extends Mock implements UserInfoCubit {}

class FakeUpdateProfileInputEntity extends Fake
    implements UpdateProfileInputEntity {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUpdateProfileInputEntity());
    registerFallbackValue(FakeUserEntity());
  });

  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late MockUserInfoCubit mockUserInfoCubit;
  late EditProfileCubit sut;

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

  const tErrorMessage = 'Failed to update profile';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    mockUserInfoCubit = MockUserInfoCubit();
    sut = EditProfileCubit(mockUpdateProfileUseCase, mockUserInfoCubit);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be EditProfileInitial', () {
    // Assert
    expect(sut.state, equals(const EditProfileInitial()));
  });

  test('currentUser getter should return currentUser from UserInfoCubit', () {
    // Arrange
    when(() => mockUserInfoCubit.currentUser).thenReturn(tUserEntity);

    // Act
    final result = sut.currentUser;

    // Assert
    expect(result, equals(tUserEntity));
    verify(() => mockUserInfoCubit.currentUser).called(1);
  });

  group('updateProfile', () {
    blocTest<EditProfileCubit, EditProfileState>(
      'should emit [EditProfileFailure] when input.uid is empty',
      build: () => sut,
      act: (cubit) => cubit.updateProfile(
        const UpdateProfileInputEntity(
          uid: '',
          name: 'محمد',
          phone: '01000000000',
          image: '',
        ),
      ),
      expect: () => [EditProfileFailure(AppStrings.userNotFound)],
      verify: (_) {
        verifyZeroInteractions(mockUpdateProfileUseCase);
        verifyZeroInteractions(mockUserInfoCubit);
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'should emit [EditProfileLoading, EditProfileSuccess] and save user locally when update succeeds with non-null data',
      setUp: () {
        when(() => mockUpdateProfileUseCase(any()))
            .thenAnswer((_) async => const NetworkSuccess(tUserEntity));
        when(() => mockUserInfoCubit.saveUserLocally(any()))
            .thenAnswer((_) async {});
      },
      build: () => sut,
      act: (cubit) => cubit.updateProfile(tInputEntity),
      expect: () => [
        const EditProfileLoading(),
        const EditProfileSuccess(tUserEntity),
      ],
      verify: (_) {
        verify(() => mockUpdateProfileUseCase(tInputEntity)).called(1);
        verify(() => mockUserInfoCubit.saveUserLocally(tUserEntity)).called(1);
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'should emit [EditProfileLoading, EditProfileFailure] with unexpectedError when update succeeds with null data',
      setUp: () {
        when(() => mockUpdateProfileUseCase(any()))
            .thenAnswer((_) async => const NetworkSuccess(null));
      },
      build: () => sut,
      act: (cubit) => cubit.updateProfile(tInputEntity),
      expect: () => [
        const EditProfileLoading(),
        EditProfileFailure(AppStrings.unexpectedError),
      ],
      verify: (_) {
        verify(() => mockUpdateProfileUseCase(tInputEntity)).called(1);
        verifyNever(() => mockUserInfoCubit.saveUserLocally(any()));
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'should emit [EditProfileLoading, EditProfileFailure] with error message when update fails',
      setUp: () {
        when(() => mockUpdateProfileUseCase(any()))
            .thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      build: () => sut,
      act: (cubit) => cubit.updateProfile(tInputEntity),
      expect: () => [
        const EditProfileLoading(),
        const EditProfileFailure(tErrorMessage),
      ],
      verify: (_) {
        verify(() => mockUpdateProfileUseCase(tInputEntity)).called(1);
        verifyNever(() => mockUserInfoCubit.saveUserLocally(any()));
      },
    );
  });
}
