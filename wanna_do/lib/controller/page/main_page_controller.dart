import 'package:get/get.dart';

class MainPageController extends GetxController {
  var currentTabIndex = 0.obs;

  MainPageController({int initialTabIndex = 0}) {
    currentTabIndex.value = initialTabIndex;
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
