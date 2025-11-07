import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/manage/container/challenge/challenge_complain_detail.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/model/checkup/request_queue_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengeComplainManage extends StatefulWidget {
  const ChallengeComplainManage({super.key});

  @override
  State<ChallengeComplainManage> createState() =>
      _ChallengeComplainManageState();
}

class _ChallengeComplainManageState extends State<ChallengeComplainManage> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;
  int selectedButtonIndex = 0;
  List<DocumentSnapshot> challengeList = [];
  final List<String> buttonStatusTexts = [
    '실패 이의제기',
    '성공 이의제기',
    '검사중',
  ];

  Future<void> checkChallenge(
      DocumentSnapshot challengeSnapshot, ChallengeModel data) async {
    try {
      String deviceId = '';

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('service')
          .doc('challengeComplain')
          .collection('challengeComplain')
          .where('docId', isEqualTo: data.docId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        ErrorGetxToast.show(context, '새로고침 해주세요', '존재하지 않는 문서이거나 네트워크 오류에요');
        return;
      }

      DocumentSnapshot challengeComplainDoc = querySnapshot.docs.first;
      DocumentReference docRef = querySnapshot.docs.first.reference;

      if (challengeComplainDoc.get('checkingState') != 'checking') {
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
          deviceId = iosInfo.identifierForVendor!;
        }

        RequestQueueModel requestQueueModel = RequestQueueModel(
          uid: authUid,
          deviceInfo: deviceId,
        );

        await docRef.collection('requestQueue').add(requestQueueModel.toJson());

        QuerySnapshot requestQueueSnapshot = await docRef
            .collection('requestQueue')
            .orderBy('createdAt', descending: false)
            .limit(1)
            .get();

        if (requestQueueSnapshot.docs.isEmpty) {
          setState(() {
            isLoading = false;
          });
          ErrorGetxToast.show(context, '이미 검사중인 챌린지에요', '다른 챌린지를 검사해주세요');
          return;
        }

        DocumentSnapshot requestQueueDoc = requestQueueSnapshot.docs.first;

        RequestQueueModel requestQueueData = RequestQueueModel.fromJson(
          requestQueueDoc.data() as Map<String, dynamic>,
        );

        if (requestQueueData.uid == authUid &&
            requestQueueData.deviceInfo == deviceId) {
          await docRef.update({
            'checkingState': 'checking',
          });

          Get.to(
            () => ChallengeComplainDetail(
              challengeSnapshot: challengeSnapshot,
            ),
          )!
              .then((value) {
            setState(() {
              isLoading = false;
            });
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ErrorGetxToast.show(context, '이미 검사중인 챌린지에요', '다른 챌린지를 검사해주세요');
          return;
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ErrorGetxToast.show(context, '이미 검사중인 챌린지에요', '다른 챌린지를 검사해주세요');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: SubAppBar(),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: List.generate(3, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedButtonIndex = index;
                            });
                          },
                          child: StateButtonFirst(
                            widgetText: buttonStatusTexts[index],
                            isSelected: selectedButtonIndex == index,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: CustomMaterialIndicator(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    setState(() {});
                  },
                  indicatorBuilder: (context, controller) {
                    return Lottie.asset(
                      'asset/lottie/short_loading_first_animation.json',
                      height: 100,
                    );
                  },
                  child: ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('service')
                            .doc('challengeComplain')
                            .collection('challengeComplain')
                            .orderBy('checkAt', descending: false)
                            .limit(20)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              height: 300,
                              child: Center(
                                child: Lottie.asset(
                                  'asset/lottie/short_loading_first_animation.json',
                                  height: 100,
                                ),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              height: 300,
                              child: Center(
                                child: Lottie.asset(
                                  'asset/lottie/short_loading_first_animation.json',
                                  height: 100,
                                ),
                              ),
                            );
                          }

                          List<DocumentSnapshot> docTotalList = [];
                          List<DocumentSnapshot> docLoseComplainList = [];
                          List<DocumentSnapshot> docWinComplainList = [];
                          List<DocumentSnapshot> docCheckingList = [];
                          List<DocumentSnapshot> docFutureList = [];

                          for (var doc in snapshot.data!.docs) {
                            docTotalList.add(doc);
                          }

                          docLoseComplainList = docTotalList
                              .where((doc) =>
                                  doc.get('status') == 'complain' &&
                                  doc.get('checkingState') != 'checking')
                              .toList();

                          docWinComplainList = docTotalList
                              .where((doc) =>
                                  doc.get('status') == 'win' &&
                                  doc.get('checkingState') != 'checking')
                              .toList();

                          docCheckingList = docTotalList
                              .where((doc) =>
                                  doc.get('checkingState') == 'checking')
                              .toList();

                          switch (selectedButtonIndex) {
                            case 0:
                              docFutureList = docLoseComplainList;
                            case 1:
                              docFutureList = docWinComplainList;
                            case 2:
                              docFutureList = docCheckingList;
                            default:
                              docFutureList = docLoseComplainList;
                          }

                          if (docFutureList.isEmpty) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'asset/lottie/wanna_do_checker_animation.json',
                                      height: 200,
                                    ),
                                    Text(
                                      '아직 여기에는 챌린지 기록이 없어요',
                                      style: font15w400,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot challengeSnapshot =
                                  docFutureList[index];

                              ChallengeModel data = ChallengeModel.fromJson(
                                challengeSnapshot.data()
                                    as Map<String, dynamic>,
                              );

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    try {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      if (selectedButtonIndex == 2 &&
                                          data.checkingState == 'checking') {
                                        Get.to(
                                          () => ChallengeComplainDetail(
                                            challengeSnapshot:
                                                challengeSnapshot,
                                          ),
                                        )!
                                            .then((value) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                        });
                                      } else {
                                        await checkChallenge(
                                          challengeSnapshot,
                                          data,
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      ErrorGetxToast.show(context, '새로고침 해주세요',
                                          '존재하지 않는 문서이거나 네트워크 오류에요');
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '항의이유: ${data.complainReason}',
                                                    style: font16w700,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '내기금액: ${data.betPoint}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'uid: ${data.uid}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                      '검사일: ${data.checkAt!.toDate().toString()}'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.chevron_right_outlined,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider();
                            },
                            itemCount: docFutureList.length,
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isLoading) ShortLoadingFirst(),
      ],
    );
  }
}
