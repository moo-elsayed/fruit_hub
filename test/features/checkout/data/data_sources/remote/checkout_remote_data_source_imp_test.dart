import 'package:dio/dio.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/helpers/api_constants.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/order_item_model.dart';
import 'package:fruit_hub/core/models/order_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source_imp.dart';
import 'package:fruit_hub/features/checkout/data/models/address_model.dart';
import 'package:fruit_hub/features/checkout/data/models/payment_input_model.dart';
import 'package:fruit_hub/features/checkout/data/models/shipping_config_model.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_input_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockDio extends Mock implements Dio {}

class MockStripe extends Mock implements Stripe {}

class FakeOptions extends Fake implements Options {}

class FakeSetupPaymentSheetParameters extends Fake
    implements SetupPaymentSheetParameters {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOptions());
    registerFallbackValue(FakeSetupPaymentSheetParameters());
  });

  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockDio mockDio;
  late MockStripe mockStripe;
  late CheckoutRemoteDataSourceImp sut;

  const tUserId = 'user_checkout_123';

  final tAddressModel = AddressModel(
    name: 'أحمد محمد',
    email: 'ahmed@example.com',
    phone: '01012345678',
    city: 'القاهرة',
    streetName: 'شارع التحرير',
    buildingNumber: '10',
    floorNumber: '3',
    apartmentNumber: '5',
    latitude: 30.0444,
    longitude: 31.2357,
  );

  const tOrderItemModel = OrderItemModel(
    name: 'تفاح أحمر',
    code: 'APPLE_01',
    imagePath: 'assets/images/red_apple.png',
    price: 25.0,
    quantity: 2,
  );

  final tOrderModel = OrderModel(
    uId: tUserId,
    orderId: 1001,
    totalPrice: 50.0,
    status: OrderStatus.pending,
    paymentMethod: 'Cash',
    date: '2026-09-24T10:00:00',
    shippingAddress: tAddressModel,
    orderItems: const [tOrderItemModel],
  );

  final tPaymentInput = PaymentInputModel(amount: 150.0, currency: 'EGP');

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockDio = MockDio();
    mockStripe = MockStripe();

    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(tUserId);

    sut = CheckoutRemoteDataSourceImp(
      dio: mockDio,
      stripe: mockStripe,
      firestore: fakeFirestore,
      auth: mockFirebaseAuth,
    );
  });

  group('fetchShippingConfig', () {
    test('should return NetworkSuccess with ShippingConfigModel when document exists and has valid data', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.constantsCollection)
          .doc(BackendEndpoints.shippingConfigDoc)
          .set({
            BackendEndpoints.shippingCostField: 35.0,
            BackendEndpoints.freeShippingThresholdField: 250.0,
          });

      // Act
      final result = await sut.fetchShippingConfig();

      // Assert
      expect(result, isA<NetworkSuccess<ShippingConfigModel>>());
      final data = (result as NetworkSuccess<ShippingConfigModel>).data;
      expect(data, isNotNull);
      expect(data!.shippingCost, 35.0);
      expect(data.freeShippingThreshold, 250.0);
    });

    test('should return NetworkSuccess with ShippingConfigModel when freeShippingThreshold is null', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.constantsCollection)
          .doc(BackendEndpoints.shippingConfigDoc)
          .set({BackendEndpoints.shippingCostField: 20.0});

      // Act
      final result = await sut.fetchShippingConfig();

      // Assert
      expect(result, isA<NetworkSuccess<ShippingConfigModel>>());
      final data = (result as NetworkSuccess<ShippingConfigModel>).data;
      expect(data, isNotNull);
      expect(data!.shippingCost, 20.0);
      expect(data.freeShippingThreshold, isNull);
    });

    test('should return NetworkFailure with unexpectedError when document does not exist', () async {
      // Arrange - collection is empty

      // Act
      final result = await sut.fetchShippingConfig();

      // Assert
      expect(result, isA<NetworkFailure<ShippingConfigModel>>());
      final failure = (result as NetworkFailure<ShippingConfigModel>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });

    test('should return NetworkFailure when document data has invalid format causing parsing exception', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.constantsCollection)
          .doc(BackendEndpoints.shippingConfigDoc)
          .set({BackendEndpoints.shippingCostField: 'not_a_number_type'});

      // Act
      final result = await sut.fetchShippingConfig();

      // Assert
      expect(result, isA<NetworkFailure<ShippingConfigModel>>());
      final failure = (result as NetworkFailure<ShippingConfigModel>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('addOrder', () {
    test('should return NetworkSuccess and save order to firestore when order is valid', () async {
      // Arrange

      // Act
      final result = await sut.addOrder(tOrderModel);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      final snapshot = await fakeFirestore
          .collection(BackendEndpoints.ordersCollection)
          .get();
      expect(snapshot.docs, hasLength(1));
      final savedData = snapshot.docs.first.data();
      expect(savedData['uId'], tOrderModel.uId);
      expect(savedData['orderId'], tOrderModel.orderId);
      expect(savedData['totalPrice'], tOrderModel.totalPrice);
      expect(savedData['status'], tOrderModel.status.name);
      expect(savedData['paymentMethod'], tOrderModel.paymentMethod);
      expect(savedData['shippingAddress']['city'], 'القاهرة');
      expect(savedData['orderItems'], hasLength(1));
      expect(savedData['orderItems'][0]['code'], 'APPLE_01');
    });

    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.addOrder(tOrderModel);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should return NetworkFailure when an exception occurs during adding order', () async {
      // Arrange
      when(() => mockUser.uid).thenThrow(Exception('Firestore exception'));

      // Act
      final result = await sut.addOrder(tOrderModel);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('makePayment', () {
    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.makePayment(tPaymentInput);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should create customer, merge customerId preserving existing user fields, create keys, init sheet, and present sheet when user has no customerId', () async {
      // Arrange
      const tNewCustomerId = 'cus_new_456';
      const tClientSecret = 'pi_test_secret_789';
      const tEphemeralKeySecret = 'ek_test_secret_012';

      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            'name': 'محمد حسام',
            'email': 'mohamed@example.com',
            'phone': '01099887766',
          });

      when(
        () => mockDio.post(
          ApiConstants.createCustomerUrl,
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.createCustomerUrl),
          data: {'id': tNewCustomerId},
          statusCode: 200,
        ),
      );

      when(
        () => mockDio.post(
          ApiConstants.createEphemeralKeyUrl,
          data: {'customer': tNewCustomerId},
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.createEphemeralKeyUrl,
          ),
          data: {'secret': tEphemeralKeySecret},
          statusCode: 200,
        ),
      );

      when(
        () => mockDio.post(
          ApiConstants.createPaymentIntentUrl,
          data: {
            'amount': tPaymentInput.amountInCents,
            'currency': tPaymentInput.currency,
            'customer': tNewCustomerId,
            'payment_method_types[]': 'card',
          },
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.createPaymentIntentUrl,
          ),
          data: {'client_secret': tClientSecret},
          statusCode: 200,
        ),
      );

      when(
        () => mockStripe.initPaymentSheet(
          paymentSheetParameters: any(named: 'paymentSheetParameters'),
        ),
      ).thenAnswer((_) async => null);

      when(() => mockStripe.presentPaymentSheet())
          .thenAnswer((_) async => null);

      // Act
      final result = await sut.makePayment(tPaymentInput);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());

      // Verify SetOptions(merge: true) preserved existing fields
      final userDoc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final userData = userDoc.data()!;
      expect(userData[BackendEndpoints.customerIdField], tNewCustomerId);
      expect(userData['name'], 'محمد حسام');
      expect(userData['email'], 'mohamed@example.com');
      expect(userData['phone'], '01099887766');

      // Verify interactions
      verify(
        () => mockDio.post(
          ApiConstants.createCustomerUrl,
          options: any(named: 'options'),
        ),
      ).called(1);
      verify(
        () => mockDio.post(
          ApiConstants.createEphemeralKeyUrl,
          data: {'customer': tNewCustomerId},
          options: any(named: 'options'),
        ),
      ).called(1);
      verify(
        () => mockDio.post(
          ApiConstants.createPaymentIntentUrl,
          data: {
            'amount': tPaymentInput.amountInCents,
            'currency': tPaymentInput.currency,
            'customer': tNewCustomerId,
            'payment_method_types[]': 'card',
          },
          options: any(named: 'options'),
        ),
      ).called(1);
      verify(
        () => mockStripe.initPaymentSheet(
          paymentSheetParameters: any(named: 'paymentSheetParameters'),
        ),
      ).called(1);
      verify(() => mockStripe.presentPaymentSheet()).called(1);
    });

    test('should reuse existing customerId without calling createCustomer when user already has customerId', () async {
      // Arrange
      const tExistingCustomerId = 'cus_existing_999';
      const tClientSecret = 'pi_test_secret_existing';
      const tEphemeralKeySecret = 'ek_test_secret_existing';

      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({BackendEndpoints.customerIdField: tExistingCustomerId});

      when(
        () => mockDio.post(
          ApiConstants.createEphemeralKeyUrl,
          data: {'customer': tExistingCustomerId},
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.createEphemeralKeyUrl,
          ),
          data: {'secret': tEphemeralKeySecret},
          statusCode: 200,
        ),
      );

      when(
        () => mockDio.post(
          ApiConstants.createPaymentIntentUrl,
          data: {
            'amount': tPaymentInput.amountInCents,
            'currency': tPaymentInput.currency,
            'customer': tExistingCustomerId,
            'payment_method_types[]': 'card',
          },
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.createPaymentIntentUrl,
          ),
          data: {'client_secret': tClientSecret},
          statusCode: 200,
        ),
      );

      when(
        () => mockStripe.initPaymentSheet(
          paymentSheetParameters: any(named: 'paymentSheetParameters'),
        ),
      ).thenAnswer((_) async => null);

      when(() => mockStripe.presentPaymentSheet())
          .thenAnswer((_) async => null);

      // Act
      final result = await sut.makePayment(tPaymentInput);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());

      // Verify createCustomer was NOT called
      verifyNever(
        () => mockDio.post(
          ApiConstants.createCustomerUrl,
          options: any(named: 'options'),
        ),
      );
    });

    test(
      'should return NetworkFailure when createCustomer fails on dio call',
      () async {
        // Arrange
        when(
          () => mockDio.post(
            ApiConstants.createCustomerUrl,
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: ApiConstants.createCustomerUrl,
            ),
            message: 'Network request failed',
          ),
        );

        // Act
        final result = await sut.makePayment(tPaymentInput);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
      },
    );

    test(
      'should return NetworkFailure when createEphemeralKey fails on dio call',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.usersCollection)
            .doc(tUserId)
            .set({BackendEndpoints.customerIdField: 'cus_existing_999'});

        when(
          () => mockDio.post(
            ApiConstants.createEphemeralKeyUrl,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: ApiConstants.createEphemeralKeyUrl,
            ),
            message: 'Ephemeral key error',
          ),
        );

        // Act
        final result = await sut.makePayment(tPaymentInput);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
      },
    );

    test(
      'should return NetworkFailure when createPaymentIntent fails on dio call',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.usersCollection)
            .doc(tUserId)
            .set({BackendEndpoints.customerIdField: 'cus_existing_999'});

        when(
          () => mockDio.post(
            ApiConstants.createEphemeralKeyUrl,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: ApiConstants.createEphemeralKeyUrl,
            ),
            data: {'secret': 'ek_secret'},
            statusCode: 200,
          ),
        );

        when(
          () => mockDio.post(
            ApiConstants.createPaymentIntentUrl,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: ApiConstants.createPaymentIntentUrl,
            ),
            message: 'Payment intent failed',
          ),
        );

        // Act
        final result = await sut.makePayment(tPaymentInput);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
      },
    );

    test('should return NetworkFailure when stripe initPaymentSheet throws an exception', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({BackendEndpoints.customerIdField: 'cus_existing_999'});

      when(
        () => mockDio.post(
          ApiConstants.createEphemeralKeyUrl,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.createEphemeralKeyUrl,
          ),
          data: {'secret': 'ek_secret'},
          statusCode: 200,
        ),
      );

      when(
        () => mockDio.post(
          ApiConstants.createPaymentIntentUrl,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.createPaymentIntentUrl,
          ),
          data: {'client_secret': 'pi_secret'},
          statusCode: 200,
        ),
      );

      when(
        () => mockStripe.initPaymentSheet(
          paymentSheetParameters: any(named: 'paymentSheetParameters'),
        ),
      ).thenThrow(Exception('Stripe init failed'));

      // Act
      final result = await sut.makePayment(tPaymentInput);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
    });

    test('should return NetworkFailure when stripe presentPaymentSheet is cancelled or fails', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({BackendEndpoints.customerIdField: 'cus_existing_999'});

      when(
        () => mockDio.post(
          ApiConstants.createEphemeralKeyUrl,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.createEphemeralKeyUrl,
          ),
          data: {'secret': 'ek_secret'},
          statusCode: 200,
        ),
      );

      when(
        () => mockDio.post(
          ApiConstants.createPaymentIntentUrl,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.createPaymentIntentUrl,
          ),
          data: {'client_secret': 'pi_secret'},
          statusCode: 200,
        ),
      );

      when(
        () => mockStripe.initPaymentSheet(
          paymentSheetParameters: any(named: 'paymentSheetParameters'),
        ),
      ).thenAnswer((_) async => null);

      when(() => mockStripe.presentPaymentSheet())
          .thenThrow(Exception('Payment sheet cancelled by user'));

      // Act
      final result = await sut.makePayment(tPaymentInput);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
    });
  });

  group('Model and Entity Mappings', () {
    test('ShippingConfigModel fromJson should parse complete json with numeric types correctly', () {
      // Arrange
      final json = {'shipping_cost': 25.5, 'free_shipping_threshold': 150.0};

      // Act
      final model = ShippingConfigModel.fromJson(json);

      // Assert
      expect(model.shippingCost, 25.5);
      expect(model.freeShippingThreshold, 150.0);
    });

    test('ShippingConfigModel fromJson should support fallback defaults and numeric type coercion', () {
      // Arrange: int coerced to double, free_shipping_threshold null
      final jsonWithCoercion = {
        'shipping_cost': 30, // int
      };

      final emptyJson = <String, dynamic>{};

      // Act
      final model1 = ShippingConfigModel.fromJson(jsonWithCoercion);
      final model2 = ShippingConfigModel.fromJson(emptyJson);

      // Assert
      expect(model1.shippingCost, 30.0);
      expect(model1.shippingCost, isA<double>());
      expect(model1.freeShippingThreshold, isNull);

      expect(model2.shippingCost, 0.0);
      expect(model2.freeShippingThreshold, isNull);
    });

    test('ShippingConfigModel toJson should match exact firestore keys and conditionally omit null threshold', () {
      // Arrange
      final modelWithThreshold = ShippingConfigModel(
        shippingCost: 35.0,
        freeShippingThreshold: 200.0,
      );

      final modelWithoutThreshold = ShippingConfigModel(shippingCost: 35.0);

      // Act
      final json1 = modelWithThreshold.toJson();
      final json2 = modelWithoutThreshold.toJson();

      // Assert
      expect(json1['shipping_cost'], 35.0);
      expect(json1['free_shipping_threshold'], 200.0);

      expect(json2['shipping_cost'], 35.0);
      expect(json2.containsKey('free_shipping_threshold'), isFalse);
    });

    test('ShippingConfigModel toEntity and fromEntity should map all properties correctly', () {
      // Arrange
      const entity = ShippingConfigEntity(
        shippingCost: 40.0,
        freeShippingThreshold: 300.0,
      );

      // Act
      final model = ShippingConfigModel.fromEntity(entity);
      final mappedEntity = model.toEntity();

      // Assert
      expect(model.shippingCost, 40.0);
      expect(model.freeShippingThreshold, 300.0);
      expect(mappedEntity.shippingCost, entity.shippingCost);
      expect(mappedEntity.freeShippingThreshold, entity.freeShippingThreshold);
    });

    test('PaymentInputModel toEntity, fromEntity, copyWith, and amountInCents should work correctly', () {
      // Arrange
      final entity = PaymentInputEntity(
        amount: 125.50,
        currency: 'USD',
        customerId: 'cus_123',
      );

      // Act
      final model = PaymentInputModel.fromEntity(entity);
      final mappedEntity = model.toEntity();
      final copiedModel = model.copyWith(amount: 200.0);

      // Assert
      expect(model.amount, 125.50);
      expect(model.currency, 'USD');
      expect(model.customerId, 'cus_123');
      expect(model.amountInCents, '12550');

      expect(mappedEntity.amount, entity.amount);
      expect(mappedEntity.currency, entity.currency);
      expect(mappedEntity.customerId, entity.customerId);

      expect(copiedModel.amount, 200.0);
      expect(copiedModel.currency, 'USD');
      expect(copiedModel.amountInCents, '20000');
    });

    test('AddressModel fromJson, toJson, toEntity, and fromEntity should map accurately with conditional coordinates', () {
      // Arrange
      final jsonWithCoords = {
        'name': 'ياسر خالد',
        'email': 'yasser@example.com',
        'phone': '01234567890',
        'city': 'الجيزة',
        'street': 'شارع النيل',
        'building_number': '15',
        'floor_number': '2',
        'apartment_number': '4',
        'latitude': 29.9876,
        'longitude': 31.1234,
      };

      final jsonWithoutCoords = {
        'name': 'ياسر خالد',
        'email': 'yasser@example.com',
        'phone': '01234567890',
        'city': 'الجيزة',
        'street': 'شارع النيل',
        'building_number': '15',
        'floor_number': '2',
        'apartment_number': '4',
      };

      // Act
      final modelWithCoords = AddressModel.fromJson(jsonWithCoords);
      final modelWithoutCoords = AddressModel.fromJson(jsonWithoutCoords);
      final emptyModel = AddressModel.fromJson(<String, dynamic>{});

      final jsonOutput1 = modelWithCoords.toJson();
      final jsonOutput2 = modelWithoutCoords.toJson();

      final entity = modelWithCoords.toEntity();
      final fromEntityModel = AddressModel.fromEntity(entity);

      // Assert
      expect(modelWithCoords.name, 'ياسر خالد');
      expect(modelWithCoords.latitude, 29.9876);
      expect(modelWithCoords.longitude, 31.1234);

      expect(modelWithoutCoords.latitude, isNull);
      expect(modelWithoutCoords.longitude, isNull);

      expect(emptyModel.name, '');
      expect(emptyModel.city, '');
      expect(emptyModel.streetName, '');

      expect(jsonOutput1['street'], 'شارع النيل');
      expect(jsonOutput1['building_number'], '15');
      expect(jsonOutput1['latitude'], 29.9876);
      expect(jsonOutput2.containsKey('latitude'), isFalse);
      expect(jsonOutput2.containsKey('longitude'), isFalse);

      expect(fromEntityModel.name, entity.name);
      expect(fromEntityModel.email, entity.email);
      expect(fromEntityModel.phone, entity.phone);
      expect(fromEntityModel.city, entity.city);
      expect(fromEntityModel.streetName, entity.streetName);
      expect(fromEntityModel.buildingNumber, entity.buildingNumber);
      expect(fromEntityModel.floorNumber, entity.floorNumber);
      expect(fromEntityModel.apartmentNumber, entity.apartmentNumber);
      expect(fromEntityModel.latitude, entity.latitude);
      expect(fromEntityModel.longitude, entity.longitude);
    });
  });
}
