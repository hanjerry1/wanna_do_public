import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/container/challenge/challenge_checkup_detail.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengeCheckupManage extends StatefulWidget {
  const ChallengeCheckupManage({super.key});

  @override
  State<ChallengeCheckupManage> createState() => _ChallengeCheckupManageState();
}

class _ChallengeCheckupManageState extends State<ChallengeCheckupManage> {
  bool isLoading = false;
  int selectedButtonIndex = 0;
  List<DocumentSnapshot> challengeList = [];
  final List<String> buttonStatusTexts = [
    '체크업 전체',
    '성공 챌린지',
    '실패 챌린지',
  ];

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
                          .collection('log')
                          .doc('checkupLog')
                          .collection('checkupLog')
                          .orderBy('checkAt', descending: false)
                          .limit(10)
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
                        List<DocumentSnapshot> docVisibleTotalList = [];
                        List<DocumentSnapshot> docWinList = [];
                        List<DocumentSnapshot> docLoseList = [];
                        List<DocumentSnapshot> docFutureList = [];

                        for (var doc in snapshot.data!.docs) {
                          docTotalList.add(doc);
                        }

                        docVisibleTotalList = docTotalList
                            .where((doc) => doc.get('isVisible') == true)
                            .toList();

                        docWinList = docTotalList
                            .where((doc) => doc.get('status') == 'win')
                            .toList();

                        docLoseList = docTotalList
                            .where((doc) => doc.get('status') == 'lose')
                            .toList();

                        switch (selectedButtonIndex) {
                          case 0:
                            docFutureList = docVisibleTotalList;
                          case 1:
                            docFutureList = docWinList;
                          case 2:
                            docFutureList = docLoseList;
                          default:
                            docFutureList = docVisibleTotalList;
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

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
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
                                        Get.to(
                                          () => ChallengeCheckupDetail(
                                            challengeSnapshot:
                                                challengeSnapshot,
                                          ),
                                        )!
                                            .then((value) {
                                          setState(() {});
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('log')
                                                  .doc('checkupLog')
                                                  .collection('checkupLog')
                                                  .doc(challengeSnapshot.id)
                                                  .delete();

                                              setState(() {});
                                            },
                                            child: Container(
                                              color: redColorLight,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.close_outlined,
                                                  color: redColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '${data.status == 'win' ? '성공판정' : '실패판정'} | 목표: ${data.goal}',
                                                        style: font16w700,
                                                        maxLines: 3,
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
                                            color:
                                                Colors.black.withOpacity(0.5),
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
                              ),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                List<String> docIdsToDelete = docFutureList
                                    .take(4)
                                    .map((doc) => doc.id)
                                    .toList();

                                for (String docId in docIdsToDelete) {
                                  await FirebaseFirestore.instance
                                      .collection('log')
                                      .doc('checkupLog')
                                      .collection('checkupLog')
                                      .doc(docId)
                                      .delete();
                                }

                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: Text(
                                '전체에서 최근 4개씩 삭제',
                                style: font18w800.copyWith(
                                  color: mainColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
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
