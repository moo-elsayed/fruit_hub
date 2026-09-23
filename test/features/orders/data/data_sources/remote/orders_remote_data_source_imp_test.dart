import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/order_item_model.dart';
import 'package:fruit_hub/core/models/order_model.dart';
import 'package:fruit_hub/features/checkout/data/models/address_model.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/orders/data/data_sources/remote/orders_remote_data_source_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late OrdersRemoteDataSourceImp sut;

  const tUserId = 'user_123';

  final Map<String, dynamic> tAddressJson = {
    'name': 'أحمد محمد',
    'email': 'ahmed@example.com',
    'phone': '01012345678',
    'city': 'القاهرة',
    'street': 'شارع التحرير',
    'building_number': '10',
    'floor_number': '3',
    'apartment_number': '5',
  };

  final Map<String, dynamic> tOrderItemJson = {
    'name': 'تفاح أحمر',
    'code': 'APPLE_01',
    'imageUrl': 'assets/images/red_apple.png',
    'price': 25.0,
    'quantity': 2,
  };

  final Map<String, dynamic> tOrderJson1 = {
    'uId': tUserId,
    'orderId': 1001,
    'totalPrice': 80.0,
    'status': 'pending',
    'paymentMethod': 'Cash',
    'date': '2026-09-01T10:00:00',
    'shippingAddress': tAddressJson,
    'orderItems': [tOrderItemJson],
  };

  final Map<String, dynamic> tOrderJson2 = {
    'uId': tUserId,
    'orderId': 1002,
    'totalPrice': 150.0,
    'status': 'shipped',
    'paymentMethod': 'Paypal',
    'date': '2026-09-05T12:00:00',
    'shippingAddress': tAddressJson,
    'orderItems': [tOrderItemJson],
  };

  final Map<String, dynamic> tOtherUserOrderJson = {
    'uId': 'other_user_456',
    'orderId': 2001,
    'totalPrice': 200.0,
    'status': 'pending',
    'paymentMethod': 'Credit Card',
    'date': '2026-09-06T14:00:00',
    'shippingAddress': tAddressJson,
    'orderItems': [tOrderItemJson],
  };

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(tUserId);

    sut = OrdersRemoteDataSourceImp(
      firestore: fakeFirestore,
      auth: mockFirebaseAuth,
    );
  });

  group('streamUserOrders', () {
    test('should emit empty list when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final stream = sut.streamUserOrders();

      // Assert
      await expectLater(stream, emits(isEmpty));
    });

    test('should emit empty list when currentUser uid is empty', () async {
      // Arrange
      when(() => mockUser.uid).thenReturn('');

      // Act
      final stream = sut.streamUserOrders();

      // Assert
      await expectLater(stream, emits(isEmpty));
    });

    test(
      'should emit empty list when user has no orders in firestore',
      () async {
        // Arrange - collection is empty

        // Act
        final stream = sut.streamUserOrders();

        // Assert
        await expectLater(stream, emits(isEmpty));
      },
    );

    test('should emit only orders matching currentUser uid sorted by date descending', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc('DOC_1')
          .set(tOrderJson1); // date: 2026-09-01
      await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc('DOC_2')
          .set(tOrderJson2); // date: 2026-09-05 (newer)
      await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc('DOC_OTHER')
          .set(tOtherUserOrderJson); // different user

      // Act
      final stream = sut.streamUserOrders();

      // Assert
      await expectLater(
        stream,
        emits(
          isA<List<OrderModel>>()
              .having((list) => list.length, 'length', 2)
              .having(
                (list) => list.first.orderId,
                'first orderId (newer)',
                1002,
              )
              .having((list) => list.first.docId, 'first docId', 'DOC_2')
              .having((list) => list.last.orderId, 'second orderId', 1001)
              .having((list) => list.last.docId, 'second docId', 'DOC_1'),
        ),
      );
    });

    test('should emit updated list in real-time when new order is added to Firestore', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc('DOC_1')
          .set(tOrderJson1);

      final stream = sut.streamUserOrders();

      // Assert & Act
      final completer = Completer<void>();
      var emissionCount = 0;

      final subscription = stream.listen((orders) {
        emissionCount++;
        if (emissionCount == 1) {
          expect(orders, hasLength(1));
          expect(orders.first.orderId, 1001);
          // Trigger real-time update
          fakeFirestore
              .collection(BackendEndpoints.ordersCollection)
              .doc('DOC_2')
              .set(tOrderJson2);
        } else if (emissionCount == 2) {
          expect(orders, hasLength(2));
          expect(orders.first.orderId, 1002);
          completer.complete();
        }
      });

      await completer.future;
      await subscription.cancel();
    });
  });

  group('streamOrderById', () {
    test('should stream order when found by numeric orderId query', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc('CUSTOM_DOC_ID')
          .set(tOrderJson1); // orderId: 1001

      // Act
      final stream = sut.streamOrderById('1001');

      // Assert
      await expectLater(
        stream,
        emits(
          isA<OrderModel>()
              .having((o) => o.orderId, 'orderId', 1001)
              .having((o) => o.docId, 'docId', 'CUSTOM_DOC_ID')
              .having((o) => o.status, 'status', OrderStatus.pending),
        ),
      );
    });

    test('should stream order by docId fallback when numericId is not matched in query but doc exists with that id', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc('1001')
          .set({
            ...tOrderJson1,
            'orderId': 9999, // query for orderId=1001 will be empty, but docId is '1001'
          });

      // Act
      final stream = sut.streamOrderById('1001');

      // Assert
      await expectLater(
        stream,
        emits(
          isA<OrderModel>()
              .having((o) => o.docId, 'docId', '1001')
              .having((o) => o.orderId, 'orderId', 9999),
        ),
      );
    });

    test('should emit BusinessException with notFoundError when numeric orderId does not exist by query or docId', () async {
      // Arrange - empty collection

      // Act
      final stream = sut.streamOrderById('99999');

      // Assert
      await expectLater(
        stream,
        emitsError(
          isA<BusinessException>().having(
            (e) => e.message,
            'message',
            AppStrings.notFoundError,
          ),
        ),
      );
    });

    test('should stream order when orderId is non-numeric string and document exists', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc('DOC_STRING_ID')
          .set(tOrderJson2);

      // Act
      final stream = sut.streamOrderById('DOC_STRING_ID');

      // Assert
      await expectLater(
        stream,
        emits(
          isA<OrderModel>()
              .having((o) => o.docId, 'docId', 'DOC_STRING_ID')
              .having((o) => o.orderId, 'orderId', 1002)
              .having((o) => o.status, 'status', OrderStatus.shipped),
        ),
      );
    });

    test('should emit BusinessException with notFoundError when non-numeric document does not exist', () async {
      // Arrange - non-existent doc

      // Act
      final stream = sut.streamOrderById('NON_EXISTENT_DOC');

      // Assert
      await expectLater(
        stream,
        emitsError(
          isA<BusinessException>().having(
            (e) => e.message,
            'message',
            AppStrings.notFoundError,
          ),
        ),
      );
    });

    test(
      'should emit real-time updates when document is updated in firestore',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.ordersCollection)
            .doc('REALTIME_DOC')
            .set(tOrderJson1);

        final stream = sut.streamOrderById('REALTIME_DOC');

        // Assert & Act
        final completer = Completer<void>();
        var emissionCount = 0;

        final subscription = stream.listen((order) {
          emissionCount++;
          if (emissionCount == 1) {
            expect(order.status, OrderStatus.pending);
            // Update order status in firestore
            fakeFirestore
                .collection(BackendEndpoints.ordersCollection)
                .doc('REALTIME_DOC')
                .update({'status': 'delivered'});
          } else if (emissionCount == 2) {
            expect(order.status, OrderStatus.delivered);
            completer.complete();
          }
        });

        await completer.future;
        await subscription.cancel();
      },
    );
  });

  group('cancelOrder', () {
    const tDocId = 'ORDER_DOC_ID';

    test('should throw BusinessException with notFoundError when document does not exist', () async {
      // Arrange - document does not exist

      // Act & Assert
      expect(
        () => sut.cancelOrder('NON_EXISTENT_DOC'),
        throwsA(
          isA<BusinessException>().having(
            (e) => e.message,
            'message',
            AppStrings.notFoundError,
          ),
        ),
      );
    });

    test('should throw BusinessException with cannotCancelOrder when status is not pending', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc(tDocId)
          .set({...tOrderJson1, 'status': 'shipped'});

      // Act & Assert
      await expectLater(
        () => sut.cancelOrder(tDocId),
        throwsA(
          isA<BusinessException>().having(
            (e) => e.message,
            'message',
            AppStrings.cannotCancelOrder,
          ),
        ),
      );

      // Verify status was NOT modified
      final doc = await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc(tDocId)
          .get();
      expect(doc.data()!['status'], 'shipped');
    });

    test('should throw BusinessException with cannotCancelOrder when status is already cancelled', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc(tDocId)
          .set({...tOrderJson1, 'status': 'cancelled'});

      // Act & Assert
      await expectLater(
        () => sut.cancelOrder(tDocId),
        throwsA(
          isA<BusinessException>().having(
            (e) => e.message,
            'message',
            AppStrings.cannotCancelOrder,
          ),
        ),
      );
    });

    test('should update order status to cancelled in Firestore when order status is pending', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc(tDocId)
          .set({...tOrderJson1, 'status': 'pending'});

      // Act
      await sut.cancelOrder(tDocId);

      // Assert
      final updatedDoc = await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .doc(tDocId)
          .get();
      expect(updatedDoc.data()!['status'], 'cancelled');
    });
  });

  group('Model and Entity Mappings', () {
    test(
      'OrderModel toEntity and fromEntity should map all properties correctly',
      () {
        // Arrange
        const addressEntity = AddressEntity(
          name: 'عمرو',
          email: 'amr@test.com',
          phone: '01000000000',
          city: 'الجيزة',
          streetName: 'شارع الهرم',
          buildingNumber: '15',
          floorNumber: '2',
          apartmentNumber: '4',
        );

        const itemEntity = OrderItemEntity(
          name: 'برتقال',
          code: 'ORANGE_01',
          imagePath: 'assets/images/orange.png',
          price: 20.0,
          quantity: 3,
        );

        const orderEntity = OrderEntity(
          docId: 'DOC_123',
          uId: 'USER_123',
          orderId: 777,
          totalPrice: 100.0,
          status: OrderStatus.processing,
          paymentOption: PaymentOptionEntity(
            title: 'Cash',
            type: PaymentMethodType.cash,
            shippingCost: 40.0,
          ),
          date: '2026-09-22',
          shippingAddress: addressEntity,
          orderItems: [itemEntity],
        );

        // Act
        final model = OrderModel.fromEntity(orderEntity);
        final mappedEntity = model.toEntity();

        // Assert
        expect(model.docId, orderEntity.docId);
        expect(model.uId, orderEntity.uId);
        expect(model.orderId, orderEntity.orderId);
        expect(model.totalPrice, orderEntity.totalPrice);
        expect(model.status, orderEntity.status);
        expect(
          model.paymentMethod,
          orderEntity.paymentOption.type.databaseValue,
        );
        expect(model.date, orderEntity.date);
        expect(model.shippingAddress.name, addressEntity.name);
        expect(model.orderItems, hasLength(1));
        expect(model.orderItems.first.name, itemEntity.name);

        expect(mappedEntity.docId, orderEntity.docId);
        expect(mappedEntity.uId, orderEntity.uId);
        expect(mappedEntity.orderId, orderEntity.orderId);
        expect(mappedEntity.totalPrice, orderEntity.totalPrice);
        expect(mappedEntity.status, orderEntity.status);
        expect(mappedEntity.paymentOption.type, PaymentMethodType.cash);
        expect(mappedEntity.shippingAddress.name, addressEntity.name);
        expect(mappedEntity.orderItems.first.name, itemEntity.name);
      },
    );

    test('OrderModel fromJson and toJson should serialize and deserialize correctly', () {
      // Arrange
      final json = {
        'uId': 'USER_999',
        'orderId': 888,
        'totalPrice': 250.5,
        'status': 'delivered',
        'paymentMethod': 'Card',
        'date': '2026-09-20',
        'shippingAddress': tAddressJson,
        'orderItems': [tOrderItemJson],
      };

      // Act
      final model = OrderModel.fromJson(json, docId: 'DOC_999');
      final outputJson = model.toJson();

      // Assert
      expect(model.docId, 'DOC_999');
      expect(model.uId, 'USER_999');
      expect(model.orderId, 888);
      expect(model.totalPrice, 250.5);
      expect(model.status, OrderStatus.delivered);
      expect(model.paymentMethod, 'Card');
      expect(model.date, '2026-09-20');
      expect(outputJson['uId'], 'USER_999');
      expect(outputJson['orderId'], 888);
      expect(outputJson['totalPrice'], 250.5);
      expect(outputJson['status'], 'delivered');
    });

    test('OrderModel fromJson should handle fallback and coercion on null/missing fields', () {
      // Arrange
      final emptyJson = <String, dynamic>{
        'totalPrice': 50, // int coerced to double
        'orderId': 123.0, // num coerced to int
      };

      // Act
      final model = OrderModel.fromJson(emptyJson);

      // Assert
      expect(model.docId, '');
      expect(model.uId, '');
      expect(model.totalPrice, 50.0);
      expect(model.totalPrice, isA<double>());
      expect(model.orderId, 123);
      expect(model.status, OrderStatus.pending);
      expect(model.paymentMethod, '');
      expect(model.date, '');
      expect(model.orderItems, isEmpty);
      expect(model.shippingAddress.name, '');
    });

    test(
      'OrderModel toPaypalTransaction should construct correct paypal payload',
      () {
        // Arrange
        final order = OrderModel(
          docId: 'PAYPAL_ORDER',
          uId: tUserId,
          orderId: 3001,
          totalPrice: 100.0,
          status: OrderStatus.pending,
          paymentMethod: 'Paypal',
          date: '2026-09-22',
          shippingAddress: AddressModel.fromJson(tAddressJson),
          orderItems: [
            const OrderItemModel(
              name: 'مانجو',
              code: 'MANGO_01',
              imagePath: 'mango.png',
              price: 40.0,
              quantity: 2,
            ),
          ],
        );

        // Act
        final paypalPayload = order.toPaypalTransaction();

        // Assert
        expect(paypalPayload['amount']['total'], '100.00');
        expect(paypalPayload['amount']['currency'], 'USD');
        expect(paypalPayload['amount']['details']['subtotal'], '80.00');
        expect(paypalPayload['amount']['details']['shipping'], '20.00');
        expect(paypalPayload['item_list']['items'], hasLength(1));
        expect(paypalPayload['item_list']['items'].first['name'], 'مانجو');
        expect(
          paypalPayload['shipping_address']['recipient_name'],
          'أحمد محمد',
        );
      },
    );

    test('OrderItemModel fromCartItemEntity should convert correctly', () {
      // Arrange
      const fruit = FruitEntity(
        code: 'GRAPE_01',
        name: 'عنب',
        price: 35.0,
        imagePath: 'grape.png',
      );
      const cartItem = CartItemEntity(fruitEntity: fruit, quantity: 4);

      // Act
      final model = OrderItemModel.fromEntity(cartItem);

      // Assert
      expect(model.code, 'GRAPE_01');
      expect(model.name, 'عنب');
      expect(model.price, 35.0);
      expect(model.quantity, 4);
      expect(model.imagePath, 'grape.png');
    });

    test(
      'OrderItemModel fromJson should support imagePath fallback from imageUrl',
      () {
        // Arrange
        final json = {
          'name': 'خوخ',
          'code': 'PEACH_01',
          'imageUrl': 'peach.png',
          'price': 15,
          'quantity': 3.0,
        };

        // Act
        final model = OrderItemModel.fromJson(json);

        // Assert
        expect(model.name, 'خوخ');
        expect(model.code, 'PEACH_01');
        expect(model.imagePath, 'peach.png');
        expect(model.price, 15.0);
        expect(model.quantity, 3);
      },
    );

    test('AddressModel fromEntity, toEntity, fromJson, and toJson should map all properties', () {
      // Arrange
      const entity = AddressEntity(
        name: 'سارة',
        email: 'sara@test.com',
        phone: '01111111111',
        city: 'الإسكندرية',
        streetName: 'طريق الكورنيش',
        buildingNumber: '5',
        floorNumber: '1',
        apartmentNumber: '2',
        latitude: 31.2,
        longitude: 29.9,
      );

      // Act
      final model = AddressModel.fromEntity(entity);
      final mappedEntity = model.toEntity();
      final json = model.toJson();
      final fromJsonModel = AddressModel.fromJson(json);

      // Assert
      expect(model.name, entity.name);
      expect(model.city, entity.city);
      expect(model.latitude, 31.2);
      expect(mappedEntity, equals(entity));
      expect(fromJsonModel.name, entity.name);
      expect(fromJsonModel.city, entity.city);
      expect(fromJsonModel.latitude, 31.2);
    });
  });
}
