import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/list_item_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class UserChallenge extends StatefulWidget {
  final String uid;

  const UserChallenge({
    super.key,
    required this.uid,
  });

  @override
  State<UserChallenge> createState() => _UserChallengeState();
}

class _UserChallengeState extends State<UserChallenge> {
  DateTime now = DateTime.now();
  int number = 0;
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
        title: '챌린지',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
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
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('challenge')
                  .doc(widget.uid)
                  .collection('challenge')
                  .orderBy('applyAt', descending: true)
                  .limit(100)
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
        ],
      ),
    );
  }
}
