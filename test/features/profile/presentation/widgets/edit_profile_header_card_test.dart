import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/edit_profile_header_card.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/email_verification_status_badge.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_avatar_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

void main() {
  late MockUserInfoCubit mockUserInfoCubit;
  late TextEditingController imageController;

  const dummyUser = UserEntity(
    uid: '123',
    name: 'أحمد علي',
    email: 'ahmed@test.com',
    phone: '01012345678',
    image: 'https://example.com/photo.jpg',
    isVerified: true,
  );

  setUp(() {
    AppToast.isEnabled = false;
    mockUserInfoCubit = MockUserInfoCubit();
    imageController = TextEditingController();

    when(() => mockUserInfoCubit.state).thenReturn(UserInfoSuccess(dummyUser));
    when(() => mockUserInfoCubit.currentUser).thenReturn(dummyUser);
  });

  tearDown(() {
    AppToast.isEnabled = true;
    imageController.dispose();
  });

  Widget buildTestWidget({Map<String, WidgetBuilder>? routes}) =>
      BlocProvider<UserInfoCubit>.value(
        value: mockUserInfoCubit,
        child: EditProfileHeaderCard(imageController: imageController),
      );

  group('EditProfileHeaderCard Widget Tests', () {
    testWidgets(
      'should render UserAvatarWidget, camera icon, and EmailVerificationStatusBadge',
      (WidgetTester tester) async {
        // Arrange
        imageController.text = 'https://example.com/photo.jpg';

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Assert
        expect(find.byType(UserAvatarWidget), findsOneWidget);
        expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
        expect(find.byType(EmailVerificationStatusBadge), findsOneWidget);
        expect(find.text(AppStrings.verifiedAccount), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to fullScreenImageGalleryView when avatar with image is tapped',
      (WidgetTester tester) async {
        // Arrange
        imageController.text = 'https://example.com/photo.jpg';
        var navigatedToGallery = false;

        await tester.pumpWidget(
          createWidgetForTesting(
            child: buildTestWidget(),
            routes: {
              Routes.fullScreenImageGalleryView: (context) {
                navigatedToGallery = true;
                return const Scaffold(body: Text('Gallery View'));
              },
            },
          ),
        );
        await tester.pump();

        // Act - Tap top-left area of avatar to avoid bottom-end camera badge
        final avatarTopLeft = tester.getTopLeft(find.byType(UserAvatarWidget));
        await tester.tapAt(avatarTopLeft + const Offset(15, 15));
        await tester.pumpAndSettle();

        // Assert
        expect(navigatedToGallery, isTrue);
      },
    );

    testWidgets('should open image picker sheet when camera badge is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      imageController.text = 'https://example.com/photo.jpg';

      await tester.pumpWidget(createWidgetForTesting(child: buildTestWidget()));
      await tester.pump();

      // Act - Tap on camera badge icon
      await tester.tap(find.byIcon(Icons.camera_alt_rounded));
      await tester.pumpAndSettle();

      // Assert - bottom sheet options are displayed
      expect(find.text(AppStrings.chooseImageSource), findsOneWidget);
      expect(find.text(AppStrings.camera), findsOneWidget);
      expect(find.text(AppStrings.gallery), findsOneWidget);
      expect(find.text(AppStrings.removePhoto), findsOneWidget);
    });

    testWidgets(
      'should open image picker sheet when avatar without image is tapped',
      (WidgetTester tester) async {
        // Arrange
        imageController.text = '';

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Act - Tap avatar top-left area
        final avatarTopLeft = tester.getTopLeft(find.byType(UserAvatarWidget));
        await tester.tapAt(avatarTopLeft + const Offset(15, 15));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(AppStrings.chooseImageSource), findsOneWidget);
        expect(find.text(AppStrings.camera), findsOneWidget);
        expect(find.text(AppStrings.gallery), findsOneWidget);
      },
    );
  });
}
