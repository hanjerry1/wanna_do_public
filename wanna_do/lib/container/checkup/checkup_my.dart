import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/help/role_home.dart';
import 'package:wanna_do/container/point/point_record.dart';
import 'package:wanna_do/container/point/point_out.dart';
import 'package:wanna_do/model/checkup/checkup_log_model.dart';
import 'package:wanna_do/model/point/point_model.dart';
import 'package:wanna_do/model/statistic/statistic_model.dart';
import 'package:wanna_do/model/user/user_state_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class CheckupMy extends StatefulWidget {
  const CheckupMy({super.key});

  @override
  State<CheckupMy> createState() => _CheckupMyState();
}

class _CheckupMyState extends State<CheckupMy> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  String checkupState = '0';
  int point = 0;
  int monthChallenge = 0;
  int monthPointOutTicket = 0;

  @override
  void initState() {
    super.initState();
    loadInitUserCheckupStateData();
    loadInitStatisticData();
    loadInitPointData();
  }

  Future<void> loadInitUserCheckupStateData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(authUid)
        .collection('userState')
        .doc(authUid)
        .get();

    UserStateModel data = UserStateModel.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );

    setState(() {
      checkupState = data.checkupState;
    });
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

  String checkupStateTranslate(String checkupState) {
    switch (checkupState) {
      case '0':
        return '없음';
      case '1':
        return '경고';
      case '2':
        return '경고';
      case '3':
        return '제한';
      default:
        return '없음';
    }
  }

  String pointStateTranslate(String pointState) {
    switch (pointState) {
      case 'wait':
        return '대기';
      case 'complain':
        return '이의제기 처리';
      case 'needless':
        return '미지급';
      case 'need':
        return '지급중';
      case 'finish':
        return '지급완료';
      default:
        return '대기';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> columnsData = [
      {"label": "규정위반", "value": checkupStateTranslate(checkupState)},
      {"label": "임시적립금", "value": "$point"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: '체크업 활동',
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: columnsData.map((data) {
                return Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: () {
                      if (data['label'] == '규정위반') {
                        Get.dialog(
                          DialogTwoButton(
                            title: '규정 위반 안내',
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '없음 - 규정 위반 횟수 0회',
                                  style: font15w700.copyWith(
                                    height: 1.5,
                                  ),
                                ),
                                Text(
                                  '경고 - 규정 위반 횟수 1-2회',
                                  style: font15w700.copyWith(
                                    height: 1.5,
                                    color: orangeColor,
                                  ),
                                ),
                                Text(
                                  '제한 - 규정 위반 횟수 3회',
                                  style: font15w700.copyWith(
                                    height: 1.5,
                                    color: redColor,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  '제한된 경우, 체크업 이용이 불가하며 다시 이용을 원할 경우 고객센터로 직접 연락해주세요.'
                                  '\n(위반 횟수는 예고없이 초기화됩니다.)',
                                  style: font15w700.copyWith(
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                            leftText: '확인',
                            rightText: '규정 확인하기',
                            onLeftButtonPressed: () {
                              Get.back();
                            },
                            onRightButtonPressed: () {
                              Get.to(() => RoleHome());
                            },
                          ),
                        );
                      } else if (data['label'] == '임시적립금') {
                        loadInitPointData();
                        Get.to(() => PointRecord());
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
                              style: font18w700.copyWith(
                                color: data['label'] == '규정위반'
                                    ? checkupState == '3'
                                        ? redColor
                                        : checkupState == '0'
                                            ? Colors.black
                                            : orangeColor
                                    : Colors.black,
                              ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BigButtonSecond(
                  buttonText: '적립금 꺼내기',
                  backgroundColor: mainColorLight,
                  textColor: mainColor,
                  onPressed: () {
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
                                  '${monthChallenge}개',
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
            child: Container(
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '참고!',
                      style: font15w800.copyWith(
                        color: mainColor,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        '실패로 처리된 사용자가 24시간 내로 이의제기를 하지 않으면 나에게 내기금액 25%가 적립돼요',
                        style: font13w400.copyWith(
                          color: Colors.black.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('checkupRecord')
                        .doc(authUid)
                        .collection('checkupRecord')
                        .orderBy('createdAt', descending: true)
                        .limit(50)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Lottie.asset(
                          'asset/lottie/short_loading_first_animation.json',
                          height: 50,
                        );
                      }

                      List<DocumentSnapshot> docTotalList = [];

                      for (var doc in snapshot.data!.docs) {
                        docTotalList.add(doc);
                      }

                      return ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot documentSnapshot =
                              docTotalList[index];

                          CheckupRecordModel data = CheckupRecordModel.fromJson(
                            documentSnapshot.data() as Map<String, dynamic>,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: data.status == 'win'
                                          ? mainColor
                                          : redColor,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: data.status == 'win'
                                      ? Icon(
                                          Icons.check,
                                          color: mainColor,
                                        )
                                      : Icon(
                                          Icons.close,
                                          color: redColor,
                                        ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.goal,
                                        style: font15w700,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '내기금액: ${data.betPoint.toString()}원',
                                        style: font13w400,
                                      ),
                                      Text(
                                        DateFormatUtilsSecond.formatDay(
                                            data.createdAt!.toDate()),
                                        style: font13w400,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      pointStateTranslate(data.pointState),
                                      style: font15w700,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      data.status == 'win'
                                          ? '나-성공처리'
                                          : '나-실패처리',
                                      style: font13w400.copyWith(
                                        color: data.status == 'win'
                                            ? mainColor
                                            : redColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            thickness: 0.3,
                          );
                        },
                        itemCount: docTotalList.length,
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
