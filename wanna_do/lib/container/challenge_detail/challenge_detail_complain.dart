import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengeDetailComPlain extends StatefulWidget {
  final String docId;
  final String status;
  final String checker;

  const ChallengeDetailComPlain({
    super.key,
    required this.docId,
    required this.checker,
    required this.status,
  });

  @override
  State<ChallengeDetailComPlain> createState() =>
      _ChallengeDetailComPlainState();
}

class _ChallengeDetailComPlainState extends State<ChallengeDetailComPlain> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(updateState);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void updateState() {
    setState(() {});
  }

  Future<void> sendComplain() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
        return;
      }

      setState(() {
        isLoading = true;
      });

      String deviceId = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
        deviceId = iosInfo.identifierForVendor!;
      }

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(authUid)
          .get();

      UserModel data = UserModel.fromJson(
        documentSnapshot.data() as Map<String, dynamic>,
      );

      if (data.deviceId != deviceId) {
        Get.offAll(() => MainPage());
        ErrorGetxToast.show(context, '앱을 재시작 해주세요', '앱에서 하나의 기기만 사용해주세요');
        return;
      }

      DocumentReference challengeRef = FirebaseFirestore.instance
          .collection('challenge')
          .doc(authUid)
          .collection('challenge')
          .doc(widget.docId);

      DocumentSnapshot challengeSnapshot = await FirebaseFirestore.instance
          .collection('challenge')
          .doc(authUid)
          .collection('challenge')
          .doc(widget.docId)
          .get();

      if (widget.status == 'win') {
        Map<String, dynamic> updateData = {
          'complainReason': textEditingController.text,
        };

        Map<String, dynamic> originalData =
            challengeSnapshot.data() as Map<String, dynamic>;

        ChallengeModel newData = ChallengeModel.fromJson({
          ...originalData,
          ...updateData,
        });

        DocumentReference challengeComplainRef = FirebaseFirestore.instance
            .collection('service')
            .doc('challengeComplain')
            .collection('challengeComplain')
            .doc();

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(challengeRef, newData.toJson());
          transaction.set(challengeComplainRef, newData.toJson());
        }).then((result) {
          Get.offAll(() => MainPage());
          InfoGetxToast.show(context, '성공 이의제기 완료', '판정에 도움을 주셔서 감사해요');
        }).catchError((e) {
          setState(() {
            isLoading = false;
          });
          ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
        });
      } else if (widget.status == 'lose') {
        Map<String, dynamic> updateData = {
          'complainReason': textEditingController.text,
          'status': 'complain',
          'pointState': 'complain',
        };

        Map<String, dynamic> originalData =
            challengeSnapshot.data() as Map<String, dynamic>;

        ChallengeModel newData = ChallengeModel.fromJson({
          ...originalData,
          ...updateData,
        });

        DocumentReference challengeComplainRef = FirebaseFirestore.instance
            .collection('service')
            .doc('challengeComplain')
            .collection('challengeComplain')
            .doc();

        DocumentReference checkupRecordRef = FirebaseFirestore.instance
            .collection('checkupRecord')
            .doc(widget.checker)
            .collection('checkupRecord')
            .doc(widget.docId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(challengeRef, newData.toJson());
          transaction.set(challengeComplainRef, newData.toJson());

          if (widget.checker != 'Wanna Do 관리자') {
            transaction.update(checkupRecordRef, {
              'pointState': 'complain',
            });
          }
        }).then((result) {
          Get.offAll(() => MainPage());
          InfoGetxToast.show(context, '실패 이의제기 완료', '문제가 있다면 바로 재판정 해드릴게요');
        }).catchError((e) {
          setState(() {
            isLoading = false;
          });
          ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                resizeToAvoidBottomInset: true,
                appBar: SubAppBar(
                  onBackButtonPressed: () {
                    FocusScope.of(context).unfocus();
                    Future.delayed(Duration(milliseconds: 200), () {
                      Get.back();
                    });
                  },
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: NoGlowScrollBehavior(),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.asset(
                                          'asset/img/write.png',
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      '무엇이 잘못되었나요?',
                                      style: font23w800,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '잘못되었다고 생각한 이유를 알려주세요',
                                      style: font20w700,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      '단, 무분별한 이의제기는 규정위반 사유가 돼요',
                                      style: font15w700.copyWith(
                                        color: mainColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: greyColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: TextField(
                                      focusNode: focusNode,
                                      controller: textEditingController,
                                      onChanged: (String? val) {
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: font14w400,
                                        hintText:
                                            '목표대로 수학문제를 20P까지 풀고 정확히 인증했는데 실패로 판정했어요\n\n'
                                            '판정이 어려울정도로 안보이진 않은데도 실패로 판정했어요\n\n',
                                        counterText:
                                            '${textEditingController.text.length}/200',
                                      ),
                                      maxLength: 200,
                                      maxLines: 5,
                                      keyboardType: TextInputType.multiline,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 30),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'asset/img/guide.png',
                                          height: 20,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '실패인데 성공으로 처리됐다면?',
                                          style: font15w700.copyWith(
                                            color:
                                                Colors.black.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '내가 봐도 실패한 챌린지인데 검사자가 성공으로 판정했다면 편하게 알려주세요.\n'
                                      '그렇다고 판정이 변하진 않아요. 나에게 솔직한 모습은 정말 좋은 일이니까요.',
                                      style: font15w400.copyWith(
                                        height: 1.5,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (textEditingController.text.isNotEmpty)
                      AnimatedOpacity(
                        opacity: isKeyboardVisible ? 0.0 : 1.0,
                        duration: Duration(milliseconds: 1000),
                        child: Visibility(
                          visible: !isKeyboardVisible,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: BigButtonFirst(
                              buttonText: '제출',
                              onPressed: () async {
                                await sendComplain();
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (isLoading) ShortLoadingFirst(),
      ],
    );
  }
}
