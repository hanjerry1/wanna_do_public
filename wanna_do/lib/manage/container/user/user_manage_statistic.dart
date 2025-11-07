import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/statistic/statistic_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';

class UserManageStatistic extends StatefulWidget {
  final String uid;

  const UserManageStatistic({
    super.key,
    required this.uid,
  });

  @override
  State<UserManageStatistic> createState() => _UserManageStatisticState();
}

class _UserManageStatisticState extends State<UserManageStatistic> {
  TextEditingController textEditingController1 =
      TextEditingController(text: '');
  bool isLoading = false;
  String field = '';

  Future<void> updateStatistic() async {
    try {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('statistic')
          .doc(widget.uid)
          .update({
        field: int.parse(textEditingController1.text),
      });
      setState(() {
        isLoading = false;
      });
      InfoGetxToast.show(context, '통계 변경 알림', '통계가 업데이트 되었어요');
    } catch (e) {
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('statistic')
            .doc(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
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

          StatisticModel data = StatisticModel.fromJson(
            snapshot.data!.data() as Map<String, dynamic>,
          );

          Map<String, dynamic> dataMap = data.toJson();

          List<String> variableNames = [
            'todayCheckup',
            'totalChallenge',
            'totalWin',
            'totalLose',
            'totalCheckup',
            'totalMyLikePost',
            'totalMyPost',
            'totalMedal',
            'monthChallenge',
            'monthWin',
            'monthLose',
            'monthCheckup',
            'monthMyPost',
            'monthPointOutTicket',
          ];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          field,
                          style: font15w400,
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${dataMap[field] ?? '수정할 필드를 선택'}',
                          style: font15w700,
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: '숫자입력'),
                        controller: textEditingController1,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 10),
                    SmallButtonFirst(
                      onPressed: () async {
                        if (field != '' &&
                            textEditingController1.text.isNotEmpty) {
                          await updateStatistic();
                        }
                      },
                      backgroundColor: mainColor,
                      content: Text(
                        'update',
                        style: font13w700.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: variableNames.length,
                  itemBuilder: (context, index) {
                    String variableName = variableNames[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          field = variableName;
                        });
                      },
                      child: ListTile(
                        title: Text(variableName),
                        trailing: Icon(Icons.add),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
