import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/notifications/data/data_sources/remote/notifications_remote_data_source_imp.dart';
import 'package:fruit_hub/features/notifications/data/models/notification_model.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late NotificationsRemoteDataSourceImp sut;

  const tUserId = 'user_123';
  final tTimestamp1 = Timestamp.fromDate(DateTime(2026, 9, 20, 10, 0));
  final tTimestamp2 = Timestamp.fromDate(DateTime(2026, 9, 21, 12, 30));

  final Map<String, dynamic> tNotificationJson1 = {
    'title': 'تم شحن طلبك',
    'body': 'طلبك في الطريق إليك الآن',
    'titleAr': 'تم شحن طلبك',
    'titleEn': 'Your order has been shipped',
    'bodyAr': 'طلبك في الطريق إليك الآن',
    'bodyEn': 'Your order is on the way',
    'type': 'order',
    'isRead': false,
    'orderId': '1001',
    'status': 'shipped',
    'productCode': null,
    'createdAt': tTimestamp1,
  };

  final Map<String, dynamic> tNotificationJson2 = {
    'title': 'خصم خاص',
    'body': 'احصل على خصم 20% على الفواكه الطازجة',
    'titleAr': 'خصم خاص',
    'titleEn': 'Special Discount',
    'bodyAr': 'احصل على خصم 20% على الفواكه الطازجة',
    'bodyEn': 'Get 20% off fresh fruits',
    'type': 'general',
    'isRead': false,
    'orderId': null,
    'status': null,
    'productCode': 'APPLE_01',
    'createdAt': tTimestamp2,
  };

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(tUserId);

    sut = NotificationsRemoteDataSourceImp(
      firestore: fakeFirestore,
      auth: mockFirebaseAuth,
    );
  });

  group('getNotificationsStream', () {
    test('should emit empty list when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final stream = sut.getNotificationsStream();

      // Assert
      await expectLater(stream, emits(isEmpty));
    });

    test('should emit list of NotificationModels ordered by createdAt descending when documents exist', () async {
      // Arrange
      final notifsCollection = fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .collection(BackendEndpoints.notificationsCollection);

      await notifsCollection.doc('notif_1').set(tNotificationJson1);
      await notifsCollection.doc('notif_2').set(tNotificationJson2);

      // Act
      final stream = sut.getNotificationsStream();

      // Assert
      await expectLater(
        stream,
        emits(
          predicate<List<NotificationModel>>(
            (list) =>
                list.length == 2 &&
                list[0].id == 'notif_2' &&
                list[0].type == NotificationType.general &&
                list[1].id == 'notif_1' &&
                list[1].type == NotificationType.order,
          ),
        ),
      );
    });

    test(
      'should emit real-time updates when new notification is added or updated',
      () async {
        // Arrange
        final notifsCollection = fakeFirestore
            .collection(BackendEndpoints.usersCollection)
            .doc(tUserId)
            .collection(BackendEndpoints.notificationsCollection);

        await notifsCollection.doc('notif_1').set(tNotificationJson1);

        final stream = sut.getNotificationsStream();

        // Act & Assert
        final expectation = expectLater(
          stream,
          emitsInOrder([
            predicate<List<NotificationModel>>((list) => list.length == 1),
            predicate<List<NotificationModel>>((list) => list.length == 2),
            predicate<List<NotificationModel>>(
              (list) =>
                  list.firstWhere((n) => n.id == 'notif_1').isRead == true,
            ),
          ]),
        );

        await pumpEventQueue();

        // Add second notification
        await notifsCollection.doc('notif_2').set(tNotificationJson2);
        await pumpEventQueue();

        // Update first notification
        await notifsCollection.doc('notif_1').update({'isRead': true});
        await pumpEventQueue();

        await expectation;
      },
    );

    test('should not emit notifications belonging to another user', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc('other_user_456')
          .collection(BackendEndpoints.notificationsCollection)
          .doc('other_notif')
          .set(tNotificationJson1);

      // Act
      final stream = sut.getNotificationsStream();

      // Assert
      await expectLater(stream, emits(isEmpty));
    });
  });

  group('markAsRead', () {
    const tNotifId = 'notif_1';

    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.markAsRead(tNotifId);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should update isRead to true in Firestore and return NetworkSuccess<void> when notification exists', () async {
      // Arrange
      final notifDocRef = fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .collection(BackendEndpoints.notificationsCollection)
          .doc(tNotifId);

      await notifDocRef.set(tNotificationJson1);

      // Act
      final result = await sut.markAsRead(tNotifId);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      final updatedDoc = await notifDocRef.get();
      expect(updatedDoc.data()?['isRead'], true);
      expect(updatedDoc.data()?['title'], tNotificationJson1['title']);
    });
  });

  group('markAllAsRead', () {
    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.markAllAsRead();

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should return NetworkSuccess<void> and do nothing when there are no unread notifications', () async {
      // Arrange
      final notifsCollection = fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .collection(BackendEndpoints.notificationsCollection);

      final readNotification = Map<String, dynamic>.from(tNotificationJson1)
        ..['isRead'] = true;
      await notifsCollection.doc('notif_1').set(readNotification);

      // Act
      final result = await sut.markAllAsRead();

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      final doc = await notifsCollection.doc('notif_1').get();
      expect(doc.data()?['isRead'], true);
    });

    test('should update all unread notifications to isRead true via batch and return NetworkSuccess<void>', () async {
      // Arrange
      final notifsCollection = fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .collection(BackendEndpoints.notificationsCollection);

      await notifsCollection.doc('notif_1').set(tNotificationJson1);
      await notifsCollection.doc('notif_2').set(tNotificationJson2);
      await notifsCollection
          .doc('notif_3')
          .set(
            Map<String, dynamic>.from(tNotificationJson1)..['isRead'] = true,
          );

      // Act
      final result = await sut.markAllAsRead();

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      final doc1 = await notifsCollection.doc('notif_1').get();
      final doc2 = await notifsCollection.doc('notif_2').get();
      final doc3 = await notifsCollection.doc('notif_3').get();

      expect(doc1.data()?['isRead'], true);
      expect(doc2.data()?['isRead'], true);
      expect(doc3.data()?['isRead'], true);

      // Verify other fields remain intact
      expect(doc1.data()?['title'], tNotificationJson1['title']);
      expect(doc2.data()?['productCode'], tNotificationJson2['productCode']);
    });
  });

  group('Model and Entity Mappings', () {
    test('should map fromFirestore and toEntity correctly with all properties including bilingual fields', () {
      // Arrange
      final date = DateTime(2026, 9, 20, 10, 0);
      final json = {
        'title': 'عنوان الإشعار',
        'body': 'نص الإشعار',
        'titleAr': 'عنوان عربي',
        'titleEn': 'English Title',
        'bodyAr': 'نص عربي',
        'bodyEn': 'English Body',
        'type': 'order',
        'isRead': false,
        'orderId': 1001,
        'status': 'pending',
        'productCode': 'FRUIT_1',
        'createdAt': Timestamp.fromDate(date),
      };

      // Act
      final model = NotificationModel.fromFirestore(json, 'doc_xyz');
      final entity = model.toEntity();

      // Assert
      expect(model.id, 'doc_xyz');
      expect(model.title, 'عنوان الإشعار');
      expect(model.body, 'نص الإشعار');
      expect(model.titleAr, 'عنوان عربي');
      expect(model.titleEn, 'English Title');
      expect(model.bodyAr, 'نص عربي');
      expect(model.bodyEn, 'English Body');
      expect(model.type, NotificationType.order);
      expect(model.isRead, false);
      expect(model.orderId, '1001');
      expect(model.status, 'pending');
      expect(model.productCode, 'FRUIT_1');
      expect(model.createdAt, date);

      expect(entity.id, model.id);
      expect(entity.title, model.title);
      expect(entity.body, model.body);
      expect(entity.titleAr, model.titleAr);
      expect(entity.titleEn, model.titleEn);
      expect(entity.bodyAr, model.bodyAr);
      expect(entity.bodyEn, model.bodyEn);
      expect(entity.type, model.type);
      expect(entity.isRead, model.isRead);
      expect(entity.orderId, model.orderId);
      expect(entity.status, model.status);
      expect(entity.productCode, model.productCode);
      expect(entity.createdAt, model.createdAt);
    });

    test(
      'should parse ISO 8601 string for createdAt in fromFirestore correctly',
      () {
        // Arrange
        const dateString = '2026-09-20T10:00:00.000';
        final json = {
          'title': 'Test Title',
          'body': 'Test Body',
          'type': 'general',
          'createdAt': dateString,
        };

        // Act
        final model = NotificationModel.fromFirestore(json, 'doc_1');

        // Assert
        expect(model.createdAt, DateTime.parse(dateString));
      },
    );

    test('should handle missing or null fields gracefully in fromFirestore with fallback defaults', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final model = NotificationModel.fromFirestore(json, 'doc_fallback');

      // Assert
      expect(model.id, 'doc_fallback');
      expect(model.title, '');
      expect(model.body, '');
      expect(model.titleAr, isNull);
      expect(model.titleEn, isNull);
      expect(model.bodyAr, isNull);
      expect(model.bodyEn, isNull);
      expect(model.type, NotificationType.general);
      expect(model.isRead, false);
      expect(model.orderId, isNull);
      expect(model.status, isNull);
      expect(model.productCode, isNull);
      expect(model.createdAt, isNull);
    });

    test(
      'should serialize to toJson with expected keys and conditional fields',
      () {
        // Arrange
        final date = DateTime(2026, 9, 20, 10, 0);
        final model = NotificationModel(
          id: 'doc_1',
          title: 'Title',
          body: 'Body',
          titleAr: 'عربي',
          titleEn: 'English',
          bodyAr: 'نص',
          bodyEn: 'Body En',
          type: NotificationType.order,
          isRead: true,
          orderId: '1001',
          status: 'delivered',
          productCode: 'APPLE_01',
          createdAt: date,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['title'], 'Title');
        expect(json['body'], 'Body');
        expect(json['titleAr'], 'عربي');
        expect(json['titleEn'], 'English');
        expect(json['bodyAr'], 'نص');
        expect(json['bodyEn'], 'Body En');
        expect(json['type'], 'order');
        expect(json['isRead'], true);
        expect(json['orderId'], '1001');
        expect(json['status'], 'delivered');
        expect(json['productCode'], 'APPLE_01');
        expect(json['createdAt'], Timestamp.fromDate(date));
      },
    );

    test(
      'should omit conditional keys from toJson when properties are null',
      () {
        // Arrange
        const model = NotificationModel(
          id: 'doc_1',
          title: 'Title',
          body: 'Body',
          type: NotificationType.general,
          isRead: false,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json.containsKey('titleAr'), false);
        expect(json.containsKey('titleEn'), false);
        expect(json.containsKey('bodyAr'), false);
        expect(json.containsKey('bodyEn'), false);
        expect(json.containsKey('orderId'), false);
        expect(json.containsKey('status'), false);
        expect(json.containsKey('productCode'), false);
        expect(json.containsKey('createdAt'), false);
      },
    );

    test(
      'should return correct localized title and body on NotificationEntity',
      () {
        // Arrange
        const entity = NotificationModel(
          id: '1',
          title: 'Fallback Title',
          body: 'Fallback Body',
          titleAr: 'عنوان عربي',
          titleEn: 'English Title',
          bodyAr: 'محتوى عربي',
          bodyEn: 'English Content',
          type: NotificationType.general,
          isRead: false,
        );

        final notifEntity = entity.toEntity();

        // Act & Assert
        expect(notifEntity.localizedTitle(true), 'عنوان عربي');
        expect(notifEntity.localizedTitle(false), 'English Title');
        expect(notifEntity.localizedBody(true), 'محتوى عربي');
        expect(notifEntity.localizedBody(false), 'English Content');

        // Test fallback to legacy title/body when bilingual fields are null
        const fallbackEntity = NotificationModel(
          id: '2',
          title: 'Legacy Title',
          body: 'Legacy Body',
          type: NotificationType.general,
          isRead: false,
        );
        final fallbackNotifEntity = fallbackEntity.toEntity();

        expect(fallbackNotifEntity.localizedTitle(true), 'Legacy Title');
        expect(fallbackNotifEntity.localizedTitle(false), 'Legacy Title');
        expect(fallbackNotifEntity.localizedBody(true), 'Legacy Body');
        expect(fallbackNotifEntity.localizedBody(false), 'Legacy Body');
      },
    );
  });
}
