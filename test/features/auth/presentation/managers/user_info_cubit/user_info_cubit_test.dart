import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/get_user_info_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAppPreferencesService extends Mock implements AppPreferencesService {}

class MockGetUserInfoUseCase extends Mock implements GetUserInfoUseCase {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
  });

  late MockAppPreferencesService mockAppPreferencesService;
  late MockGetUserInfoUseCase mockGetUserInfoUseCase;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockFirebaseUser;
  late UserInfoCubit sut;

  const tUid = 'uid_123';
  const tUser = UserEntity(
    uid: tUid,
    name: 'Test User',
    email: 'test@example.com',
    phone: '01012345678',
    image: 'https://example.com/avatar.png',
    isVerified: true,
  );

  const tUpdatedUser = UserEntity(
    uid: tUid,
    name: 'Updated User',
    email: 'test@example.com',
    phone: '01012345678',
    image: 'https://example.com/new_avatar.png',
    isVerified: true,
  );

  const tErrorMessage = 'User not found';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockAppPreferencesService = MockAppPreferencesService();
    mockGetUserInfoUseCase = MockGetUserInfoUseCase();
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseUser = MockUser();

    when(() => mockFirebaseUser.uid).thenReturn(tUid);
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);

    when(() => mockAppPreferencesService.getUser()).thenReturn(null);
    when(() => mockAppPreferencesService.saveUser(any()))
        .thenAnswer((_) async {});
    when(() => mockAppPreferencesService.clearUser()).thenAnswer((_) async {});

    sut = UserInfoCubit(
      mockAppPreferencesService,
      mockGetUserInfoUseCase,
      firebaseAuth: mockFirebaseAuth,
    );
  });

  tearDown(() {
    sut.close();
  });

  group('initialization & loadCachedUser', () {
    test('initial state should be UserInfoInitial when no cached user', () {
      // Assert
      expect(sut.state, isA<UserInfoInitial>());
    });

    test('initial state should be UserInfoSuccess when cached user exists', () {
      // Arrange
      final localMockPrefs = MockAppPreferencesService();
      when(() => localMockPrefs.getUser()).thenReturn(tUser);

      // Act
      final cubit = UserInfoCubit(
        localMockPrefs,
        mockGetUserInfoUseCase,
        firebaseAuth: mockFirebaseAuth,
      );

      // Assert
      expect(cubit.state, isA<UserInfoSuccess>());
      expect((cubit.state as UserInfoSuccess).user, tUser);
      cubit.close();
    });
  });

  group('currentUser', () {
    test('should return user from state when state is UserInfoSuccess', () {
      // Arrange
      sut.emit(UserInfoSuccess(tUser));

      // Act
      final result = sut.currentUser;

      // Assert
      expect(result, tUser);
    });

    test('should fallback to AppPreferencesService.getUser when state is not UserInfoSuccess', () {
      // Arrange
      when(() => mockAppPreferencesService.getUser()).thenReturn(tUser);
      clearInteractions(mockAppPreferencesService);

      // Act
      final result = sut.currentUser;

      // Assert
      expect(result, tUser);
      verify(() => mockAppPreferencesService.getUser()).called(1);
    });
  });

  group('saveUserLocally', () {
    blocTest<UserInfoCubit, UserInfoState>(
      'should save user to preferences and emit UserInfoSuccess',
      build: () => sut,
      act: (cubit) async {
        // Act
        await cubit.saveUserLocally(tUser);
      },
      expect: () => [
        isA<UserInfoSuccess>().having((s) => s.user, 'user', tUser),
      ],
      verify: (_) {
        // Assert
        verify(() => mockAppPreferencesService.saveUser(tUser)).called(1);
      },
    );
  });

  group('clearUserLocally', () {
    blocTest<UserInfoCubit, UserInfoState>(
      'should clear user from preferences and emit UserInfoInitial',
      build: () => sut,
      act: (cubit) async {
        // Act
        await cubit.clearUserLocally();
      },
      expect: () => [isA<UserInfoInitial>()],
      verify: (_) {
        // Assert
        verify(() => mockAppPreferencesService.clearUser()).called(1);
      },
    );
  });

  group('getUserInfo', () {
    test('should do nothing when firebaseUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      await sut.getUserInfo();

      // Assert
      expect(sut.state, isA<UserInfoInitial>());
      verifyNever(() => mockGetUserInfoUseCase(any()));
    });

    blocTest<UserInfoCubit, UserInfoState>(
      'should emit [UserInfoLoading, UserInfoSuccess] and save user when no cached user and usecase succeeds',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockGetUserInfoUseCase.call(tUid))
            .thenAnswer((_) async => const NetworkSuccess(tUpdatedUser));
      },
      act: (cubit) async {
        // Act
        await cubit.getUserInfo();
      },
      expect: () => [
        isA<UserInfoLoading>(),
        isA<UserInfoSuccess>().having((s) => s.user, 'user', tUpdatedUser),
      ],
      verify: (_) {
        // Assert
        verify(() => mockGetUserInfoUseCase.call(tUid)).called(1);
        verify(() => mockAppPreferencesService.saveUser(tUpdatedUser))
            .called(1);
      },
    );

    blocTest<UserInfoCubit, UserInfoState>(
      'should emit [UserInfoSuccess] directly without loading and save user when cached user already exists and usecase succeeds',
      build: () {
        sut.emit(UserInfoSuccess(tUser));
        return sut;
      },
      setUp: () {
        // Arrange
        when(() => mockGetUserInfoUseCase.call(tUid))
            .thenAnswer((_) async => const NetworkSuccess(tUpdatedUser));
      },
      act: (cubit) async {
        // Act
        await cubit.getUserInfo();
      },
      expect: () => [
        isA<UserInfoSuccess>().having((s) => s.user, 'user', tUpdatedUser),
      ],
      verify: (_) {
        // Assert
        verify(() => mockGetUserInfoUseCase.call(tUid)).called(1);
        verify(() => mockAppPreferencesService.saveUser(tUpdatedUser))
            .called(1);
      },
    );

    blocTest<UserInfoCubit, UserInfoState>(
      'should emit [UserInfoLoading, UserInfoFailure] when no cached user and usecase returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockGetUserInfoUseCase.call(tUid))
            .thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.getUserInfo();
      },
      expect: () => [
        isA<UserInfoLoading>(),
        isA<UserInfoFailure>().having((s) => s.error, 'error', tErrorMessage),
      ],
      verify: (_) {
        // Assert
        verify(() => mockGetUserInfoUseCase.call(tUid)).called(1);
        verifyNever(() => mockAppPreferencesService.saveUser(any()));
      },
    );

    blocTest<UserInfoCubit, UserInfoState>(
      'should not emit failure when cached user already exists and usecase returns NetworkFailure',
      build: () {
        sut.emit(UserInfoSuccess(tUser));
        return sut;
      },
      setUp: () {
        // Arrange
        when(() => mockGetUserInfoUseCase.call(tUid))
            .thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.getUserInfo();
      },
      expect: () => [],
      verify: (_) {
        // Assert
        verify(() => mockGetUserInfoUseCase.call(tUid)).called(1);
        verifyNever(() => mockAppPreferencesService.saveUser(any()));
      },
    );
  });
}
