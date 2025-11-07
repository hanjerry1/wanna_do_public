import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vertical_barchart/vertical-barchart.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/statistic/statistic_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';

class MyChallengeAchievement extends StatelessWidget {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;

  MyChallengeAchievement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: SubAppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('statistic')
            .doc(authUid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          StatisticModel data = StatisticModel.fromJson(
            snapshot.data!.data() as Map<String, dynamic>,
          );

          List<VBarChartModel> bardataMonth = [
            createBarChartModel(0, '챌린지 수', [mainColor, mainColor],
                data.monthChallenge.toDouble(), '${data.monthChallenge}개'),
            createBarChartModel(1, '챌린지 성공 수', [mainColor, mainColor],
                data.monthWin.toDouble(), '${data.monthWin}개'),
            createBarChartModel(2, '챌린지 실패 수', [mainColor, mainColor],
                data.monthLose.toDouble(), '${data.monthLose}개'),
            createBarChartModel(3, '체크업 수', [mainColor, mainColor],
                data.monthCheckup.toDouble(), '${data.monthCheckup}개'),
          ];
          List<VBarChartModel> bardataTotal = [
            createBarChartModel(0, '챌린지 수', [subColor, subColor],
                data.totalChallenge.toDouble(), "${data.totalChallenge}개"),
            createBarChartModel(1, '챌린지 성공 수', [subColor, subColor],
                data.totalWin.toDouble(), "${data.totalWin}개"),
            createBarChartModel(2, '챌린지 실패 수', [subColor, subColor],
                data.totalLose.toDouble(), "${data.totalLose}개"),
            createBarChartModel(4, '메달 획득 수', [subColor, subColor],
                data.totalMedal.toDouble(), "${data.totalMedal}개"),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                            '오래된 챌린지 기록은 자동으로 사라질 수 있어요. 전체 기간 업적은 1년 단위로 생각해주세요',
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
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '이번달 업적',
                  style: font20w800,
                ),
              ),
              Container(
                height: 250,
                child: VerticalBarchart(
                  background: Colors.transparent,
                  labelColor: Colors.black,
                  tooltipColor: greyColorDark,
                  tooltipSize: 50,
                  maxX: 400,
                  data: bardataMonth,
                  barStyle: BarStyle.DEFAULT,
                  barSize: 10,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  thickness: 0.3,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '전체 기간 업적',
                  style: font20w800,
                ),
              ),
              Container(
                height: 250,
                child: VerticalBarchart(
                  background: Colors.transparent,
                  labelColor: Colors.black,
                  tooltipSize: 50,
                  tooltipColor: greyColorDark,
                  maxX: 1500,
                  data: bardataTotal,
                  barStyle: BarStyle.DEFAULT,
                  barSize: 10,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

VBarChartModel createBarChartModel(int index, String label, List<Color> colors,
    double jumlah, String tooltip) {
  return VBarChartModel(
    index: index,
    label: label,
    colors: colors,
    jumlah: jumlah,
    tooltip: tooltip,
  );
}
