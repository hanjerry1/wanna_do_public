import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/statistic/month_rank_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/list_item_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class RankMonthScore extends StatefulWidget {
  const RankMonthScore({super.key});

  @override
  State<RankMonthScore> createState() => _RankMonthScoreState();
}

class _RankMonthScoreState extends State<RankMonthScore> {
  List<DocumentSnapshot> docMonthScoreList = [];
  DateTime now = DateTime.now();
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
          .limit(10)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: '${DateFormatUtilsEight.formatDay(
          DateTime(now.year, now.month - 1, now.day),
        )} 랭킹',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
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
                        '랭킹은 월말 24시에 정산되고 심사 자격을 갖춘 회원의 활동을 평가해서 잠시후 순위가 결정돼요',
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
            SizedBox(height: 30),
            Row(
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
                    '심사 점수',
                    style: font15w700.copyWith(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            if (!isEmptyRank)
              Expanded(
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot monthRankSnapshot =
                        docMonthScoreList[index];

                    MonthRankModel monthRankData = MonthRankModel.fromJson(
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
                  itemCount: docMonthScoreList.length,
                ),
              ),
            if (isEmptyRank)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'asset/lottie/wanna_do_checker_animation.json',
                      height: 200,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '아직 랭킹이 없거나 심사중이에요',
                      style: font15w400,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
