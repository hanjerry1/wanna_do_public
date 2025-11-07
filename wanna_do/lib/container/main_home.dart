import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:wanna_do/component/challenge_page_view.dart';
import 'package:wanna_do/component/challenges_home.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/help/agreement_home.dart';
import 'package:wanna_do/container/help/company_home.dart';
import 'package:wanna_do/container/help/guide_home.dart';
import 'package:wanna_do/container/help/notice_home.dart';
import 'package:wanna_do/container/my_challenge/my_challenge_home.dart';
import 'package:wanna_do/container/rank/rank_home.dart';
import 'package:wanna_do/controller/page/challenge_controller.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/model/statistic/month_rank_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/list_item_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class MainHome extends StatefulWidget {
  MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  final ChallengeController controller = Get.put(ChallengeController());
  List<DocumentSnapshot> docMonthScoreList = [];
  final List<String> buttonStatusTexts = [
    '전체',
    '인증전',
    '검사진행중',
    '성공',
    '실패',
  ];
  bool isEmptyRank = false;

  @override
  void initState() {
    super.initState();
    loadInitMonthScoreData();
  }

  Future<void> loadInitMonthScoreData() async {
    try {
      QuerySnapshot mainSnapshot = await FirebaseFirestore.instance
          .collection('log')
          .doc('monthRankLog')
          .collection('monthRankLog')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (mainSnapshot.docs.isEmpty) {
        setState(() {
          isEmptyRank = true;
        });
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

      if (subSnapshot.docs.isEmpty) {
        setState(() {
          isEmptyRank = true;
        });
        return;
      }

      setState(() {
        for (var doc in subSnapshot.docs) {
          docMonthScoreList.add(doc);
        }
      });
    } catch (e) {}
  }

  Future<void> sendEmail() async {
    final Email email = Email(
      body: '',
      subject: '[Wanna Do 이용 문의]'
          '\n문의자: ${FirebaseAuth.instance.currentUser!.uid}'
          '\n\n회원님이 기다리지 않도록 신속하게 답변하려고 노력하고 있어요!'
          '\n다만, 불쾌감을 주는 표현을 사용하거나 반복적이고 무분별한 문의는 답변하지 않으니 유의해주세요.',
      recipients: ['climbers.hst@gmail.com'],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MainAppBar(
        title: 'Wanna Do',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                Get.to(() => NoticeHome());
              },
              icon: SvgPicture.asset(
                'asset/svg/notice_icon.svg',
                height: 27,
              ),
            ),
          ),
        ],
        textStyle: fontAppLogo.copyWith(
          color: Colors.black,
        ),
      ),
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => MyChallengeHome());
                      },
                      child: Row(
                        children: [
                          Text(
                            'My 챌린지',
                            style: font20w700,
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 35,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              controller.changeSelectedIndexMainHome(index);
                            },
                            child: Obx(
                              () => StateButtonFirst(
                                widgetText: buttonStatusTexts[index],
                                isSelected: controller
                                        .selectedButtonIndexMainHome.value ==
                                    index,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 10),
                    Obx(
                      () {
                        final docStreamList = controller.docStreamMainHomeList;
                        if (controller.isLoading.value) {
                          return Container(
                            height: 300,
                            child: Center(
                              child: Lottie.asset(
                                'asset/lottie/short_loading_first_animation.json',
                                height: 50,
                              ),
                            ),
                          );
                        }

                        if (docStreamList.isEmpty) {
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
                                  SizedBox(height: 10),
                                  Text(
                                    '아직 여기에는 챌린지 기록이 없어요',
                                    style: font15w400,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot challengeSnapshot =
                                  docStreamList[index];

                              ChallengeModel data = ChallengeModel.fromJson(
                                challengeSnapshot.data()
                                    as Map<String, dynamic>,
                              );

                              return MainListTimerItem(
                                category: data.category,
                                goal: data.goal,
                                deadline: data.deadline.toDate(),
                                status: data.status,
                                betPoint: data.betPoint,
                                docId: data.docId,
                                isVideo: data.isVideo,
                                isVisible: data.isVisible,
                                certifyAt: data.certifyAt?.toDate(),
                                certifyUrl: data.certifyUrl,
                                thumbNailUrl: data.thumbNailUrl,
                                checkAt: data.checkAt?.toDate(),
                                checker: data.checker,
                                complainReason: data.complainReason,
                                failReason: data.failReason,
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(
                                thickness: 0.3,
                              );
                            },
                            itemCount: docStreamList.length,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: MediumButtonFirst(
                            buttonText: '1개 챌린지 시작하기',
                            onPressed: () async {
                              Get.to(() => ChallengePageView());
                            },
                            backgroundColor: subColorLight,
                            textColor: subColorDark,
                          ),
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: MediumButtonFirst(
                            buttonText: '여러 챌린지 시작하기',
                            onPressed: () {
                              Get.to(() => ChallengesHome());
                            },
                            backgroundColor: mainColorLight,
                            textColor: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => GuideHome());
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 80,
                    decoration: BoxDecoration(
                      color: greyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),
                        Image.asset(
                          'asset/img/guide.png',
                          width: 35,
                          color: charcoalColor,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '챌린지를 어떻게 하는지 모르겠다면?',
                                style: font15w700.copyWith(
                                  color: charcoalColor,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '워너두 가이드 살펴보기',
                                style: font15w300.copyWith(
                                  color: charcoalColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => RankHome());
                            },
                            child: Row(
                              children: [
                                Text(
                                  '명예의 전당',
                                  style: font20w700,
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 35,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              '지난달 랭킹',
                              style: font15w700.copyWith(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (!isEmptyRank)
                      Container(
                        height: 200,
                        child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot monthRankSnapshot =
                                docMonthScoreList[index];

                            MonthRankModel monthRankData =
                                MonthRankModel.fromJson(
                              monthRankSnapshot.data() as Map<String, dynamic>,
                            );

                            return SubListMonthScoreItem(
                              rank: index + 1,
                              uid: monthRankData.uid,
                              name: monthRankData.name,
                              monthWin: monthRankData.monthWin,
                              monthLose: monthRankData.monthLose,
                              monthChallenge: monthRankData.monthChallenge,
                              monthScore: monthRankData.monthScore,
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              thickness: 0.3,
                            );
                          },
                          itemCount: docMonthScoreList.length > 3
                              ? 3
                              : docMonthScoreList.length,
                        ),
                      ),
                    if (isEmptyRank)
                      Container(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'asset/lottie/wanna_do_checker_animation.json',
                                height: 100,
                              ),
                              SizedBox(height: 10),
                              Text(
                                '아직 랭킹이 없거나 심사중이에요',
                                style: font15w400,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 180,
                color: greyColor.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Wanna Do',
                              style: fontCorpLogo.copyWith(
                                color: greyColorInfoText,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => CompanyHome());
                            },
                            child: Row(
                              children: [
                                Text(
                                  'by Climbers',
                                  style: font14w700.copyWith(
                                    color: greyColorInfoText,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: greyColorInfoText,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => NoticeHome());
                        },
                        child: Text(
                          '공지사항',
                          style: font13w400.copyWith(
                            color: greyColorInfoText,
                          ),
                        ),
                      ),
                      SizedBox(height: 7),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => AgreementHome());
                        },
                        child: Text(
                          '이용약관 | 개인정보처리방침',
                          style: font13w400.copyWith(
                            color: greyColorInfoText,
                          ),
                        ),
                      ),
                      SizedBox(height: 7),
                      GestureDetector(
                        onTap: () async {
                          if (Platform.isAndroid) {
                            await sendEmail();
                          } else if (Platform.isIOS) {
                            ErrorGetxToast.show(context,
                                '아이폰은 이메일 문의를 지원하지 않아요', 'MY 탭에서 문의하기를 이용해주세요');
                          }
                        },
                        child: Text(
                          'Contact : climbers.hst@gmail.com',
                          style: font13w400.copyWith(
                            color: greyColorInfoText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
