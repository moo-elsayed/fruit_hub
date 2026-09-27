import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/cubits/app_language_cubit.dart';
import 'package:fruit_hub/core/cubits/app_theme_cubit.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/main_screen_header.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signout_cubit/sign_out_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/views/profile.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/profile_card.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/profile_section_title.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/sign_out_button.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_profile_card.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

class MockSignOutCubit extends MockCubit<SignOutState>
    implements SignOutCubit {}

class MockAppThemeCubit extends MockCubit<ThemeMode> implements AppThemeCubit {}

class MockAppLanguageCubit extends MockCubit<Locale>
    implements AppLanguageCubit {}

void main() {
  late MockUserInfoCubit mockUserInfoCubit;
  late MockSignOutCubit mockSignOutCubit;
  late MockAppThemeCubit mockAppThemeCubit;
  late MockAppLanguageCubit mockAppLanguageCubit;

  const dummyUser = UserEntity(
    uid: 'u123',
    name: 'محمد خالد',
    email: 'mohamed@example.com',
    phone: '01122334455',
    image: '',
    isVerified: true,
  );

  setUp(() {
    mockUserInfoCubit = MockUserInfoCubit();
    mockSignOutCubit = MockSignOutCubit();
    mockAppThemeCubit = MockAppThemeCubit();
    mockAppLanguageCubit = MockAppLanguageCubit();

    when(() => mockUserInfoCubit.state).thenReturn(UserInfoSuccess(dummyUser));
    when(() => mockUserInfoCubit.currentUser).thenReturn(dummyUser);

    when(() => mockSignOutCubit.state).thenReturn(SignOutInitial());
    when(() => mockAppThemeCubit.state).thenReturn(ThemeMode.light);
    when(() => mockAppLanguageCubit.state).thenReturn(const Locale('ar'));
  });

  Widget buildTestWidget() => MultiBlocProvider(
    providers: [
      BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
      BlocProvider<SignOutCubit>.value(value: mockSignOutCubit),
      BlocProvider<AppThemeCubit>.value(value: mockAppThemeCubit),
      BlocProvider<AppLanguageCubit>.value(value: mockAppLanguageCubit),
    ],
    child: const Profile(),
  );

  group('Profile View Widget Tests', () {
    testWidgets(
      'should render all main profile sections and components successfully',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Assert
        expect(find.byType(MainScreenHeader), findsOneWidget);
        expect(find.text(AppStrings.myAccount), findsOneWidget);

        expect(find.byType(UserProfileCard), findsOneWidget);
        expect(find.text('محمد خالد'), findsOneWidget);
        expect(find.text('mohamed@example.com'), findsOneWidget);

        expect(find.byType(ProfileSectionTitle), findsOneWidget);
        expect(find.text(AppStrings.general), findsOneWidget);

        expect(find.byType(ProfileCard), findsOneWidget);
        expect(find.text(AppStrings.myOrders), findsOneWidget);
        expect(find.text(AppStrings.language), findsOneWidget);
        expect(find.text(AppStrings.theme), findsOneWidget);

        expect(find.byType(SignOutButton), findsOneWidget);
        expect(find.text(AppStrings.signOut), findsOneWidget);
      },
    );
  });
}
