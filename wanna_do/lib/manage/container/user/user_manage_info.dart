import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';

class UserManageInfo extends StatelessWidget {
  final String uid;

  const UserManageInfo({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('user').doc(uid).get(),
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

            UserModel data = UserModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    '유저정보',
                    style: font23w800,
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        'uid: ${data.uid}\n'
                        'email: ${data.email}\n'
                        '이름: ${data.name}\n'
                        '닉네임: ${data.nickname}\n'
                        '전화번호: ${data.phone}\n'
                        '생년월일: ${data.birth}\n'
                        '성별: ${data.gender}\n'
                        'device: ${data.deviceId}\n'
                        'fcmToken: ${data.fcmToken}\n\n\n'
                        '로그인 날짜: ${data.loginAt!.toDate().toString()}\n'
                        '가입 날짜: ${data.createdAt!.toDate().toString()}\n',
                        style: font18w400.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
