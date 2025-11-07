import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/point/point_log_model.dart';
import 'package:wanna_do/model/point/point_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class PointRecord extends StatefulWidget {
  const PointRecord({super.key});

  @override
  State<PointRecord> createState() => _PointRecordState();
}

class _PointRecordState extends State<PointRecord> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: '적립금 기록',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      '현재 적립금',
                      style: font20w700,
                    ),
                  ),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('point')
                        .doc(authUid)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Lottie.asset(
                          'asset/lottie/short_loading_first_animation.json',
                          height: 50,
                        );
                      }

                      PointModel data = PointModel.fromJson(
                        snapshot.data!.data() as Map<String, dynamic>,
                      );

                      return Text(
                        '${data.point}원',
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
                        '적립금 지급이 조금은 늦어질 수 있어요. 하지만 모두 빠짐없이 적립해드리니 걱정마세요!',
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
          SizedBox(height: 25),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 10,
            color: greyColor.withOpacity(0.3),
          ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '최신순',
                  style: font15w400,
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 25,
                  color: Colors.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('point')
                      .doc(authUid)
                      .collection('pointLog')
                      .orderBy('createdAt', descending: true)
                      .limit(50)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Lottie.asset(
                          'asset/lottie/short_loading_first_animation.json',
                          height: 50,
                        ),
                      );
                    }
                    List<DocumentSnapshot> docTotalList = [];

                    for (var doc in snapshot.data!.docs) {
                      docTotalList.add(doc);
                    }

                    return ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot documentSnapshot = docTotalList[index];

                        PointLogModel data = PointLogModel.fromJson(
                          documentSnapshot.data() as Map<String, dynamic>,
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                  color:
                                      data.inout == 'in' ? mainColor : redColor,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pointFromTranslate(data.pointFrom),
                                      style: font15w700,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      DateFormatUtilsSecond.formatDay(
                                          data.createdAt!.toDate()),
                                      style: font14w400,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    data.point.toString(),
                                    style: font18w800.copyWith(
                                      color: data.inout == 'in'
                                          ? mainColor
                                          : redColor,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    data.inout == 'in' ? '적립' : '출금',
                                    style: font14w400,
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
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
