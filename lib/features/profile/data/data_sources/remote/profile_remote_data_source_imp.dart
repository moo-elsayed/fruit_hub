import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';

import '../../models/update_profile_input_model.dart';
import 'profile_remote_data_source.dart';

class ProfileRemoteDataSourceImp implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImp({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? firebaseStorage,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = firebaseStorage ?? FirebaseStorage.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<NetworkResponse<UserModel>> updateProfile(
    UpdateProfileInputModel input,
  ) async => ApiHelper.executeSafely(() async {
    final docRef = _firestore
        .collection(BackendEndpoints.usersCollection)
        .doc(input.uid);

    String imageUrl = input.image.trim();
    final avatarStoragePath =
        '${BackendEndpoints.userAvatarsStorage}/${input.uid}';

    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        try {
          final listResult =
              await _storage.ref().child(avatarStoragePath).listAll();
          for (final item in listResult.items) {
            await item.delete();
          }
        } catch (_) {}

        final extension =
            file.path.contains('.') ? file.path.split('.').last : 'jpg';
        final ref =
            _storage.ref().child('$avatarStoragePath/avatar.$extension');
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();
      }
    } else if (imageUrl.isEmpty) {
      try {
        final listResult =
            await _storage.ref().child(avatarStoragePath).listAll();
        for (final item in listResult.items) {
          await item.delete();
        }
      } catch (_) {}
    }

    final modelToSave = input.copyWith(image: imageUrl);
    await docRef.set(modelToSave.toJson(), SetOptions(merge: true));

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null && currentUser.uid == input.uid) {
      if (input.name.trim().isNotEmpty) {
        await currentUser.updateDisplayName(input.name.trim());
      }
      await currentUser.updatePhotoURL(imageUrl.isNotEmpty ? imageUrl : null);
    }

    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists || docSnapshot.data() == null) {
      throw BusinessException(AppStrings.userNotFound);
    }

    return UserModel.fromJson(docSnapshot.data()!);
  }, functionName: 'updateProfile');

  @override
  Future<NetworkResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => ApiHelper.executeSafely(() async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw BusinessException(AppStrings.userNotFound);
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }, functionName: 'changePassword');
}
