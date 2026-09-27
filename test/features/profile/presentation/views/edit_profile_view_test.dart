import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/managers/edit_profile_cubit/edit_profile_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/views/edit_profile_view.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/edit_profile_view_body.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockEditProfileCubit extends MockCubit<EditProfileState>
    implements EditProfileCubit {}

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

void main() {
  late MockEditProfileCubit mockEditProfileCubit;
  late MockUserInfoCubit mockUserInfoCubit;
  late StreamController<EditProfileState> editProfileStateController;

  const dummyUser = UserEntity(
    uid: 'u_101',
    name: 'محمود أحمد',
    email: 'mahmoud@test.com',
    phone: '01012345678',
    image: '',
    isVerified: true,
  );

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
    child: const EditProfileView(),
  );

  group('EditProfileView Widget Tests', () {
    testWidgets(
      'should render CustomAppBar with edit profile title and EditProfileViewBody',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.text(AppStrings.editProfile), findsOneWidget);
        expect(find.byType(EditProfileViewBody), findsOneWidget);
      },
    );

    testWidgets(
      'should unfocus input fields when EditProfileSuccess state is emitted',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        final nameField = find.widgetWithText(
          TextFormFieldHelper,
          AppStrings.fullName,
        );
        await tester.tap(nameField);
        await tester.pump();

        final editableText = tester.widget<EditableText>(
          find.byType(EditableText).first,
        );
        expect(editableText.focusNode.hasFocus, isTrue);

        const updatedUser = UserEntity(
          uid: 'u_101',
          name: 'محمود أحمد الجديد',
          email: 'mahmoud@test.com',
          phone: '01012345678',
          image: '',
          isVerified: true,
        );

        // Act
        editProfileStateController.add(const EditProfileSuccess(updatedUser));
        await tester.pump();
        await tester.pumpAndSettle();

        // Assert
        expect(editableText.focusNode.hasFocus, isFalse);
      },
    );

    testWidgets(
      'should not unfocus input fields when EditProfileFailure state is emitted',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        final nameField = find.widgetWithText(
          TextFormFieldHelper,
          AppStrings.fullName,
        );
        await tester.tap(nameField);
        await tester.pump();

        final editableText = tester.widget<EditableText>(
          find.byType(EditableText).first,
        );
        expect(editableText.focusNode.hasFocus, isTrue);

        // Act
        editProfileStateController.add(
          const EditProfileFailure('حدث خطأ أثناء تعديل البيانات'),
        );
        await tester.pump();
        await tester.pumpAndSettle();

        // Assert
        expect(editableText.focusNode.hasFocus, isTrue);
      },
    );
  });
}
