import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/list_item_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class MyChallengeRecord extends StatefulWidget {
  MyChallengeRecord({super.key});

  @override
  State<MyChallengeRecord> createState() => _MyChallengeRecordState();
}

class _MyChallengeRecordState extends State<MyChallengeRecord> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  int selectedButtonIndex = 0;
  final List<String> buttonStatusTexts = [
    '전체',
    '인증전',
    '검사진행중',
    '성공',
    '실패',
    '이의신청중',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: '나의 챌린지 기록',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
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
                        '매우 오래된 챌린지 기록이나 인증 내역은 자동으로 삭제될 수 있어요',
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: List.generate(6, (index) {
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
              ],
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '등록순',
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('challenge')
                  .doc(authUid)
                  .collection('challenge')
                  .orderBy('applyAt', descending: true)
                  .limit(1000)
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
                List<DocumentSnapshot> docTotalList = [];
                List<DocumentSnapshot> docApplyList = [];
                List<DocumentSnapshot> docCertifyList = [];
                List<DocumentSnapshot> docComplainList = [];
                List<DocumentSnapshot> docWinList = [];
                List<DocumentSnapshot> docLoseList = [];
                List<DocumentSnapshot> docStreamList = [];

                for (var doc in snapshot.data!.docs) {
                  docTotalList.add(doc);
                }

                docApplyList = docTotalList
                    .where((doc) => doc.get('status') == 'apply')
                    .toList();

                docCertifyList = docTotalList
                    .where((doc) => doc.get('status') == 'certify')
                    .toList();
                docComplainList = docTotalList
                    .where((doc) => doc.get('status') == 'complain')
                    .toList();
                docWinList = docTotalList
                    .where((doc) => doc.get('status') == 'win')
                    .toList();

                docLoseList = docTotalList
                    .where((doc) => doc.get('status') == 'lose')
                    .toList();

                switch (selectedButtonIndex) {
                  case 1:
                    docStreamList = docApplyList;
                    break;
                  case 2:
                    docStreamList = docCertifyList;
                    break;
                  case 3:
                    docStreamList = docWinList;
                    break;
                  case 4:
                    docStreamList = docLoseList;
                    break;
                  case 5:
                    docStreamList = docComplainList;
                    break;
                  default:
                    docStreamList = docTotalList;
                }

                if (docStreamList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'asset/lottie/wanna_do_checker_animation.json',
                          height: 250,
                        ),
                        SizedBox(height: 30),
                        Text(
                          '아직 여기에는 챌린지 기록이 없어요',
                          style: font15w700,
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot challengeSnapshot =
                            docStreamList[index];

                        ChallengeModel data = ChallengeModel.fromJson(
                          challengeSnapshot.data() as Map<String, dynamic>,
                        );

                        return MainListTimeItem(
                          goal: data.goal,
                          time: DateFormatUtilsSecond.formatDay(
                              data.applyAt!.toDate()),
                          status: data.status,
                          category: data.category,
                          deadline: data.deadline.toDate(),
                          betPoint: data.betPoint,
                          docId: data.docId,
                          certifyAt: data.certifyAt?.toDate(),
                          certifyUrl: data.certifyUrl,
                          checkAt: data.checkAt?.toDate(),
                          thumbNailUrl: data.thumbNailUrl,
                          checker: data.checker,
                          complainReason: data.complainReason,
                          failReason: data.failReason,
                          isVideo: data.isVideo,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          thickness: 0.3,
                        );
                      },
                      itemCount: docStreamList.length,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
