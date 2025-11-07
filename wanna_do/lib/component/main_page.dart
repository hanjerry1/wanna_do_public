import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/main_checkup.dart';
import 'package:wanna_do/container/main_home.dart';
import 'package:wanna_do/container/main_my.dart';
import 'package:wanna_do/container/main_space.dart';
import 'package:wanna_do/controller/page/main_page_controller.dart';
import 'package:wanna_do/model/statistic/month_rank_model.dart';
import 'package:wanna_do/model/user/direct_message_model.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainPageController mainPageController = Get.put(MainPageController());
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final String? authName =
      FirebaseAuth.instance.currentUser!.displayName ?? '회원';
  String rank1Uid = '';
  String rank2Uid = '';
  String rank3Uid = '';
  String docId = '';
  String appUrl = '';

  final List<Map<String, dynamic>> tabs = [
    {
      'icon': 'asset/svg/home_icon.svg',
      'activeIcon': 'asset/svg/home_icon_fill.svg',
      'label': '홈',
    },
    {
      'icon': 'asset/svg/checkup_icon.svg',
      'activeIcon': 'asset/svg/checkup_icon_fill.svg',
      'label': '체크업',
    },
    {
      'icon': 'asset/svg/space_icon.svg',
      'activeIcon': 'asset/svg/space_icon_fill.svg',
      'label': '스페이스',
    },
    {
      'icon': 'asset/svg/my_icon.svg',
      'activeIcon': 'asset/svg/my_icon_fill.svg',
      'label': 'MY',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadInitMonthRankData();
    getUserDirectMessage();
  }

  Future<void> loadInitMonthRankData() async {
    try {
      QuerySnapshot mainSnapshot = await FirebaseFirestore.instance
          .collection('log')
          .doc('monthRankLog')
          .collection('monthRankLog')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (mainSnapshot.docs.isEmpty) {
        return;
      }
      QuerySnapshot subSnapshot = await FirebaseFirestore.instance
          .collection('log')
          .doc('monthRankLog')
          .collection('monthRankLog')
          .doc(mainSnapshot.docs.first.id)
          .collection('monthRank')
          .where('monthScore', isNotEqualTo: 0)
          .orderBy('monthScore', descending: true)
          .limit(3)
          .get();

      List<MonthRankModel> monthRankDataList = subSnapshot.docs
          .map((doc) => MonthRankModel.fromJson(
                doc.data() as Map<String, dynamic>,
              ))
          .toList();

      if (monthRankDataList.isNotEmpty) {
        setState(() {
          rank1Uid = monthRankDataList[0].uid;
          rank2Uid =
              monthRankDataList.length > 1 ? monthRankDataList[1].uid : '';
          rank3Uid =
              monthRankDataList.length > 2 ? monthRankDataList[2].uid : '';
        });
      }
    } catch (e) {}
  }

  Future<void> getUserDirectMessage() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(authUid)
        .collection('directMessage')
        .where('status', isEqualTo: 'none')
        .orderBy('createdAt', descending: false)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      docId = querySnapshot.docs.first.id;

      DirectMessageModel data = DirectMessageModel.fromJson(
        querySnapshot.docs.first.data() as Map<String, dynamic>,
      );
      Get.dialog(
        DialogTwoButton(
          title: '🔥 ${data.title}',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요 $authName님!',
                style: font15w700,
              ),
              SizedBox(height: 5),
              Text(
                data.content,
                style: font15w700,
              ),
            ],
          ),
          leftText: '취소',
          rightText: '확인하고 닫기',
          onLeftButtonPressed: () {
            Get.back();
          },
          onRightButtonPressed: () async {
            await FirebaseFirestore.instance
                .collection('user')
                .doc(authUid)
                .collection('directMessage')
                .doc(docId)
                .update({
              'status': 'checked',
            });
            Get.back();
          },
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<bool> checkForUpdate() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: Duration(seconds: 10),
          minimumFetchInterval: Duration(minutes: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
      final String requiredVersion = remoteConfig.getString('latest_version');
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      if (Platform.isAndroid) {
        appUrl = remoteConfig.getString('android_app_url');
      } else if (Platform.isIOS) {
        appUrl = remoteConfig.getString('ios_app_url');
      }

      return currentVersion.compareTo(requiredVersion) < 0;
    } catch (exception) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkForUpdate(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              child: Center(
                child: Lottie.asset(
                  'asset/lottie/short_loading_first_animation.json',
                  height: 100,
                ),
              ),
            ),
          );
        }
        if (snapshot.data!) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              color: Colors.black.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '워너두 업데이트',
                            style: font18w800,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '워너두가 새로 업그레이드 되었어요. 지금 최신 버전으로 업데이트 해주세요!',
                            style: font15w400.copyWith(
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(appUrl);
                              try {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } catch (e) {
                                ErrorGetxToast.show(context, '네트워크를 확인해주세요',
                                    '오류가 계속되면 MY탭에서 문의해주세요');
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '업데이트 하기',
                                  style: font16w800.copyWith(
                                    color: mainColor,
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(
          body: Obx(
            () => IndexedStack(
              index: mainPageController.currentTabIndex.value,
              children: [
                MainHome(),
                MainCheckup(),
                MainSpace(
                  rank1Uid: rank1Uid,
                  rank2Uid: rank2Uid,
                  rank3Uid: rank3Uid,
                ),
                MainMy(
                  rank1Uid: rank1Uid,
                  rank2Uid: rank2Uid,
                  rank3Uid: rank3Uid,
                ),
              ],
            ),
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Color(0xF5FFFFFF),
            ),
            child: Obx(
              () => BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: true,
                elevation: 10,
                currentIndex: mainPageController.currentTabIndex.value,
                onTap: (index) => mainPageController.changeTab(index),
                selectedItemColor: Colors.black,
                selectedLabelStyle: font13w700,
                unselectedItemColor: Colors.black.withOpacity(0.5),
                unselectedLabelStyle: font13w400,
                items: tabs.map((tab) {
                  return BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: SvgPicture.asset(
                        tab['icon'] as String,
                        height: 25,
                      ),
                    ),
                    activeIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: SvgPicture.asset(
                        tab['activeIcon'] as String,
                        height: 25,
                      ),
                    ),
                    label: tab['label'] as String,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
