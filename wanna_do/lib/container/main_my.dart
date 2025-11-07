import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/checkup/checkup_my.dart';
import 'package:wanna_do/container/help/contact_home.dart';
import 'package:wanna_do/container/help/guide_home.dart';
import 'package:wanna_do/container/help/notice_home.dart';
import 'package:wanna_do/container/my_challenge/my_challenge_achievement.dart';
import 'package:wanna_do/container/my_challenge/my_challenge_record.dart';
import 'package:wanna_do/container/point/point_record.dart';
import 'package:wanna_do/container/point/point_out.dart';
import 'package:wanna_do/container/setting/setting_home.dart';
import 'package:wanna_do/container/space/space_my.dart';
import 'package:wanna_do/model/point/point_model.dart';
import 'package:wanna_do/model/statistic/statistic_model.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class MainMy extends StatefulWidget {
  final String rank1Uid;
  final String rank2Uid;
  final String rank3Uid;

  const MainMy({
    super.key,
    required this.rank1Uid,
    required this.rank2Uid,
    required this.rank3Uid,
  });

  @override
  State<MainMy> createState() => _MainMyState();
}

class _MainMyState extends State<MainMy> with SingleTickerProviderStateMixin {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  AnimationController? animationController;
  String nickname = '';
  int totalChallenge = 0;
  int totalWin = 0;
  int monthChallenge = 0;
  int monthPointOutTicket = 0;
  int point = 0;

  @override
  void initState() {
    super.initState();
    loadInitStatisticData();
    loadInitPointData();
    loadInitUserData();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  Future<void> loadInitStatisticData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('statistic')
        .doc(authUid)
        .get();

    StatisticModel data = StatisticModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    setState(() {
      totalChallenge = data.totalChallenge;
      totalWin = data.totalWin;
      monthChallenge = data.monthChallenge;
      monthPointOutTicket = data.monthPointOutTicket;
    });
  }

  Future<void> loadInitPointData() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('point').doc(authUid).get();

    PointModel data = PointModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    setState(() {
      point = data.point;
    });
  }

  Future<void> loadInitUserData() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(authUid).get();

    UserModel data = UserModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    setState(() {
      nickname = data.nickname!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> columnsData = [
      {"label": "챌린지수", "value": "$totalChallenge"},
      {"label": "성공수 ", "value": "$totalWin"},
      {"label": "적립금", "value": "$point"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MainAppBar(
        title: '내정보',
        textStyle: font25w800.copyWith(
          color: Colors.black,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                Get.to(() => SettingHome());
              },
              icon: SvgPicture.asset(
                'asset/svg/my_setting.svg',
                height: 30,
              ),
            ),
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        nickname,
                        style: font20w700,
                      ),
                    ),
                    // 매일 하루 한번 터치하면 1원 적립?
                    // 너무 많이 돌리면 "그만..그만..." 멘트
                    GestureDetector(
                      onTap: () {
                        animationController!.forward(from: 0);
                      },
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 1.0)
                            .animate(animationController!),
                        child: Image.asset(
                          'asset/img/my_user.png',
                          height: 55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: columnsData.map((data) {
                    return Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () {
                          if (data['label'] == '적립금') {
                            loadInitPointData();
                            Get.to(() => PointRecord());
                          } else {
                            loadInitStatisticData();
                            Get.to(() => MyChallengeRecord());
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['label']!,
                              style: font15w400,
                            ),
                            SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  data['value']!,
                                  style: font18w700,
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.black.withOpacity(0.5),
                                  size: 25,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BigButtonSecond(
                  buttonText: '적립금 꺼내기',
                  backgroundColor: mainColorLight,
                  textColor: mainColor,
                  onPressed: () async {
                    loadInitStatisticData();
                    Get.dialog(
                      DialogTwoButton(
                        title: '적립금을 출금하는 방법',
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '이번달에 챌린지 10개를 도전하면 1개의 출금 티켓을 드려요. (월 최대1번)',
                              style: font15w700.copyWith(
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 20),
                            Divider(
                              thickness: 0.3,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '이번달 챌린지 수',
                                    style: font15w400,
                                  ),
                                ),
                                Text(
                                  '$monthChallenge개',
                                  style: font15w700.copyWith(
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 0.3,
                            ),
                          ],
                        ),
                        leftText: '취소',
                        rightText: '출금하기',
                        onLeftButtonPressed: () {
                          Get.back();
                        },
                        onRightButtonPressed: () {
                          if (monthChallenge < 10) {
                            InfoGetxToast.show(context, '10개를 도전하면 티켓을 드려요',
                                '그리 어렵지 않으니 한번 도전해봐요!');
                          } else if (monthPointOutTicket < 1) {
                            ErrorGetxToast.show(context, '이번달 출금 티켓을 이미 사용했어요',
                                '다음달이 곧 다가오니 조금만 기다려주세요!');
                          } else if (monthPointOutTicket >= 1) {
                            Get.to(() => PointOut(point: point));
                          }
                        },
                      ),
                    );
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
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '나의 활동',
                          style: font20w800,
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => MyChallengeRecord());
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'asset/svg/my_challenge_recode.svg',
                                height: 25,
                                color: mainColor,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '나의 챌린지 기록',
                                  style: font18w700,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => MyChallengeAchievement());
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'asset/svg/my_achievement.svg',
                                height: 25,
                                color: mainColor,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '나의 업적',
                                  style: font18w700,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => PointRecord());
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'asset/svg/my_point_record.svg',
                                height: 25,
                                color: mainColor,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '적립금 기록',
                                  style: font18w700,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => CheckupMy());
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'asset/svg/checkup_icon.svg',
                                height: 25,
                                color: mainColor,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '체크업 활동',
                                  style: font18w700,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => SpaceMy(
                                  rank1Uid: widget.rank1Uid,
                                  rank2Uid: widget.rank2Uid,
                                  rank3Uid: widget.rank3Uid,
                                ));
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'asset/svg/space_icon.svg',
                                height: 25,
                                color: mainColor,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '스페이스 활동',
                                  style: font18w700,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '도움말',
                          style: font20w800,
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => NoticeHome());
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'asset/svg/my_notice.svg',
                                height: 25,
                                color: subColorDark,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '공지사항',
                                  style: font18w700,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => ContactHome());
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'asset/svg/my_opinion.svg',
                                height: 25,
                                color: subColorDark,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '의견 및 문의하기',
                                  style: font18w700,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => GuideHome());
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'asset/svg/my_guide.svg',
                                height: 25,
                                color: subColorDark,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '가이드 살펴보기',
                                  style: font18w700,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
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
