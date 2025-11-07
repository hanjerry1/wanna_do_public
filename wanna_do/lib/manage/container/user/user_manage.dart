import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/container/user/user_challenge.dart';
import 'package:wanna_do/manage/container/user/user_direct_message.dart';
import 'package:wanna_do/manage/container/user/user_manage_statistic.dart';
import 'package:wanna_do/manage/container/user/user_state_manage.dart';
import 'package:wanna_do/model/point/point_log_model.dart';
import 'package:wanna_do/model/point/point_model.dart';
import 'package:wanna_do/model/user/user_state_log_model.dart';
import 'package:wanna_do/model/user/user_state_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class UserManage extends StatefulWidget {
  final String? uid;

  const UserManage({
    super.key,
    this.uid,
  });

  @override
  State<UserManage> createState() => _UserManageState();
}

class _UserManageState extends State<UserManage> {
  TextEditingController textEditingController1 =
      TextEditingController(text: '');
  TextEditingController textEditingController2 =
      TextEditingController(text: '');
  TextEditingController textEditingController3 =
      TextEditingController(text: '');

  String newGrade = '';
  String newCheckupState = '';
  String newSpaceState = '';
  String previousGradeState = '';
  String previousCheckupState = '';
  String previousSpaceState = '';
  String newAddPoint = '';
  String previousPoint = '';
  String pointFrom = '월말 랭킹 상금';
  bool isLoading = false;

  Future<void> addPoint() async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('point')
          .doc(widget.uid)
          .update({
        'point': FieldValue.increment(int.parse(newAddPoint)),
      });

      PointLogModel pointLogModel = PointLogModel(
          uid: widget.uid!,
          inout: 'in',
          pointFrom: pointFrom,
          point: int.parse(newAddPoint));

      await FirebaseFirestore.instance
          .collection('point')
          .doc(widget.uid)
          .collection('pointLog')
          .add(pointLogModel.toJson());
      setState(() {
        isLoading = false;
      });
      InfoGetxToast.show(context, '포인트 추가 완료', '포인트가 추가 되었어요');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> subtractPoint() async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('point')
          .doc(widget.uid)
          .update({
        'point': FieldValue.increment(-int.parse(newAddPoint)),
      });

      PointLogModel pointLogModel = PointLogModel(
        uid: widget.uid!,
        inout: 'out',
        pointFrom: pointFrom,
        point: int.parse(newAddPoint),
      );

      await FirebaseFirestore.instance
          .collection('point')
          .doc(widget.uid)
          .collection('pointLog')
          .add(pointLogModel.toJson());

