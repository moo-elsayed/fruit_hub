import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source_imp.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late CheckoutRemoteDataSourceImp sut;
  late MockDatabaseService mockDatabaseService;

  final tShippingConfigMap = {'shipping_cost': 50.0};

  final tShippingConfigEntity = const ShippingConfigEntity(shippingCost: 50.0);

  OrderEntity tOrderEntity = OrderEntity(
    uid: '123',
    products: [
      const CartItemEntity(
        fruitEntity: FruitEntity(
          code: '123',
          name: 'apple',
          imagePath: 'path',
          price: 10.0,
          description: 'description',
        ),
        quantity: 1,
      ),
    ],
    address: const AddressEntity(
      streetName: 'streetName',
      buildingNumber: 'buildingNumber',
      floorNumber: 'floorNumber',
      apartmentNumber: 'apartmentNumber',
      city: 'city',
      email: 'email',
      phone: 'phone',
      name: 'name',
    ),
    paymentOption: const PaymentOptionEntity(
      option: 'option',
      shippingCost: 50.0,
    ),
  );

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    sut = CheckoutRemoteDataSourceImp(mockDatabaseService);
  });

  group('CheckoutRemoteDataSourceImp', () {
    group("fetchShippingConfig", () {
      test(
        'should return ShippingConfigEntity when database call is successful',
        () async {
          // Arrange
          when(
            () => mockDatabaseService.getData(
              path: BackendEndpoints.fetchShippingCost,
              documentId: BackendEndpoints.shippingConfigId,
            ),
          ).thenAnswer((_) async => tShippingConfigMap);

          // Act
          final result = await sut.fetchShippingConfig();
          // Assert
          expect(result, isA<NetworkSuccess<ShippingConfigEntity>>());
          expect(
            (result as NetworkSuccess<ShippingConfigEntity>).data!.shippingCost,
            tShippingConfigEntity.shippingCost,
          );
          verify(
            () => mockDatabaseService.getData(
              path: BackendEndpoints.fetchShippingCost,
              documentId: BackendEndpoints.shippingConfigId,
            ),
          ).called(1);
        },
      );

      test('should return NetworkFailure when database call fails', () async {
        // Arrange
        when(
          () => mockDatabaseService.getData(
            path: BackendEndpoints.fetchShippingCost,
            documentId: BackendEndpoints.shippingConfigId,
          ),
        ).thenThrow(FirebaseException(message: 'Database Error', plugin: ''));

        // Act
        final result = await sut.fetchShippingConfig();

        // Assert
        expect(result, isA<NetworkFailure>());
        expect(getErrorMessage(result), 'Database Error');
        verify(
          () => mockDatabaseService.getData(
            path: BackendEndpoints.fetchShippingCost,
            documentId: BackendEndpoints.shippingConfigId,
          ),
        ).called(1);
      });
    });
    group("addOrder", () {
      test(
        'should return NetworkSuccess when database call is successful',
        () async {
          // Arrange
          when(
            () => mockDatabaseService.addData(
              path: BackendEndpoints.addOrder,
              data: any(named: 'data'),
            ),
          ).thenAnswer((_) async {});
          // Act
          final result = await sut.addOrder(tOrderEntity);
          // Assert
          expect(result, isA<NetworkSuccess>());
          verify(
            () => mockDatabaseService.addData(
              path: BackendEndpoints.addOrder,
              data: any(named: 'data'),
            ),
          ).called(1);
        },
      );

      test(
        'should return NetworkFailure when FirebaseException occurs',
        () async {
          // Arrange
          when(
            () => mockDatabaseService.addData(
              path: BackendEndpoints.addOrder,
              data: any(named: 'data'),
            ),
          ).thenThrow(
            FirebaseException(code: 'code', message: 'message', plugin: ''),
          );
          // Act
          final result = await sut.addOrder(tOrderEntity);
          // Assert
          expect(result, isA<NetworkFailure>());
          expect(getErrorMessage(result), 'message');
          verify(
            () => mockDatabaseService.addData(
              path: BackendEndpoints.addOrder,
              data: any(named: 'data'),
            ),
          ).called(1);
        },
      );

      test(
        'should return NetworkFailure with generic message when unknown Exception occurs',
        () async {
          // Arrange
          when(
            () => mockDatabaseService.addData(
              path: BackendEndpoints.addOrder,
              data: any(named: 'data'),
            ),
          ).thenThrow(Exception());
          // Act
          final result = await sut.addOrder(tOrderEntity);
          // Assert
          expect(result, isA<NetworkFailure>());
          expect(getErrorMessage(result), 'error_occurred_please_try_again');
          verify(
            () => mockDatabaseService.addData(
              path: BackendEndpoints.addOrder,
              data: any(named: 'data'),
            ),
          ).called(1);
        },
      );
    });
  });
}
