import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/helpers/image_compressor.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';
import 'package:fruit_hub/features/profile/data/data_sources/remote/profile_remote_data_source_imp.dart';
import 'package:fruit_hub/features/profile/data/models/update_profile_input_model.dart';
import 'package:fruit_hub/features/profile/domain/entities/update_profile_input_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockListResult extends Mock implements ListResult {}

class MockImageCompressor extends Mock implements ImageCompressor {}

class FakeAuthCredential extends Fake implements AuthCredential {}

class FakeSettableMetadata extends Fake implements SettableMetadata {}

class FakeTaskSnapshot extends Fake implements TaskSnapshot {}

class FakeUploadTask extends Fake implements UploadTask {
  FakeUploadTask([TaskSnapshot? snapshot])
    : _snapshot = snapshot ?? FakeTaskSnapshot();

  final TaskSnapshot _snapshot;

  @override
  Future<S> then<S>(
    FutureOr<S> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) => Future.value(_snapshot).then(onValue, onError: onError);
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
    registerFallbackValue(FakeSettableMetadata());
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(File(''));
    registerFallbackValue(CompressFormat.jpeg);
  });

  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockFirebaseStorage mockFirebaseStorage;
  late MockReference mockRootRef;
  late MockReference mockAvatarFolderRef;
  late MockReference mockAvatarFileRef;
  late MockReference mockExistingAvatarItem;
  late MockListResult mockListResult;
  late MockImageCompressor mockImageCompressor;
  late Directory tempDir;
  late File tempAvatarFile;
  late ProfileRemoteDataSourceImp sut;

  const tUid = 'user_profile_123';
  const tEmail = 'moo@example.com';
  const tOldName = 'Old Name';
  const tNewName = 'New Name';
  const tOldPhone = '01000000000';
  const tNewPhone = '01111111111';
  const tUploadedDownloadUrl =
      'https://firebasestorage.googleapis.com/avatar.jpg';
  const tHttpImageUrl = 'https://example.com/hosted_avatar.png';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockFirebaseStorage = MockFirebaseStorage();
    mockRootRef = MockReference();
    mockAvatarFolderRef = MockReference();
    mockAvatarFileRef = MockReference();
    mockExistingAvatarItem = MockReference();
    mockListResult = MockListResult();
    mockImageCompressor = MockImageCompressor();

    tempDir = Directory.systemTemp.createTempSync('profile_test_');
    tempAvatarFile = File('${tempDir.path}/avatar_test.jpg');
    tempAvatarFile.writeAsBytesSync([1, 2, 3, 4, 5]);

    // User mock setup
    when(() => mockUser.uid).thenReturn(tUid);
    when(() => mockUser.email).thenReturn(tEmail);
    when(() => mockUser.displayName).thenReturn(tOldName);
    when(() => mockUser.photoURL).thenReturn(null);
    when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
    when(() => mockUser.updatePhotoURL(any())).thenAnswer((_) async {});
    when(() => mockUser.reauthenticateWithCredential(any()))
        .thenAnswer((_) async => MockUserCredential());
    when(() => mockUser.updatePassword(any())).thenAnswer((_) async {});

    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

    // Storage mock setup
    when(() => mockFirebaseStorage.ref()).thenReturn(mockRootRef);
    when(
      () => mockRootRef.child('${BackendEndpoints.userAvatarsStorage}/$tUid'),
    ).thenReturn(mockAvatarFolderRef);
    when(
      () => mockRootRef.child(
        '${BackendEndpoints.userAvatarsStorage}/$tUid/avatar.jpg',
      ),
    ).thenReturn(mockAvatarFileRef);

    when(() => mockAvatarFolderRef.listAll())
        .thenAnswer((_) async => mockListResult);
    when(() => mockListResult.items).thenReturn([mockExistingAvatarItem]);
    when(() => mockExistingAvatarItem.delete()).thenAnswer((_) async {});

    when(() => mockAvatarFileRef.putData(any(), any()))
        .thenAnswer((_) => FakeUploadTask());
    when(() => mockAvatarFileRef.putFile(any()))
        .thenAnswer((_) => FakeUploadTask());
    when(() => mockAvatarFileRef.getDownloadURL())
        .thenAnswer((_) async => tUploadedDownloadUrl);

    // Image compressor mock default
    when(
      () => mockImageCompressor.compressWithFile(
        any(),
        minWidth: any(named: 'minWidth'),
        minHeight: any(named: 'minHeight'),
        quality: any(named: 'quality'),
        format: any(named: 'format'),
      ),
    ).thenAnswer((_) async => Uint8List.fromList([9, 8, 7]));

    sut = ProfileRemoteDataSourceImp(
      firebaseAuth: mockFirebaseAuth,
      firestore: fakeFirestore,
      firebaseStorage: mockFirebaseStorage,
      imageCompressor: mockImageCompressor,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<void> seedUserDocument({
    String uid = tUid,
    String name = tOldName,
    String phone = tOldPhone,
    String email = tEmail,
    String image = '',
    bool isVerified = true,
    Map<String, dynamic>? extraData,
  }) async {
    await fakeFirestore
        .collection(BackendEndpoints.usersCollection)
        .doc(uid)
        .set({
          'uid': uid,
          'name': name,
          'phone': phone,
          'email': email,
          'image': image,
          'isVerified': isVerified,
          ...?extraData,
        });
  }

  group('updateProfile', () {
    test('should compress and upload local avatar image, delete old avatars, merge into Firestore preserving existing fields, and return NetworkSuccess with updated UserModel', () async {
      // Arrange
      await seedUserDocument(
        extraData: {'savedAddress': 'Cairo, Egypt', 'accountType': 'VIP'},
      );

      final input = UpdateProfileInputModel(
        uid: tUid,
        name: tNewName,
        phone: tNewPhone,
        image: tempAvatarFile.path,
      );

      // Act
      final result = await sut.updateProfile(input);

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final updatedUser = (result as NetworkSuccess<UserModel>).data!;
      expect(updatedUser.uid, equals(tUid));
      expect(updatedUser.name, equals(tNewName));
      expect(updatedUser.phone, equals(tNewPhone));
      expect(updatedUser.image, equals(tUploadedDownloadUrl));
      expect(updatedUser.email, equals(tEmail));

      // Verify storage operations
      verify(() => mockAvatarFolderRef.listAll()).called(1);
      verify(() => mockExistingAvatarItem.delete()).called(1);
      verify(
        () => mockImageCompressor.compressWithFile(
          tempAvatarFile.path,
          minWidth: 512,
          minHeight: 512,
          quality: 75,
          format: CompressFormat.jpeg,
        ),
      ).called(1);
      verify(() => mockAvatarFileRef.putData(any(), any())).called(1);
      verify(() => mockAvatarFileRef.getDownloadURL()).called(1);

      // Verify FirebaseAuth user updates
      verify(() => mockUser.updateDisplayName(tNewName)).called(1);
      verify(() => mockUser.updatePhotoURL(tUploadedDownloadUrl)).called(1);

      // Verify Firestore merge preserved unrelated fields
      final doc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .get();
      final docData = doc.data()!;
      expect(docData['savedAddress'], equals('Cairo, Egypt'));
      expect(docData['accountType'], equals('VIP'));
      expect(docData['name'], equals(tNewName));
      expect(docData['phone'], equals(tNewPhone));
      expect(docData['image'], equals(tUploadedDownloadUrl));
    });

    test('should fallback to putFile when image compression returns null and return NetworkSuccess', () async {
      // Arrange
      await seedUserDocument();
      when(
        () => mockImageCompressor.compressWithFile(
          any(),
          minWidth: any(named: 'minWidth'),
          minHeight: any(named: 'minHeight'),
          quality: any(named: 'quality'),
          format: any(named: 'format'),
        ),
      ).thenAnswer((_) async => null);

      final input = UpdateProfileInputModel(
        uid: tUid,
        name: tNewName,
        phone: tNewPhone,
        image: tempAvatarFile.path,
      );

      // Act
      final result = await sut.updateProfile(input);

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final updatedUser = (result as NetworkSuccess<UserModel>).data!;
      expect(updatedUser.image, equals(tUploadedDownloadUrl));

      verify(() => mockAvatarFileRef.putFile(any())).called(1);
      verifyNever(() => mockAvatarFileRef.putData(any(), any()));
    });

    test('should not upload to storage or compress image when image URL already starts with http', () async {
      // Arrange
      await seedUserDocument();
      const input = UpdateProfileInputModel(
        uid: tUid,
        name: tNewName,
        phone: tNewPhone,
        image: tHttpImageUrl,
      );

      // Act
      final result = await sut.updateProfile(input);

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final updatedUser = (result as NetworkSuccess<UserModel>).data!;
      expect(updatedUser.image, equals(tHttpImageUrl));

      verifyNever(() => mockImageCompressor.compressWithFile(any()));
      verifyNever(() => mockAvatarFolderRef.listAll());
      verifyNever(() => mockAvatarFileRef.putData(any(), any()));
      verifyNever(() => mockAvatarFileRef.putFile(any()));
      verify(() => mockUser.updatePhotoURL(tHttpImageUrl)).called(1);
    });

    test('should delete existing avatars from storage and set photoURL to null when image is empty', () async {
      // Arrange
      await seedUserDocument(image: tUploadedDownloadUrl);
      const input = UpdateProfileInputModel(
        uid: tUid,
        name: tNewName,
        phone: tNewPhone,
        image: '',
      );

      // Act
      final result = await sut.updateProfile(input);

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final updatedUser = (result as NetworkSuccess<UserModel>).data!;
      expect(updatedUser.image, isEmpty);

      verify(() => mockAvatarFolderRef.listAll()).called(1);
      verify(() => mockExistingAvatarItem.delete()).called(1);
      verifyNever(() => mockAvatarFileRef.putData(any(), any()));
      verify(() => mockUser.updatePhotoURL(null)).called(1);
    });

    test('should continue gracefully and return NetworkSuccess when deleting existing avatar throws exception', () async {
      // Arrange
      await seedUserDocument();
      when(() => mockAvatarFolderRef.listAll()).thenThrow(
        FirebaseException(plugin: 'storage', message: 'Permission denied'),
      );

      const input = UpdateProfileInputModel(
        uid: tUid,
        name: tNewName,
        phone: tNewPhone,
        image: '',
      );

      // Act
      final result = await sut.updateProfile(input);

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final updatedUser = (result as NetworkSuccess<UserModel>).data!;
      expect(updatedUser.name, equals(tNewName));
    });

    test(
      'should not call currentUser methods when currentUser is null',
      () async {
        // Arrange
        await seedUserDocument();
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        const input = UpdateProfileInputModel(
          uid: tUid,
          name: tNewName,
          phone: tNewPhone,
          image: tHttpImageUrl,
        );

        // Act
        final result = await sut.updateProfile(input);

        // Assert
        expect(result, isA<NetworkSuccess<UserModel>>());
        verifyNever(() => mockUser.updateDisplayName(any()));
        verifyNever(() => mockUser.updatePhotoURL(any()));
      },
    );

    test('should not call currentUser methods when currentUser.uid does not match input.uid', () async {
      // Arrange
      const differentUid = 'different_uid_999';
      await seedUserDocument(uid: differentUid);
      when(() => mockUser.uid).thenReturn(tUid);

      const input = UpdateProfileInputModel(
        uid: differentUid,
        name: tNewName,
        phone: tNewPhone,
        image: tHttpImageUrl,
      );

      // Act
      final result = await sut.updateProfile(input);

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      verifyNever(() => mockUser.updateDisplayName(any()));
      verifyNever(() => mockUser.updatePhotoURL(any()));
    });

    test(
      'should return NetworkFailure when storage upload throws an exception',
      () async {
        // Arrange
        await seedUserDocument();
        when(() => mockAvatarFileRef.getDownloadURL()).thenThrow(
          FirebaseException(plugin: 'storage', message: 'Download URL failed'),
        );

        final input = UpdateProfileInputModel(
          uid: tUid,
          name: tNewName,
          phone: tNewPhone,
          image: tempAvatarFile.path,
        );

        // Act
        final result = await sut.updateProfile(input);

        // Assert
        expect(result, isA<NetworkFailure<UserModel>>());
      },
    );

    test('should skip storage upload and update Firestore directly when local file does not exist', () async {
      // Arrange
      await seedUserDocument();
      const input = UpdateProfileInputModel(
        uid: tUid,
        name: tNewName,
        phone: tNewPhone,
        image: 'non_existent/path/to/avatar.jpg',
      );

      // Act
      final result = await sut.updateProfile(input);

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      verifyNever(() => mockAvatarFileRef.putData(any(), any()));
      verifyNever(() => mockAvatarFileRef.putFile(any()));
    });
  });

  group('changePassword', () {
    const tCurrentPassword = 'CurrentPassword123!';
    const tNewPassword = 'NewPassword456!';

    test('should reauthenticate and update password, returning NetworkSuccess<void> when inputs are valid', () async {
      // Arrange & Act
      final result = await sut.changePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockUser.reauthenticateWithCredential(any())).called(1);
      verify(() => mockUser.updatePassword(tNewPassword)).called(1);
    });

    test(
      'should return NetworkFailure with userNotFound when currentUser is null',
      () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await sut.changePassword(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        );

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = result as NetworkFailure<void>;
        expect(failure.error, contains(AppStrings.userNotFound));
        verifyNever(() => mockUser.reauthenticateWithCredential(any()));
        verifyNever(() => mockUser.updatePassword(any()));
      },
    );

    test('should return NetworkFailure with userNotFound when currentUser.email is null', () async {
      // Arrange
      when(() => mockUser.email).thenReturn(null);

      // Act
      final result = await sut.changePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = result as NetworkFailure<void>;
      expect(failure.error, contains(AppStrings.userNotFound));
      verifyNever(() => mockUser.reauthenticateWithCredential(any()));
      verifyNever(() => mockUser.updatePassword(any()));
    });

    test('should return NetworkFailure when reauthentication fails due to wrong password', () async {
      // Arrange
      when(() => mockUser.reauthenticateWithCredential(any()))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));

      // Act
      final result = await sut.changePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      verifyNever(() => mockUser.updatePassword(any()));
    });

    test(
      'should return NetworkFailure when updatePassword throws exception',
      () async {
        // Arrange
        when(() => mockUser.updatePassword(any()))
            .thenThrow(FirebaseAuthException(code: 'weak-password'));

        // Act
        final result = await sut.changePassword(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        );

        // Assert
        expect(result, isA<NetworkFailure<void>>());
      },
    );
  });

  group('Model and Entity Mappings', () {
    const tModel = UpdateProfileInputModel(
      uid: 'user_123',
      name: '  أحمد محمود  ',
      phone: '  01099998888  ',
      image: '  avatar.jpg  ',
    );

    test(
      'fromEntity and toEntity should map all properties bidirectionally',
      () {
        // Arrange
        const entity = UpdateProfileInputEntity(
          uid: 'user_123',
          name: 'أحمد محمود',
          phone: '01099998888',
          image: 'avatar.jpg',
        );

        // Act
        final model = UpdateProfileInputModel.fromEntity(entity);
        final mappedEntity = model.toEntity();

        // Assert
        expect(model.uid, equals(entity.uid));
        expect(model.name, equals(entity.name));
        expect(model.phone, equals(entity.phone));
        expect(model.image, equals(entity.image));

        expect(mappedEntity.uid, equals(entity.uid));
        expect(mappedEntity.name, equals(entity.name));
        expect(mappedEntity.phone, equals(entity.phone));
        expect(mappedEntity.image, equals(entity.image));
      },
    );

    test('fromJson should parse complete json correctly', () {
      // Arrange
      final json = {
        'uid': 'user_123',
        'name': 'أحمد',
        'phone': '01011112222',
        'image': 'avatar.jpg',
      };

      // Act
      final model = UpdateProfileInputModel.fromJson(json);

      // Assert
      expect(model.uid, equals('user_123'));
      expect(model.name, equals('أحمد'));
      expect(model.phone, equals('01011112222'));
      expect(model.image, equals('avatar.jpg'));
    });

    test('fromJson should fallback to empty strings when json keys are null or missing', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final model = UpdateProfileInputModel.fromJson(json);

      // Assert
      expect(model.uid, isEmpty);
      expect(model.name, isEmpty);
      expect(model.phone, isEmpty);
      expect(model.image, isEmpty);
    });

    test('toJson should trim name, phone, and image strings', () {
      // Act
      final json = tModel.toJson();

      // Assert
      expect(json['name'], equals('أحمد محمود'));
      expect(json['phone'], equals('01099998888'));
      expect(json['image'], equals('avatar.jpg'));
      expect(json.containsKey('uid'), isFalse);
    });

    test('copyWith should override only specified properties', () {
      // Act
      final updated = tModel.copyWith(name: 'محمد', phone: '01234567890');

      // Assert
      expect(updated.uid, equals(tModel.uid));
      expect(updated.name, equals('محمد'));
      expect(updated.phone, equals('01234567890'));
      expect(updated.image, equals(tModel.image));
    });
  });
}
