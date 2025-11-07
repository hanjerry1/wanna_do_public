import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:wanna_do/component/start_login.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/service/contact_model.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;

class SettingDelete extends StatefulWidget {
  final String? content;

  SettingDelete({
    super.key,
    this.content,
  });

  @override
  State<SettingDelete> createState() => _SettingDeleteState();
}

class _SettingDeleteState extends State<SettingDelete> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;
  bool isCheck = false;

  Future<void> deleteAll() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (widget.content != null) {
        ContactModel contactModel = ContactModel(
          uid: authUid,
          content: '탈퇴이유: ${widget.content}',
          status: 'none',
        );

        await FirebaseFirestore.instance
            .collection('report')
            .doc('contact')
            .collection('contact')
            .add(contactModel.toJson());
      }

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(authUid)
          .get();

      UserModel data = UserModel.fromJson(
        documentSnapshot.data() as Map<String, dynamic>,
      );

      await callDeleteUserAccount();

      if (data.whereLogin == 'kakao') {
        await kakao.UserApi.instance.unlink();
      }

      Get.offAll(
        () => StartLogin(),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> callDeleteUserAccount() async {
    await FirebaseFunctions.instanceFor(region: 'asia-northeast3')
        .httpsCallable('deleteUserAccount')
        .call(<String, dynamic>{
      'uid': authUid,
      'secretKey': dotenv.env['CLOUD_FUNCTIONS_SECRET_KEY'] ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: SubAppBar(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    '탈퇴한 이후에는 \n다음의 데이터를 복구할 수 없어요',
                                    style: font20w800.copyWith(height: 1.5),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '*탈퇴후 3개월간 동일 계정으로 재가입 할 수 없어요',
                                    style: font14w400.copyWith(
                                      color: redColor,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Text(
                                    '-  나의 챌린지 기록이 전부 사라져요.',
                                    style: font15w700.copyWith(height: 1.5),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    '-  내가 체크업에서 활동한 모든 기록이 삭제돼요.',
                                    style: font15w700.copyWith(height: 1.5),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    '-  그동안 쌓아왔던 적립금과 적립금 내역은 전부 사라져요.',
                                    style: font15w700.copyWith(height: 1.5),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    '-  공용 데이터(게시글, 댓글 등)을 제외한 워너두에서 활동한 모든 기록은 사라져요.',
                                    style: font15w700.copyWith(height: 1.5),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    '-  워너두의 다양한 혜택과 상금을 받을 기회가 사라져요.',
                                    style: font15w700.copyWith(height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isCheck = !isCheck;
                      });
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          'asset/img/check_mini2.png',
                          color: isCheck ? mainColor : greyColor,
                          height: 17,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '다음 사항을 전부 숙지하고 탈퇴할게요',
                          style: font17w700.copyWith(
                            color: isCheck ? mainColor : charcoalColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: BigButtonFirst(
                    buttonText: '탈퇴하기',
                    onPressed: !isCheck
                        ? null
                        : () async {
                            await deleteAll();
                          },
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) ShortLoadingFirst(opacity: 0.1),
        ],
      ),
    );
  }
}
