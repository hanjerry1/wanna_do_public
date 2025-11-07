import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/component/manage_main_page.dart';
import 'package:wanna_do/manage/container/user/user_manage.dart';
import 'package:wanna_do/model/point/point_log_model.dart';
import 'package:wanna_do/model/point/point_out_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';

class PointDetail extends StatefulWidget {
  final String docId;
  DocumentSnapshot challengeSnapshot;

  PointDetail({
    super.key,
    required this.challengeSnapshot,
    required this.docId,
  });

  @override
  State<PointDetail> createState() => _PointDetailState();
}

class _PointDetailState extends State<PointDetail> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    PointOutModel data = PointOutModel.fromJson(
      widget.challengeSnapshot.data() as Map<String, dynamic>,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'uid: ${data.uid}',
                ),
                SizedBox(height: 30),
                Text(
                  '출금요청금액: ${data.point}',
                ),
                SizedBox(height: 10),
                Text(
                  '예금주: ${data.name}',
                ),
                SizedBox(height: 10),
                Text(
                  '은행: ${data.bank}',
                ),
                SizedBox(height: 10),
                Text(
                  '계좌번호: ${data.account}',
                ),
              ],
            ),
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
              '요청자 정보 확인하기',
              style: font15w700.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: MediumButtonSecond(
                    buttonText: '출금 처리완료',
                    onPressed: () async {
                      try {
                        setState(() {
                          isLoading = true;
                        });

                        await FirebaseFirestore.instance
                            .collection('service')
                            .doc('pointOut')
                            .collection('pointOut')
                            .doc(widget.docId)
                            .update({
                          'isFinish': true,
                        });

                        Get.offAll(
                          () => ManageMainPage(
                            currentIndex: 2,
                          ),
                        );
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    backgroundColor: mainColorLight,
                    textColor: mainColor,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: MediumButtonSecond(
                    buttonText: '출금 거절',
                    onPressed: () async {
                      try {
                        setState(() {
                          isLoading = true;
                        });

                        WriteBatch batch = FirebaseFirestore.instance.batch();

                        DocumentReference serviceRef = FirebaseFirestore
                            .instance
                            .collection('service')
                            .doc('pointOut')
                            .collection('pointOut')
                            .doc(widget.docId);
                        batch.update(serviceRef, {
                          'isFinish': true,
                        });

                        PointLogModel pointLogModel = PointLogModel(
                          uid: data.uid,
                          inout: 'in',
                          pointFrom: 'outReject',
                          point: data.point,
                        );

                        DocumentReference pointRef = FirebaseFirestore.instance
                            .collection('point')
                            .doc(data.uid);
                        batch.update(pointRef, {
                          'point': FieldValue.increment(data.point),
                        });

                        DocumentReference pointLogRef = FirebaseFirestore
                            .instance
                            .collection('point')
                            .doc(data.uid)
                            .collection('pointLog')
                            .doc();

                        batch.set(pointLogRef, pointLogModel.toJson());

                        DocumentReference statisticRef = FirebaseFirestore
                            .instance
                            .collection('statistic')
                            .doc(data.uid);
                        batch.update(statisticRef, {'monthPointOutTicket': 1});

                        await batch.commit();

                        Get.offAll(
                          () => ManageMainPage(
                            currentIndex: 2,
                          ),
                        );
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    backgroundColor: redColorLight,
                    textColor: redColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
