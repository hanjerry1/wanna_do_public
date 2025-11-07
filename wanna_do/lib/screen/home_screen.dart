import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/component/start_login.dart';
import 'package:wanna_do/component/unable_main_page.dart';
import 'package:wanna_do/controller/init_controller.dart';
import 'package:wanna_do/controller/user_controller.dart';
import 'package:wanna_do/manage/component/manage_main_page.dart';

// FutureBuilder에서 firestore의 문서 정보를 get할때, snapshot에 관한 궁금증.
// snapshot - FutureBuilder에 의해 제공되는 데이터로, 연결상태,에러 정보를 가지고 있는 AsyncSnapshot 객체를 말함.
// snapshot.data - AsyncSnapshot 내부에 있는 데이터로, DocumentSnapshot 객체를 말함.
// snapshot.data.data() - DocumentSnapshot 내부에 있는 데이터로, Firestore 문서의 Map<String, dynamic> 형태인 데이터를 말함.

class HomeScreen extends GetView<UserController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());
    Get.put(InitDeadlineOverChangeController());
    Get.put(InitCalculateMyPointController());
    return Obx(() {
      if (userController.isLoading.value) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Lottie.asset(
              'asset/lottie/short_loading_first_animation.json',
              height: 100,
            ),
          ),
        );
      }
      switch (userController.role.value) {
        case 'owner':
        case 'manager':
        case 'staff':
          return ManageMainPage();
        case 'unable':
          return UnableMainPage();
        case 'able':
          return MainPage();
        default:
          return StartLogin();
      }
    });
  }
}
