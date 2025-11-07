import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/container/user/user_manage.dart';
import 'package:wanna_do/model/statistic/month_rank_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class RankManage extends StatefulWidget {
  const RankManage({super.key});

  @override
  State<RankManage> createState() => _RankManageState();
}

class _RankManageState extends State<RankManage> {
  Map<int, TextEditingController> controllers = {};
  int successRate = 0;
  int monthScore = 100;
  String docId = '';
  String orderby = 'monthWin';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDocId();
  }

  @override
  void dispose() {
    controllers.forEach((_, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void getDocId() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('log')
        .doc('monthRankLog')
        .collection('monthRankLog')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(1)
        .get();

    setState(() {
      isLoading = false;
      docId = querySnapshot.docs.first.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Lottie.asset(
            'asset/lottie/short_loading_first_animation.json',
            height: 100,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SubAppBar(
          title: '지난달 성공수 순위',
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '1. 이번달 챌린지 확인후 성공난이도50+진정성25+성실성25=100으로 심사 점수 주기\n\n'
                  '2. 심사 점수로 배열후 사용자 정보 이동 > 순위 입력 및 포인트 추가 > 개인공지 명예의전당 전송 > 메달권이면 통계에서 메달+1',
                  style: font13w700,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          orderby = 'monthWin';
                        });
                      },
                      child: Text(
                        '성공수 배열',
                        style: font15w700.copyWith(
                          color: mainColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          orderby = 'monthScore';
                        });
                      },
                      child: Text(
                        '심사점수 배열',
                        style: font15w700.copyWith(
                          color: purpleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('log')
                      .doc('monthRankLog')
                      .collection('monthRankLog')
                      .doc(docId)
                      .collection('monthRank')
                      .orderBy(orderby, descending: true)
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

                    for (var doc in snapshot.data!.docs) {
                      docTotalList.add(doc);
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot documentSnapshot = docTotalList[index];

                        MonthRankModel data = MonthRankModel.fromJson(
                          documentSnapshot.data() as Map<String, dynamic>,
                        );

                        if (!controllers.containsKey(index)) {
                          controllers[index] = TextEditingController();
                        }
                        TextEditingController controller = controllers[index]!;

                        successRate = (data.monthWin + data.monthLose) == 0
                            ? 0
                            : ((data.monthWin.toDouble() /
                                        (data.monthWin + data.monthLose)) *
                                    100)
                                .toInt();

                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '지난달 성공수: ${data.monthWin}',
                                    style: font15w700.copyWith(
                                      color: mainColor,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '심사 점수: ${data.monthScore}',
                                    style: font15w700.copyWith(
                                      color: purpleColor,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '성공률 ${successRate}%',
                                    style: font14w700.copyWith(
                                      color: orangeColor,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text('지난달 실패수: ${data.monthLose}'),
                                  SizedBox(height: 5),
                                  Text('지난달 챌린지 수: ${data.monthChallenge}'),
                                  SizedBox(height: 5),
                                  Text(
                                    DateFormatUtilsSecond.formatDay(
                                        data.createdAt.toDate()),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      child: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          hintText: '심사 점수',
                                          counterText: '',
                                        ),
                                        maxLines: 1,
                                        maxLength: 5,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      child: Text('저장'),
                                      onPressed: () async {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());

                                        await FirebaseFirestore.instance
                                            .collection('log')
                                            .doc('monthRankLog')
                                            .collection('monthRankLog')
                                            .doc(docId)
                                            .collection('monthRank')
                                            .doc(documentSnapshot.id)
                                            .update({
                                          'monthScore':
                                              int.parse(controller.text),
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                SmallButtonFirst(
                                  onPressed: () {
                                    Get.to(
                                      () => UserManage(
                                        uid: data.uid,
                                      ),
                                    );
                                  },
                                  backgroundColor: mainColor,
                                  content: Text(
                                    '사용자 정보',
                                    style: font15w700.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
            ],
          ),
        ),
      ),
    );
  }
}
