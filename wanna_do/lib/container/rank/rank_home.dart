import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:easy_tooltip/easy_tooltip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/rank/rank_month_score.dart';
import 'package:wanna_do/model/statistic/statistic_model.dart';
import 'package:wanna_do/model/user/user_state_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/list_item_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';

class RankHome extends StatefulWidget {
  const RankHome({super.key});

  @override
  State<RankHome> createState() => _RankHomeState();
}

class _RankHomeState extends State<RankHome> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  DateTime? lastRefreshTime;

  Future<void> onRefresh() async {
    final now = DateTime.now();
    if (lastRefreshTime == null ||
        now.difference(lastRefreshTime!).inSeconds > 5) {
      lastRefreshTime = now;
      setState(() {});
    } else {
      final secondsLeft = 5 - now.difference(lastRefreshTime!).inSeconds;
      ErrorGetxToast.show(
        context,
        '새로고침 대기',
        '$secondsLeft초 후에 다시 새로고침 해주세요',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: '명예의 전당',
      ),
      body: CustomMaterialIndicator(
        elevation: 0,
        backgroundColor: Colors.white,
        onRefresh: onRefresh,
        indicatorBuilder: (context, controller) {
          return Lottie.asset(
            'asset/lottie/short_loading_first_animation.json',
            height: 100,
          );
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '지난달 나의 랭킹',
                          style: font20w700,
                        ),
                      ),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('user')
                            .doc(authUid)
                            .collection('userState')
                            .doc(authUid)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Lottie.asset(
                              'asset/lottie/short_loading_first_animation.json',
                              height: 50,
                            );
                          }

                          UserStateModel data = UserStateModel.fromJson(
                            snapshot.data!.data() as Map<String, dynamic>,
                          );

                          return Text(
                            '${data.grade}등',
                            style: font37w700,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BigButtonSecond(
                  buttonText: '지난달 명예의 전당',
                  backgroundColor: mainColorLight,
                  textColor: mainColor,
                  onPressed: () {
                    Get.to(() => RankMonthScore());
                  },
                ),
              ),
              SizedBox(height: 25),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 10,
                color: greyColor.withOpacity(0.3),
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: greyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            '매달 랭킹 상금',
                            style: font18w800.copyWith(
                              color: charcoalColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Image.asset(
                              'asset/img/medal_first.png',
                              height: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              '30,000원 적립금 지급',
                              style: font15w700,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Image.asset(
                              'asset/img/medal_second.png',
                              height: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              '20,000원 적립금 지급',
                              style: font15w700,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Image.asset(
                              'asset/img/medal_third.png',
                              height: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              '10,000원 적립금 지급',
                              style: font15w700,
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              '4-10등',
                              style: font16w800,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '5,000원 적립금 지급',
                              style: font15w700,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '심사 방식',
                                style: font15w800.copyWith(
                                  color: charcoalColor,
                                ),
                              ),
                            ),
                            EasyTooltip(
                              bubbleWidth: 300,
                              backgroundColor: mainColor,
                              text: '메달권인 회원은 1달간 워너두가 임명한 위너 회원으로 활동할 수 있어요.'
                                  '\n회원들의 의견을 모아 전달하면 워너님의 의견을 빼놓지 않고 모두 귀담아 들을게요.',
                              textStyle: font14w700.copyWith(
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: orangeColor,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '추가혜택?',
                                    style: font13w700.copyWith(
                                      color: orangeColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Text(
                          '이번달 챌린지 성공수가 30회 이상인 회원중 절반(최대10명)을 선정하여 랭킹별 상금 지급',
                          style: font15w700.copyWith(
                            color: charcoalColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '심사 기준',
                          style: font15w800.copyWith(
                            color: charcoalColor,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          '성공난이도(50)+진정성(25)+성실성(25)',
                          style: font15w700.copyWith(
                            color: charcoalColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        '이번달 성공',
                        style: font15w700.copyWith(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('statistic')
                      .orderBy('monthWin', descending: true)
                      .limit(30)
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

                    List<DocumentSnapshot> docTotalList = [];

                    for (var doc in snapshot.data!.docs) {
                      docTotalList.add(doc);
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot documentSnapshot = docTotalList[index];

                        StatisticModel data = StatisticModel.fromJson(
                          documentSnapshot.data() as Map<String, dynamic>,
                        );

                        return SubListMonthWinItem(
                          rank: index + 1,
                          uid: data.uid,
                          name: data.name,
                          monthWin: data.monthWin,
                          monthLose: data.monthLose,
                          monthChallenge: data.monthChallenge,
                          monthScore: 0,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          thickness: 0.3,
                        );
                      },
                      itemCount: docTotalList.length,
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
