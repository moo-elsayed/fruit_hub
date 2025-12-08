import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/clear_user_session_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements AppPreferencesManager {}

void main() {
  late ClearUserSessionUseCase sut;
  late MockLocalStorageService mockLocalStorageService;

  final tStorageException = Exception('Storage error');

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    sut = ClearUserSessionUseCase(mockLocalStorageService);
  });

  group('clearUserSession UseCase', () {
    test(
      'should call deleteUid deleteUseName setLoggedIn and deleteAddress on LocalStorageService successfully',
      () async {
        // Arrange
        when(
          () => mockLocalStorageService.deleteUid(),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalStorageService.deleteUseName(),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalStorageService.setLoggedIn(false),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalStorageService.deleteAddress(),
        ).thenAnswer((_) async {});
        // Act
        await sut.call();
        // Assert
        verify(() => mockLocalStorageService.deleteUid()).called(1);
        verify(() => mockLocalStorageService.deleteUseName()).called(1);
        verify(() => mockLocalStorageService.setLoggedIn(false)).called(1);
        verify(() => mockLocalStorageService.deleteAddress()).called(1);
        verifyNoMoreInteractions(mockLocalStorageService);
      },
    );

    test(
      'should throw "Failed to clear user session" Exception when LocalStorageService fails',
      () async {
        // Arrange
        when(
          () => mockLocalStorageService.deleteUid(),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalStorageService.deleteUseName(),
        ).thenAnswer((_) async => throw tStorageException);
        when(
          () => mockLocalStorageService.setLoggedIn(false),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalStorageService.deleteAddress(),
        ).thenAnswer((_) async {});
        // Act
        final call = sut.call();
        // Assert
        expect(
          call,
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              'Exception: Failed to clear user session',
            ),
          ),
        );
        verify(() => mockLocalStorageService.deleteUid()).called(1);
        verify(() => mockLocalStorageService.deleteUseName()).called(1);
        verify(() => mockLocalStorageService.setLoggedIn(false)).called(1);
        verify(() => mockLocalStorageService.deleteAddress()).called(1);
        verifyNoMoreInteractions(mockLocalStorageService);
      },
    );
  });
}
