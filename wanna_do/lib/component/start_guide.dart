import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/controller/user_controller.dart';
import 'package:wanna_do/model/user/agreement_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';

class StartGuide extends StatefulWidget {
  final UserController userController = Get.put(UserController());
  StartGuide({super.key});

  @override
  _StartGuideState createState() => _StartGuideState();
}

class _StartGuideState extends State<StartGuide> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final PageController pageController = PageController();
  int currentPage = 0;
  int progress = 1;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
        progress = currentPage + 1;
      });
    });
    getFirebaseMessagingTopic();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> getFirebaseMessagingTopic() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(authUid)
        .collection('agreement')
        .doc(authUid)
        .get();

    AgreementModel data = AgreementModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    if (data.pushNotice) {
      await FirebaseMessaging.instance.subscribeToTopic('pushNotice');
    }
    if (data.pushAd) {
      await FirebaseMessaging.instance.subscribeToTopic('pushAd');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentPage > 0) {
          pageController.jumpToPage(currentPage - 1);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 2),
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 4,
                    color: greyColor,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * (progress / 3),
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [subColor, mainColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Scaffold(
                      backgroundColor: Colors.white,
                      appBar: SubAppBar(),
                      body: Column(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 100),
                                Text(
                                  'Wanna Do!',
                                  style: fontAppLogo.copyWith(
                                    fontSize: 30,
                                    color: mainColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Lottie.asset(
                                  'asset/lottie/wanna_do_checker_animation.json',
                                  width: 300,
                                ),
                                SizedBox(height: 50),
                                Text(
                                  '나의 목표달성 검사',
                                  style: font25w800,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  '워너두는 돈을 걸고 나와의 약속을 \n지키도록 도와주는 선생님이에요',
                                  style: font20w400.copyWith(height: 1.5),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: BigButtonFirst(
                              buttonText: '다음',
                              onPressed: () {
                                pageController.jumpToPage(currentPage + 1);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Scaffold(
                      backgroundColor: Colors.white,
                      appBar: SubAppBar(
                        onBackButtonPressed: () {
                          pageController.jumpToPage(currentPage - 1);
                        },
                      ),
                      body: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    '원하는 금액을 걸고\n나와 약속을 지킬 목표를 설정해요',
                                    style: font23w800.copyWith(height: 1.5),
                                  ),
                                  SizedBox(height: 30),
                                  Center(
                                    child: Lottie.asset(
                                      'asset/lottie/wanna_do_checker_animation.json',
                                      width: 300,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'asset/img/check_mini2.png',
                                        width: 35,
                                        color: mainColor,
                                      ),
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '목표달성에 성공했다고 판정되면',
                                            style: font15w800,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '건 돈을 100% 돌려받을 수 있어요!',
                                            style: font15w400,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'asset/img/check_mini2.png',
                                        width: 35,
                                        color: mainColor,
                                      ),
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '실패해도 너무 슬퍼하지 마세요',
                                            style: font15w800,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '건 돈의 일부를 다시 환급해 드려요!',
                                            style: font15w400,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'asset/img/check_mini2.png',
                                        width: 35,
                                        color: mainColor,
                                      ),
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '목표달성을 위해 워너두가 함께!',
                                            style: font15w800,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '혼자서 이겨내기 힘들다면 워너두와 함께해요!',
                                            style: font15w400,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: BigButtonFirst(
                              buttonText: '재밌을 것 같은데요?',
                              onPressed: () {
                                pageController.jumpToPage(currentPage + 1);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Scaffold(
                      backgroundColor: Colors.white,
                      appBar: SubAppBar(
                        onBackButtonPressed: () {
                          pageController.jumpToPage(currentPage - 1);
                        },
                      ),
                      body: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    '인증이 가능한 목표라면\n무엇이든 참여할 수 있어요',
                                    style: font23w800.copyWith(height: 1.5),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    '+ 문제집, 시험점수, 다이어트, 루틴 외 기타',
                                    style: font15w400,
                                  ),
                                  SizedBox(height: 30),
                                  Image.asset(
                                    'asset/img/iphone_category.png',
                                    height: 450,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: BigButtonFirst(
                              buttonText: '워너두 시작해보기!',
                              onPressed: () {
                                Get.offAll(() => MainPage());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
