import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_profile_card.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

void main() {
  late MockUserInfoCubit mockUserInfoCubit;

  const dummyUser = UserEntity(
    uid: 'u123',
    name: 'أحمد علي',
    email: 'ahmed@example.com',
    phone: '01012345678',
    image: '',
    isVerified: true,
  );

  setUp(() {
    mockUserInfoCubit = MockUserInfoCubit();
    when(() => mockUserInfoCubit.state).thenReturn(UserInfoInitial());
    when(() => mockUserInfoCubit.currentUser).thenReturn(dummyUser);
  });

  Widget buildTestWidget() => BlocProvider<UserInfoCubit>.value(
    value: mockUserInfoCubit,
    child: const UserProfileCard(),
  );

  group('UserProfileCard Widget Tests', () {
    testWidgets(
      'should render user name and email when user is present in cubit',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockUserInfoCubit.state)
            .thenReturn(UserInfoSuccess(dummyUser));

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Assert
        expect(find.text('أحمد علي'), findsOneWidget);
        expect(find.text('ahmed@example.com'), findsOneWidget);
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'should render welcome string when user name is empty or missing',
      (WidgetTester tester) async {
        // Arrange
        const emptyNameUser = UserEntity(
          uid: 'u123',
          name: '',
          email: 'test@example.com',
          phone: '',
          image: '',
        );
        when(() => mockUserInfoCubit.state)
            .thenReturn(UserInfoSuccess(emptyNameUser));
        when(() => mockUserInfoCubit.currentUser).thenReturn(emptyNameUser);

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Assert
        expect(find.text(AppStrings.welcome), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);
      },
    );

    testWidgets('should navigate to editProfileView when card is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      var navigatedToEditProfile = false;
      when(() => mockUserInfoCubit.state)
          .thenReturn(UserInfoSuccess(dummyUser));

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: buildTestWidget(),
          routes: {
            Routes.editProfileView: (context) {
              navigatedToEditProfile = true;
              return const Scaffold(body: Text('Edit Profile Screen'));
            },
          },
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(UserProfileCard));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedToEditProfile, isTrue);
    });
  });
}
