import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/profile_section_title.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('ProfileSectionTitle Widget Tests', () {
    testWidgets('should render provided title text properly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: ProfileSectionTitle(title: AppStrings.general),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text(AppStrings.general), findsOneWidget);
    });
  });
}
