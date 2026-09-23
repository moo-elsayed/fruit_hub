import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/main/presentation/managers/main_tab_notifier.dart';

void main() {
  tearDown(() {
    MainTabNotifier.switchToTab(0);
  });

  group('MainTabNotifier', () {
    test('should have initial tab value of 0', () {
      // Assert
      expect(MainTabNotifier.currentTab.value, 0);
    });

    test('should update currentTab value when switchToTab is called', () {
      // Arrange & Act
      MainTabNotifier.switchToTab(2);

      // Assert
      expect(MainTabNotifier.currentTab.value, 2);
    });

    test('should notify listeners when switchToTab updates currentTab', () {
      // Arrange
      int notifiedValue = 0;
      void listener() {
        notifiedValue = MainTabNotifier.currentTab.value;
      }

      MainTabNotifier.currentTab.addListener(listener);

      // Act
      MainTabNotifier.switchToTab(3);

      // Assert
      expect(notifiedValue, 3);

      // Cleanup
      MainTabNotifier.currentTab.removeListener(listener);
    });
  });
}
