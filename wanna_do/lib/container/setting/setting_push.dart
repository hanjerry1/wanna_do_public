import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/user/agreement_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class SettingPush extends StatefulWidget {
  const SettingPush({super.key});

  @override
  State<SettingPush> createState() => _SettingPushState();
}

class _SettingPushState extends State<SettingPush> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  bool pushNotice = false;
  bool pushAd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: '알림',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('user')
              .doc(authUid)
              .collection('agreement')
              .doc(authUid)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Lottie.asset(
                  'asset/lottie/short_loading_first_animation.json',
                  height: 100,
                ),
              );
            }

            AgreementModel data = AgreementModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>,
            );

            pushNotice = data.pushNotice;
            pushAd = data.pushAd;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (!pushNotice) {
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(authUid)
                          .collection('agreement')
                          .doc(authUid)
                          .update({
                        'pushNotice': !pushNotice,
                      });
                      await FirebaseMessaging.instance
                          .subscribeToTopic("pushNotice");
                      setState(() {});
                    } else {
                      Get.dialog(
                        DialogTwoButton(
                          title: '서비스 알림',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '서비스 알림을 해제하면 챌린지 완료, 적립금 지급을 포함한 중요한 공지를 받을 수 없어요. 그래도 해제할까요?',
                                style: font15w700.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                          leftText: '해제하기',
                          rightText: '유지하기',
                          onLeftButtonPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(authUid)
                                .collection('agreement')
                                .doc(authUid)
                                .update({
                              'pushNotice': !pushNotice,
                            });
                            await FirebaseMessaging.instance
                                .unsubscribeFromTopic("pushNotice");
                            setState(() {});
                            Get.back();
                          },
                          onRightButtonPressed: () {
                            Get.back();
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '서비스 알림',
                                style: font20w700,
                              ),
                              Text(
                                '챌린지, 적립금 등의 중요 공지 알림',
                                style: font14w400,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          activeColor: mainColor,
                          inactiveThumbColor: charcoalColor,
                          inactiveTrackColor: mainColorLight,
                          value: pushNotice,
                          onChanged: (bool value) {
                            setState(() {
                              pushNotice = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    if (!pushAd) {
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(authUid)
                          .collection('agreement')
                          .doc(authUid)
                          .update({
                        'pushAd': !pushAd,
                      });
                      await FirebaseMessaging.instance
                          .subscribeToTopic("pushAd");
                      setState(() {});

                      InfoGetxToast.show(
                        context,
                        '수신동의 처리 완료',
                        '전송자: Wanna Do\n일시: ${DateFormatUtilsSeven.formatDay(DateTime.now())}',
                      );
                    } else {
                      Get.dialog(
                        DialogTwoButton(
                          title: '마케팅 알림',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '마케팅 알림을 해제하면 워너두의 다양한 혜택과 이벤트 소식을 더이상 받을 수 없어요. 그래도 해제할까요?',
                                style: font15w700.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                          leftText: '해제하기',
                          rightText: '유지하기',
                          onLeftButtonPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(authUid)
                                .collection('agreement')
                                .doc(authUid)
                                .update({
                              'pushAd': !pushAd,
                            });
                            await FirebaseMessaging.instance
                                .unsubscribeFromTopic("pushAd");
                            setState(() {});
                            Get.back();

                            InfoGetxToast.show(
                              context,
                              '수신거부 처리 완료',
                              '전송자: Wanna Do\n일시: ${DateFormatUtilsSeven.formatDay(DateTime.now())}',
                            );
                          },
                          onRightButtonPressed: () {
                            Get.back();
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '마케팅 알림',
                                style: font20w700,
                              ),
                              Text(
                                '다양한 혜택 및 이벤트 소식 알림',
                                style: font14w400,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: pushAd,
                          activeColor: mainColor,
                          inactiveThumbColor: charcoalColor,
                          inactiveTrackColor: mainColorLight,
                          onChanged: (bool value) {
                            setState(() {
                              pushAd = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
