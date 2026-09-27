import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/profile/domain/entities/update_profile_input_entity.dart';
import 'package:fruit_hub/features/profile/presentation/managers/edit_profile_cubit/edit_profile_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/edit_profile_save_button.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/edit_profile_view_body.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_avatar_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockEditProfileCubit extends MockCubit<EditProfileState>
    implements EditProfileCubit {}

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

class FakeUpdateProfileInputEntity extends Fake
    implements UpdateProfileInputEntity {}

void main() {
  late MockEditProfileCubit mockEditProfileCubit;
  late MockUserInfoCubit mockUserInfoCubit;
  late StreamController<EditProfileState> editProfileStateController;

  const dummyUser = UserEntity(
    uid: 'u_101',
    name: 'محمود أحمد',
    email: 'mahmoud@test.com',
    phone: '01012345678',
    image: 'https://example.com/photo.jpg',
    isVerified: true,
  );

  setUpAll(() {
    registerFallbackValue(FakeUpdateProfileInputEntity());
  });

  setUp(() {
    AppToast.isEnabled = false;
    mockEditProfileCubit = MockEditProfileCubit();
    mockUserInfoCubit = MockUserInfoCubit();
    editProfileStateController = StreamController<EditProfileState>.broadcast();

    when(() => mockEditProfileCubit.state)
        .thenReturn(const EditProfileInitial());
    when(() => mockEditProfileCubit.currentUser).thenReturn(dummyUser);
    whenListen(
      mockEditProfileCubit,
      editProfileStateController.stream,
      initialState: const EditProfileInitial(),
    );

    when(() => mockUserInfoCubit.state).thenReturn(UserInfoSuccess(dummyUser));
    when(() => mockUserInfoCubit.currentUser).thenReturn(dummyUser);
  });

  tearDown(() {
    AppToast.isEnabled = true;
    editProfileStateController.close();
  });

  Widget buildTestWidget() => MultiBlocProvider(
    providers: [
      BlocProvider<EditProfileCubit>.value(value: mockEditProfileCubit),
      BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
    ],
    child: const EditProfileViewBody(),
  );

  group('EditProfileViewBody Widget Tests', () {
    testWidgets(
      'should populate form fields with current user information on init',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Assert
        expect(find.text('محمود أحمد'), findsOneWidget);
        expect(find.text('mahmoud@test.com'), findsOneWidget);
        expect(find.text('01012345678'), findsOneWidget);
        expect(find.text(AppStrings.basicInfo), findsOneWidget);
        expect(find.text(AppStrings.accountSecurity), findsOneWidget);
        expect(find.byType(EditProfileSaveButton), findsOneWidget);
      },
    );

    testWidgets(
      'should not call updateProfile when save is pressed without making changes',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Act - Tap save button directly without editing fields
        await tester.ensureVisible(find.byType(EditProfileSaveButton));
        await tester.tap(find.byType(EditProfileSaveButton));
        await tester.pump();

        // Assert
        verifyNever(
          () => mockEditProfileCubit.updateProfile(
            any(that: isA<UpdateProfileInputEntity>()),
          ),
        );
      },
    );

    testWidgets(
      'should show validation error and not call updateProfile when name is empty',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Act - Clear name field
        final nameField = find.widgetWithText(
          TextFormFieldHelper,
          AppStrings.fullName,
        );
        await tester.enterText(nameField, '');
        await tester.pump();

        await tester.ensureVisible(find.byType(EditProfileSaveButton));
        await tester.tap(find.byType(EditProfileSaveButton));
        await tester.pump();

        // Assert
        expect(find.text(AppStrings.nameCannotBeEmpty), findsOneWidget);
        verifyNever(
          () => mockEditProfileCubit.updateProfile(
            any(that: isA<UpdateProfileInputEntity>()),
          ),
        );
      },
    );

    testWidgets(
      'should call updateProfile with updated information when values change and valid',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockEditProfileCubit.updateProfile(
            any(that: isA<UpdateProfileInputEntity>()),
          ),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Act - Modify name and phone
        final nameField = find.widgetWithText(
          TextFormFieldHelper,
          AppStrings.fullName,
        );
        final phoneField = find.widgetWithText(
          TextFormFieldHelper,
          AppStrings.phoneNumber,
        );

        await tester.enterText(nameField, 'محمود علي');
        await tester.enterText(phoneField, '01199887766');
        await tester.pump();

        await tester.ensureVisible(find.byType(EditProfileSaveButton));
        await tester.tap(find.byType(EditProfileSaveButton));
        await tester.pump();

        // Assert
        verify(
          () => mockEditProfileCubit.updateProfile(
            const UpdateProfileInputEntity(
              uid: 'u_101',
              name: 'محمود علي',
              phone: '01199887766',
              image: 'https://example.com/photo.jpg',
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should update image controller when EditProfileSuccess state is emitted',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        const updatedUser = UserEntity(
          uid: 'u_101',
          name: 'محمود أحمد',
          email: 'mahmoud@test.com',
          phone: '01012345678',
          image: 'https://example.com/new_photo.jpg',
          isVerified: true,
        );

        // Act
        editProfileStateController.add(const EditProfileSuccess(updatedUser));
        await tester.pump();
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is UserAvatarWidget &&
                widget.imagePath == 'https://example.com/new_photo.jpg',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
