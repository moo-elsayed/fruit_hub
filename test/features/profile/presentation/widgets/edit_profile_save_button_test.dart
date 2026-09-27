import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/profile/presentation/managers/edit_profile_cubit/edit_profile_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/edit_profile_save_button.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockEditProfileCubit extends MockCubit<EditProfileState>
    implements EditProfileCubit {}

void main() {
  late MockEditProfileCubit mockEditProfileCubit;

  setUp(() {
    mockEditProfileCubit = MockEditProfileCubit();
  });

  Widget buildTestWidget({required VoidCallback onPressed}) =>
      BlocProvider<EditProfileCubit>.value(
        value: mockEditProfileCubit,
        child: EditProfileSaveButton(onPressed: onPressed),
      );

  group('EditProfileSaveButton Widget Tests', () {
    testWidgets(
      'should render save changes text and trigger onPressed when tapped',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockEditProfileCubit.state)
            .thenReturn(const EditProfileInitial());
        var wasPressed = false;

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: buildTestWidget(onPressed: () => wasPressed = true),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.text(AppStrings.saveChanges), findsOneWidget);
        expect(find.byType(CustomMaterialButton), findsOneWidget);

        await tester.tap(find.byType(CustomMaterialButton));
        await tester.pump();

        expect(wasPressed, isTrue);
      },
    );

    testWidgets(
      'should show loading indicator and disable tap when state is EditProfileLoading',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockEditProfileCubit.state)
            .thenReturn(const EditProfileLoading());
        var wasPressed = false;

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: buildTestWidget(onPressed: () => wasPressed = true),
          ),
        );
        await tester.pump();

        // Assert
        final button = tester.widget<CustomMaterialButton>(
          find.byType(CustomMaterialButton),
        );
        expect(button.isLoading, isTrue);

        await tester.tap(find.byType(CustomMaterialButton));
        await tester.pump();

        expect(wasPressed, isFalse);
      },
    );
  });
}
