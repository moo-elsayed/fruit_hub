import 'package:flutter/foundation.dart';

class MainTabNotifier {
  MainTabNotifier._();

  static final ValueNotifier<int> currentTab = ValueNotifier<int>(0);

  static void switchToTab(int index) {
    currentTab.value = index;
  }
}
