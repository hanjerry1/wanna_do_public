import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/user/user_state_log_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class UserStateManage extends StatelessWidget {
  final String uid;

  const UserStateManage({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('1. 상태관리 기록'),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('user')
                      .doc(uid)
                      .collection('userState')
                      .doc(uid)
                      .collection('userStateLog')
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

                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot documentSnapshot = docTotalList[index];

                        UserStateLogModel data = UserStateLogModel.fromJson(
                          documentSnapshot.data() as Map<String, dynamic>,
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '상태: ${data.stateFrom}',
                                style: font15w700,
                              ),
                              SizedBox(height: 5),
                              Text(
                                '이전 상태값: ${data.previousState}',
                                style: font15w700,
                              ),
                              SizedBox(height: 5),
                              Text(
                                '변경 상태값: ${data.newState}',
                                style: font15w700.copyWith(color: mainColor),
                              ),
                              SizedBox(height: 5),
                              Text(
                                DateFormatUtilsSecond.formatDay(
                                    data.createdAt!.toDate()),
                                style: font14w400,
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
          ],
        ),
      ),
    );
  }
}
