import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/shared_data/services/local_storage_service/shared_preferences_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesManager sut;

  final tAddressMap = {"street": "Nile St", "city": "Cairo", "floor": 5};
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    sut = SharedPreferencesManager();
    sut.init();
  });

  group('SharedPreferencesManager Tests', () {
    group('setFirstTime', () {
      test('should return true for getFirstTime by default', () {
        // Act
        final result = sut.getFirstTime();
        // Assert
        expect(result, true);
      });
      test('should set isFirstTime correctly', () async {
        // Arrange
        const isFirstTime = true;
        // Act
        await sut.setFirstTime(isFirstTime);
        // Assert
        expect(sut.getFirstTime(), isFirstTime);
      });
    });
    group('setLoggedIn', () {
      test('should return false for getLoggedIn by default', () {
        // Act
        final result = sut.getLoggedIn();
        // Assert
        expect(result, false);
      });
      test('should set isLoggedIn correctly', () async {
        // Arrange
        const isLoggedIn = true;
        // Act
        await sut.setLoggedIn(isLoggedIn);
        // Assert
        expect(sut.getLoggedIn(), isLoggedIn);
      });
    });
    group('setUsername', () {
      test('should return empty string for getUsername by default', () {
        // Act
        final result = sut.getUsername();
        // Assert
        expect(result, '');
      });
      test('should set username correctly', () async {
        // Arrange
        const username = 'John Doe';
        // Act
        await sut.setUsername(username);
        // Assert
        expect(sut.getUsername(), username);
      });
    });
    group('deleteUseName', () {
      test('should delete username correctly', () async {
        // Arrange
        const username = 'John Doe';
        await sut.setUsername(username);
        // Act
        await sut.deleteUseName();
        // Assert
        expect(sut.getUsername(), '');
      });
    });
    group('saveAddress', () {
      test('should encode map to json string when saving address', () async {
        // Arrange
        // Act
        await sut.saveAddress(tAddressMap);
        final savedAddress = sut.getAddress();
        // Assert
        expect(savedAddress, jsonEncode(tAddressMap));
      });
    });
    group('deleteAddress', () {
      test('should delete address correctly', () async {
        // Arrange
        await sut.saveAddress(tAddressMap);
        // Act
        await sut.deleteAddress();
        // Assert
        expect(sut.getAddress(), '');
      });
    });
    group('getAddress', () {
      test('should return empty string for getAddress by default', () {
        // Act
        final result = sut.getAddress();
        // Assert
        expect(result, '');
      });
      test('should decode json string to map when getting address', () async {
        // Arrange
        await sut.saveAddress(tAddressMap);
        // Act
        final result = sut.getAddress();
        // Assert
        expect(result, jsonEncode(tAddressMap));
        expect(jsonDecode(result), tAddressMap);
      });
    });
  });
}
