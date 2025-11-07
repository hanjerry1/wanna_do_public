import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/service/contact_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ContactHome extends StatefulWidget {
  const ContactHome({super.key});

  @override
  State<ContactHome> createState() => _ContactHomeState();
}

class _ContactHomeState extends State<ContactHome> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(updateState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  void updateState() {
    setState(() {});
  }

  Future<void> sendEmail() async {
    final Email email = Email(
      body: '',
      subject: '[Wanna Do 이용 문의]'
          '\n문의자: $authUid'
          '\n\n회원님이 기다리지 않도록 신속하게 답변하려고 노력하고 있어요!'
          '\n다만, 불쾌감을 주는 표현을 사용하거나 반복적이고 무분별한 문의는 답변하지 않으니 유의해주세요.',
      recipients: ['climbers.hst@gmail.com'],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      ErrorGetxToast.show(context, '해당 기기는 이메일을 지원하지 않아요', '아래 문의하기를 이용해주세요');
    }
  }

  Future<void> sendContact() async {
    try {
      setState(() {
        isLoading = true;
      });

      ContactModel contactModel = ContactModel(
        uid: authUid,
        content: textEditingController.text,
        status: 'none',
      );

      await FirebaseFirestore.instance
          .collection('report')
          .doc('contact')
          .collection('contact')
          .add(contactModel.toJson());

      Get.back();
      InfoGetxToast.show(context, '문의 전송 완료', '소중한 의견은 한글자도 놓치지 않고 읽어볼게요');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                resizeToAvoidBottomInset: true,
                appBar: SubAppBar(
                  actions: [
                    GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          await sendEmail();
                        } else if (Platform.isIOS) {
                          ErrorGetxToast.show(context, '아이폰은 메일 문의를 지원하지 않아요',
                              'climbers.hst@gmail.com으로 직접 보내거나 아래 문의하기를 이용해주세요');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          '메일 문의',
                          style: font14w400.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: NoGlowScrollBehavior(),
                        child: SingleChildScrollView(
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Image.asset(
                                                'asset/img/write.png',
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            '무엇을 문의할까요?',
                                            style: font23w800,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            '문의 사항을 구체적으로 적어주세요',
                                            style: font20w700,
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            '불편한 점이 있다면 의견을 주셔도 좋아요',
                                            style: font15w700.copyWith(
                                              color: mainColor,
                                              height: 1.5,
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
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: greyColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                                  '일주일이 지나도 챌린지 검사가 완료되지 않아요 \n\n이런 부분은 조금만 개선했으면 좋겠어요',
                                              counterText:
                                                  '${textEditingController.text.length}/1000',
                                            ),
                                            maxLength: 1000,
                                            maxLines: 5,
                                            keyboardType:
                                                TextInputType.multiline,
                                          ),
                                        ),
                                      ),
                                    ),
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
                              buttonText: '전송하기',
                              onPressed: () async {
                                await sendContact();
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isLoading) ShortLoadingFirst(),
            ],
          ),
        );
      },
    );
  }
}
