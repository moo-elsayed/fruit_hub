import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/address_body.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/save_address.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/select_location_card.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockCheckoutCubit extends MockCubit<CheckoutState>
    implements CheckoutCubit {}

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

void main() {
  late MockCheckoutCubit mockCheckoutCubit;
  late MockUserInfoCubit mockUserInfoCubit;
  late AddressArgs addressArgs;

  const tUser = UserEntity(
    uid: 'u_1',
    name: 'محمود السيد',
    email: 'mahmoud@test.com',
    phone: '01099998888',
  );

  const tCachedAddress = AddressEntity(
    name: 'علي كمال',
    email: 'ali@test.com',
    phone: '01234567890',
    city: 'الإسكندرية',
    streetName: 'طريق الجيش',
    buildingNumber: '10',
    floorNumber: '2',
    apartmentNumber: '5',
    latitude: 31.2,
    longitude: 29.9,
  );

  setUp(() {
    mockCheckoutCubit = MockCheckoutCubit();
    mockUserInfoCubit = MockUserInfoCubit();
    addressArgs = AddressArgs();

    when(() => mockCheckoutCubit.state).thenReturn(CheckoutInitial());
    when(() => mockCheckoutCubit.saveAddress).thenReturn(true);
    when(() => mockCheckoutCubit.setSaveAddress(any())).thenReturn(null);
    when(() => mockCheckoutCubit.address).thenReturn(null);

    when(() => mockUserInfoCubit.state).thenReturn(UserInfoInitial());
    when(() => mockUserInfoCubit.currentUser).thenReturn(tUser);
  });

  tearDown(() {
    addressArgs.dispose();
  });

  Widget buildTestWidget() => createWidgetForTesting(
    child: MultiBlocProvider(
      providers: [
        BlocProvider<CheckoutCubit>.value(value: mockCheckoutCubit),
        BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
      ],
      child: AddressBody(addressArgs: addressArgs),
    ),
  );

  group('AddressBody Widget Tests', () {
    testWidgets(
      'should pre-fill user info fields from UserInfoCubit when address is not cached',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(addressArgs.nameController.text, equals('محمود السيد'));
        expect(addressArgs.emailController.text, equals('mahmoud@test.com'));
        expect(addressArgs.phoneController.text, equals('01099998888'));
        expect(addressArgs.cityController.text, isEmpty);
        expect(find.byType(SelectLocationCard), findsOneWidget);
        expect(find.byType(SaveAddress), findsOneWidget);
        expect(find.byType(TextFormFieldHelper), findsNWidgets(8));
      },
    );

    testWidgets(
      'should pre-fill all fields from CheckoutCubit when stored address exists',
      (tester) async {
        // Arrange
        when(() => mockCheckoutCubit.address).thenReturn(tCachedAddress);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(addressArgs.nameController.text, equals('علي كمال'));
        expect(addressArgs.emailController.text, equals('ali@test.com'));
        expect(addressArgs.phoneController.text, equals('01234567890'));
        expect(addressArgs.cityController.text, equals('الإسكندرية'));
        expect(addressArgs.streetNameController.text, equals('طريق الجيش'));
        expect(addressArgs.buildingController.text, equals('10'));
        expect(addressArgs.floorController.text, equals('2'));
        expect(addressArgs.apartmentController.text, equals('5'));
        expect(addressArgs.latitude, equals(31.2));
        expect(addressArgs.longitude, equals(29.9));
      },
    );

    testWidgets(
      'should invoke setSaveAddress on CheckoutCubit when SaveAddress is toggled',
      (tester) async {
        // Arrange
        tester.view.physicalSize = const Size(375 * 3, 1200 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act - Scroll to and tap on SaveAddress
        await tester.ensureVisible(find.byType(SaveAddress));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(SaveAddress));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockCheckoutCubit.setSaveAddress(false)).called(1);
      },
    );
  });
}
