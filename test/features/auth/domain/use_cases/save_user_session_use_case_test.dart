import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/save_user_session_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements AppPreferencesManager {}

void main() {
  late SaveUserSessionUseCase sut;
  late MockLocalStorageService mockLocalStorageService;

  final tUser = const UserEntity(name: 'Test User', uid: '123456');
  final tStorageException = Exception('Storage error');

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    sut = SaveUserSessionUseCase(mockLocalStorageService);
  });

  group('saveUserSession UseCase', () {
    test(
      'should call setUid setUsername and setLoggedIn on LocalStorageService successfully',
      () async {
        // Arrange
        when(
          () => mockLocalStorageService.setUid(tUser.uid),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalStorageService.setUsername(tUser.name),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalStorageService.setLoggedIn(true),
        ).thenAnswer((_) async {});
        // Act
        await sut.call(tUser);
        // Assert
        verify(() => mockLocalStorageService.setUid(tUser.uid)).called(1);
        verify(() => mockLocalStorageService.setUsername(tUser.name)).called(1);
        verify(() => mockLocalStorageService.setLoggedIn(true)).called(1);
        verifyNoMoreInteractions(mockLocalStorageService);
      },
    );

    test(
      'should throw "Failed to save user session" Exception when LocalStorageService fails',
      () async {
        // Arrange
        when(
          () => mockLocalStorageService.setUid(tUser.uid),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalStorageService.setUsername(tUser.name),
        ).thenAnswer((_) async => throw tStorageException);
        when(
          () => mockLocalStorageService.setLoggedIn(true),
        ).thenAnswer((_) async {});
        // Act
        final call = sut.call(tUser);
        // Assert
        expect(
          call,
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              'Exception: Failed to save user session',
            ),
          ),
        );
        verify(() => mockLocalStorageService.setUid(tUser.uid)).called(1);
        verify(() => mockLocalStorageService.setUsername(tUser.name)).called(1);
        verify(() => mockLocalStorageService.setLoggedIn(true)).called(1);
        verifyNoMoreInteractions(mockLocalStorageService);
      },
    );
  });
}
