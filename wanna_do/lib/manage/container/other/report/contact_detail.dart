import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/container/user/user_manage.dart';
import 'package:wanna_do/model/service/contact_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';

class ContactDetail extends StatelessWidget {
  final DocumentSnapshot contactSnapshot;

  const ContactDetail({
    super.key,
    required this.contactSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    ContactModel data = ContactModel.fromJson(
      contactSnapshot.data() as Map<String, dynamic>,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: '문의사항',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '문의내용: ',
                              style: font17w700,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                data.content,
                                style: font17w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              '문의자: ',
                              style: font17w700,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                data.uid,
                                style: font17w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              '문의일: ',
                              style: font17w700,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                data.createdAt!.toDate().toString(),
                                style: font17w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
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
                      '문의자 유저 관리하기',
                      style: font15w700.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: MediumButtonSecond(
                    buttonText: '문의 확인하고 종료',
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('report')
                            .doc('contact')
                            .collection('contact')
                            .doc(contactSnapshot.id)
                            .update({
                          'status': 'checked',
                        });

                        Get.back();
                      } catch (e) {
                        ErrorGetxToast.show(
                            context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
                      }
                    },
                    backgroundColor: mainColorLight,
                    textColor: mainColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
