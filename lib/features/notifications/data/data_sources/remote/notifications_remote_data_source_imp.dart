import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../../models/notification_model.dart';
import 'notifications_remote_data_source.dart';

class NotificationsRemoteDataSourceImp
    implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImp({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _userNotificationsRef(
    String userId,
  ) => _firestore
      .collection(BackendEndpoints.usersCollection)
      .doc(userId)
      .collection(BackendEndpoints.notificationsCollection);

  @override
  Stream<List<NotificationModel>> getNotificationsStream() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value(<NotificationModel>[]);
    }

    return _userNotificationsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<NetworkResponse<void>> markAsRead(String notificationId) async =>
      ApiHelper.executeSafely(() async {
        final userId = _currentUserId;
        if (userId == null) {
          throw BusinessException(AppStrings.userNotFound);
        }

        await _userNotificationsRef(userId)
            .doc(notificationId)
            .update({'isRead': true});
      }, functionName: 'markAsRead');

  @override
  Future<NetworkResponse<void>> markAllAsRead() async =>
      ApiHelper.executeSafely(() async {
        final userId = _currentUserId;
        if (userId == null) {
          throw BusinessException(AppStrings.userNotFound);
        }

        final unreadDocs = await _userNotificationsRef(userId)
            .where('isRead', isEqualTo: false)
            .get();

        if (unreadDocs.docs.isEmpty) return;

        final batch = _firestore.batch();
        for (final doc in unreadDocs.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }, functionName: 'markAllAsRead');
}
