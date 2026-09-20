import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service_imp.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppPreferencesServiceImpl sut;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    sut = AppPreferencesServiceImpl(sharedPreferences);
  });

  const tUserEntity = UserEntity(
    uid: 'u1',
    name: 'Ahmed Mohamed',
    email: 'user@test.com',
    phone: '01012345678',
    image: 'https://example.com/avatar.png',
    isVerified: true,
  );

  final tAddressMap = <String, dynamic>{
    'street': 'Tahrir Street',
    'city': 'Cairo',
    'floor': '3',
  };

  group('AppPreferencesServiceImpl', () {
    group('isFirstTime & saveFirstTime', () {
      test('should return true by default when isFirstTime is not set', () {
        // Act & Assert
        expect(sut.isFirstTime(), isTrue);
      });

      test('should persist isFirstTime as false when saveFirstTime is called', () async {
        // Act
        await sut.saveFirstTime();

        // Assert
        expect(sut.isFirstTime(), isFalse);
      });
    });

    group('getThemeMode & saveThemeMode', () {
      test('should return system by default when theme is not set', () {
        // Act & Assert
        expect(sut.getThemeMode(), equals('system'));
      });

      test('should persist selected theme mode when saveThemeMode is called', () async {
        // Act
        await sut.saveThemeMode('dark');

        // Assert
        expect(sut.getThemeMode(), equals('dark'));

        // Act
        await sut.saveThemeMode('light');

        // Assert
        expect(sut.getThemeMode(), equals('light'));
      });
    });

    group('getLanguage & saveLanguage', () {
      test('should return ar by default when language is not set', () {
        // Act & Assert
        expect(sut.getLanguage(), equals('ar'));
      });

      test('should persist selected language when saveLanguage is called', () async {
        // Act
        await sut.saveLanguage('en');

        // Assert
        expect(sut.getLanguage(), equals('en'));

        // Act
        await sut.saveLanguage('ar');

        // Assert
        expect(sut.getLanguage(), equals('ar'));
      });
    });

    group('getUser, saveUser & clearUser', () {
      test('should return null when no user is cached', () {
        // Act & Assert
        expect(sut.getUser(), isNull);
      });

      test('should persist UserEntity and retrieve it accurately when saveUser is called', () async {
        // Act
        await sut.saveUser(tUserEntity);
        final retrieved = sut.getUser();

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved?.uid, equals('u1'));
        expect(retrieved?.name, equals('Ahmed Mohamed'));
        expect(retrieved?.email, equals('user@test.com'));
        expect(retrieved?.phone, equals('01012345678'));
        expect(retrieved?.image, equals('https://example.com/avatar.png'));
        expect(retrieved?.isVerified, isTrue);
      });

      test('should return null when cached json string is empty', () async {
        // Arrange
        await sharedPreferences.setString('cached_user', '');

        // Act & Assert
        expect(sut.getUser(), isNull);
      });

      test('should return null safely when cached json is invalid or corrupted', () async {
        // Arrange
        await sharedPreferences.setString('cached_user', 'invalid_json_data');

        // Act & Assert
        expect(sut.getUser(), isNull);
      });

      test('should remove cached user from preferences when clearUser is called', () async {
        // Arrange
        await sut.saveUser(tUserEntity);
        expect(sut.getUser(), isNotNull);

        // Act
        await sut.clearUser();

        // Assert
        expect(sut.getUser(), isNull);
      });
    });

    group('getAddress, saveAddress & deleteAddress', () {
      test('should return empty string by default when no address is cached', () {
        // Act & Assert
        expect(sut.getAddress(), equals(''));
      });

      test('should persist address json when saveAddress is called', () async {
        // Act
        await sut.saveAddress(tAddressMap);

        // Assert
        final address = sut.getAddress();
        expect(address, contains('Tahrir Street'));
        expect(address, contains('Cairo'));
      });

      test('should remove cached address when deleteAddress is called', () async {
        // Arrange
        await sut.saveAddress(tAddressMap);
        expect(sut.getAddress(), isNotEmpty);

        // Act
        await sut.deleteAddress();

        // Assert
        expect(sut.getAddress(), equals(''));
      });
    });
  });
}