      setState(() {
        isLoading = false;
      });
      InfoGetxToast.show(context, '포인트 감소 완료', '포인트가 감소 되었어요');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> updateGrade() async {
    try {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });
      UserStateLogModel userStateLogModel = UserStateLogModel(
        stateFrom: 'grade',
        newState: textEditingController1.text,
        previousState: previousGradeState,
      );

      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .collection('userState')
          .doc(widget.uid)
          .collection('userStateLog')
          .add(userStateLogModel.toJson());

      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .collection('userState')
          .doc(widget.uid)
          .update({
        'grade': textEditingController1.text,
      });
      setState(() {
        isLoading = false;
      });
      InfoGetxToast.show(context, '등급 변경 알림', '등급이 업데이트 되었어요');
    } catch (e) {
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> updateCheckupState() async {
    try {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });

      UserStateLogModel userStateLogModel = UserStateLogModel(
        stateFrom: 'checkup',
        newState: textEditingController2.text,
        previousState: previousCheckupState,
      );

      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .collection('userState')
          .doc(widget.uid)
          .collection('userStateLog')
          .add(userStateLogModel.toJson());

      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .collection('userState')
          .doc(widget.uid)
          .update({'checkupState': textEditingController2.text});

      InfoGetxToast.show(context, '등급 변경 알림', '등급이 업데이트 되었어요');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> updateSpaceState() async {
    try {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });

      UserStateLogModel userStateLogModel = UserStateLogModel(
        stateFrom: 'space',
        newState: textEditingController3.text,
        previousState: previousSpaceState,
      );

      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .collection('userState')
          .doc(widget.uid)
          .collection('userStateLog')
          .add(userStateLogModel.toJson());

      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .collection('userState')
          .doc(widget.uid)
          .update({'spaceState': textEditingController3.text});

      InfoGetxToast.show(context, '등급 변경 알림', '등급이 업데이트 되었어요');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  String pointFromTranslate(String pointFrom) {
    switch (pointFrom) {
      case 'checkup':
        return '체크업 적립금';
      case 'challenge':
        return '챌린지 실패 지원금';
      case 'out':
        return '적립금 출금';
      case 'reward':
        return '월말 랭킹 상금';
      case 'outReject':
        return '적립금 출금 거절';
      default:
        return pointFrom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: SubAppBar(),
            body: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(widget.uid)
                  .collection('userState')
                  .doc(widget.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Lottie.asset(
                      'asset/lottie/short_loading_first_animation.json',
                      height: 100,
                    ),
                  );
                }
                UserStateModel data = UserStateModel.fromJson(
                  snapshot.data!.data() as Map<String, dynamic>,
                );

                previousGradeState = data.grade;
                previousCheckupState = data.checkupState;
                previousSpaceState = data.spaceState;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                        ClipboardData(text: widget.uid!))
                                    .then((_) {
                                  InfoGetxToast.show(
                                    context,
                                    '클립보드 복사 완료',
                                    'uid: ${widget.uid}',
                                  );
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'uid: ${widget.uid!}',
                                    style: font15w700,
                                  ),
                                  SizedBox(width: 20),
                                  Icon(Icons.copy),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => UserChallenge(
                                            uid: widget.uid!,
                                          ));
                                    },
                                    child: Text('챌린지 관리하기'),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.to(
                                        () => UserDirectMessage(
                                          uid: widget.uid!,
                                        ),
                                      );
                                    },
                                    child: Text('다이렉트 메세지'),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: SmallButtonFirst(
                                    onPressed: () {
                                      Get.to(
                                        () => UserManageStatistic(
                                          uid: widget.uid!,
                                        ),
                                      );
                                    },
                                    backgroundColor: mainColor,
                                    content: Text(
                                      '통계 기록',
                                      style: font14w700.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SmallButtonFirst(
                                    onPressed: () {
                                      Get.to(
                                        () => UserStateManage(
                                          uid: widget.uid!,
                                        ),
                                      );
                                    },
                                    backgroundColor: mainColor,
                                    content: Text(
                                      '상태 기록',
                                      style: font14w700.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Text(
                              '1. 상태관리',
                              style: font20w700,
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  data.grade,
                                  style: font15w700,
                                ),
                                SizedBox(width: 30),
                                Expanded(
                                  child: TextField(
                                    decoration:
                                        InputDecoration(labelText: '지난달 최종 순위'),
                                    controller: textEditingController1,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 10),
                                SmallButtonFirst(
                                  onPressed: () async {
                                    await updateGrade();
                                  },
                                  backgroundColor: mainColor,
                                  content: Text(
                                    '업데이트',
                                    style: font13w700.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  data.checkupState,
                                  style: font15w700,
                                ),
                                SizedBox(width: 30),
                                Expanded(
                                  child: TextField(
                                    decoration:
                                        InputDecoration(labelText: '체크업 등급'),
                                    controller: textEditingController2,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 10),
                                SmallButtonFirst(
                                  onPressed: () async {
                                    await updateCheckupState();
                                  },
                                  backgroundColor: mainColor,
                                  content: Text(
                                    '업데이트',
                                    style: font13w700.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  data.spaceState,
                                  style: font15w700,
                                ),
                                SizedBox(width: 30),
                                Expanded(
                                  child: TextField(
                                    decoration:
                                        InputDecoration(labelText: '스페이스 등급'),
                                    controller: textEditingController3,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 10),
                                SmallButtonFirst(
                                  onPressed: () async {
                                    await updateSpaceState();
                                  },
                                  backgroundColor: mainColor,
                                  content: Text(
                                    '업데이트',
                                    style: font13w700.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      Text(
                        '2. 포인트 관리',
                        style: font20w700,
                      ),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('point')
                            .doc(widget.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: Text('데이터가 없습니다.'),
                            );
                          }

                          PointModel data = PointModel.fromJson(
                            snapshot.data!.data() as Map<String, dynamic>,
                          );

                          previousPoint = data.point.toString();

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  previousPoint,
                                  style: font20w700.copyWith(
                                    color: mainColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration:
                                            InputDecoration(labelText: '포인트'),
                                        onChanged: (value) =>
                                            newAddPoint = value,
                                        maxLength: 8,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SmallButtonFirst(
                                      onPressed: () {
                                        if (newAddPoint != '') {
                                          Get.dialog(
                                            DialogTwoButton(
                                              title: '유저 포인트 추가',
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '포인트 제목: $pointFrom',
                                                    style: font15w400,
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    '유저에게 주려는 포인트 "$newAddPoint원"이 맞나요?',
                                                  ),
                                                ],
                                              ),
                                              leftText: '취소',
                                              rightText: '추가하기',
                                              onLeftButtonPressed: () {
                                                Get.back();
                                              },
                                              onRightButtonPressed: () async {
                                                Get.back();
                                                await addPoint();
                                              },
                                            ),
                                          );
                                        }
                                      },
                                      backgroundColor: mainColor,
                                      content: Text(
                                        '포인트 추가',
                                        style: font13w700.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: '포인트 제목',
                                        ),
                                        onChanged: (value) => pointFrom = value,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SmallButtonFirst(
                                      onPressed: () {
                                        if (newAddPoint != '') {
                                          Get.dialog(
                                            DialogTwoButton(
                                              title: '유저 포인트 감소',
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '포인트 제목: $pointFrom',
                                                    style: font15w400,
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    '유저에게 깍으려는 포인트 "$newAddPoint원"이 맞나요?',
                                                  ),
                                                ],
                                              ),
                                              leftText: '취소',
                                              rightText: '감소하기',
                                              onLeftButtonPressed: () {
                                                Get.back();
                                              },
                                              onRightButtonPressed: () async {
                                                Get.back();
                                                await subtractPoint();
                                              },
                                            ),
                                          );
                                        }
                                      },
                                      backgroundColor: mainColor,
                                      content: Text(
                                        '포인트 감소',
                                        style: font13w700.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Text(
                              '3. 포인트 기록',
                              style: font20w700,
                            ),
                            SizedBox(height: 10),
                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('point')
                                  .doc(widget.uid)
                                  .collection('pointLog')
                                  .orderBy('createdAt', descending: true)
                                  .limit(20)
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                    height: 200,
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
                                    height: 200,
                                    child: Center(
                                      child: Lottie.asset(
                                        'asset/lottie/short_loading_first_animation.json',
                                        height: 100,
                                      ),
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    DocumentSnapshot documentSnapshot =
                                        docTotalList[index];

                                    PointLogModel data = PointLogModel.fromJson(
                                      documentSnapshot.data()
                                          as Map<String, dynamic>,
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 2,
                                                color: data.inout == 'in'
                                                    ? mainColor
                                                    : redColor,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              data.inout == 'in'
                                                  ? Icons.arrow_downward_rounded
                                                  : Icons.arrow_upward_rounded,
                                              color: data.inout == 'in'
                                                  ? mainColor
                                                  : redColor,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pointFromTranslate(
                                                      data.pointFrom),
                                                  style: font15w700,
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  DateFormatUtilsSecond
                                                      .formatDay(data.createdAt!
                                                          .toDate()),
                                                  style: font14w400,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                data.point.toString(),
                                                style: font18w800.copyWith(
                                                  color: data.inout == 'in'
                                                      ? mainColor
                                                      : redColor,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                data.inout == 'in'
                                                    ? '적립'
                                                    : '출금',
                                                style: font14w400,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Divider(
                                      thickness: 0.3,
                                    );
                                  },
                                  itemCount: docTotalList.length,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (isLoading) ShortLoadingFirst(),
        ],
      ),
    );
  }
}
