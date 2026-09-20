import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/cubits/app_language_cubit.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/core/services/notifications/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAppPreferencesService extends Mock implements AppPreferencesService {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  group('AppLanguageCubit', () {
    late MockAppPreferencesService mockPreferencesService;
    late MockNotificationService mockNotificationService;
    late AppLanguageCubit sut;

    setUp(() {
      mockPreferencesService = MockAppPreferencesService();
      mockNotificationService = MockNotificationService();
    });

    tearDown(() {
      if (!sut.isClosed) {
        sut.close();
      }
    });

    test(
      'should emit Locale with language returned by AppPreferencesService initially',
      () {
        // Arrange
        when(() => mockPreferencesService.getLanguage()).thenReturn('ar');

        // Act
        sut = AppLanguageCubit(
          preferencesService: mockPreferencesService,
          notificationService: mockNotificationService,
        );

        // Assert
        expect(sut.state, equals(const Locale('ar')));
        verify(() => mockPreferencesService.getLanguage()).called(1);
      },
    );

    test(
      'should emit English Locale initially when AppPreferencesService returns en',
      () {
        // Arrange
        when(() => mockPreferencesService.getLanguage()).thenReturn('en');

        // Act
        sut = AppLanguageCubit(
          preferencesService: mockPreferencesService,
          notificationService: mockNotificationService,
        );

        // Assert
        expect(sut.state, equals(const Locale('en')));
        verify(() => mockPreferencesService.getLanguage()).called(1);
      },
    );

    group('changeLanguage', () {
      blocTest<AppLanguageCubit, Locale>(
        'should emit new Locale, persist languageCode, and update notification language',
        build: () {
          when(() => mockPreferencesService.getLanguage()).thenReturn('ar');
          when(() => mockPreferencesService.saveLanguage('en'))
              .thenAnswer((_) async {});
          when(() => mockNotificationService.updateLanguageCode('en'))
              .thenAnswer((_) async {});
          sut = AppLanguageCubit(
            preferencesService: mockPreferencesService,
            notificationService: mockNotificationService,
          );
          return sut;
        },
        act: (cubit) => cubit.changeLanguage('en'),
        expect: () => [const Locale('en')],
        verify: (_) {
          verify(() => mockPreferencesService.saveLanguage('en')).called(1);
          verify(() => mockNotificationService.updateLanguageCode('en'))
              .called(1);
        },
      );

      blocTest<AppLanguageCubit, Locale>(
        'should emit Arabic Locale when changing language to ar',
        build: () {
          when(() => mockPreferencesService.getLanguage()).thenReturn('en');
          when(() => mockPreferencesService.saveLanguage('ar'))
              .thenAnswer((_) async {});
          when(() => mockNotificationService.updateLanguageCode('ar'))
              .thenAnswer((_) async {});
          sut = AppLanguageCubit(
            preferencesService: mockPreferencesService,
            notificationService: mockNotificationService,
          );
          return sut;
        },
        act: (cubit) => cubit.changeLanguage('ar'),
        expect: () => [const Locale('ar')],
        verify: (_) {
          verify(() => mockPreferencesService.saveLanguage('ar')).called(1);
          verify(() => mockNotificationService.updateLanguageCode('ar'))
              .called(1);
        },
      );

      blocTest<AppLanguageCubit, Locale>(
        'should not emit state and should not persist or update notifications when changing to the already active language',
        build: () {
          when(() => mockPreferencesService.getLanguage()).thenReturn('ar');
          sut = AppLanguageCubit(
            preferencesService: mockPreferencesService,
            notificationService: mockNotificationService,
          );
          return sut;
        },
        act: (cubit) => cubit.changeLanguage('ar'),
        expect: () => <Locale>[],
        verify: (_) {
          verifyNever(() => mockPreferencesService.saveLanguage(any()));
          verifyNever(() => mockNotificationService.updateLanguageCode(any()));
        },
      );
    });
  });
}
