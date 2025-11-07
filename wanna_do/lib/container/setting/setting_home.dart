import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wanna_do/component/start_login.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/help/agreement_home.dart';
import 'package:wanna_do/container/help/company_home.dart';
import 'package:wanna_do/container/help/notice_home.dart';
import 'package:wanna_do/container/setting/setting_delete_contact.dart';
import 'package:wanna_do/container/setting/setting_push.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';

class SettingHome extends StatefulWidget {
  const SettingHome({super.key});

  @override
  State<SettingHome> createState() => _SettingHomeState();
}

class _SettingHomeState extends State<SettingHome> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    initPackageInfo();
  }

  Future<void> initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
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
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: '설정',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => SettingPush());
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '알림 설정',
                            style: font18w400,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => NoticeHome());
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '공지사항',
                            style: font18w400,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () async {
                      if (Platform.isAndroid) {
                        await sendEmail();
                      } else if (Platform.isIOS) {
                        ErrorGetxToast.show(context, '아이폰은 이메일 문의를 지원하지 않아요',
                            'MY 탭에서 문의하기를 이용해주세요');
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '이메일 문의',
                            style: font18w400,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => AgreementHome());
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '이용 약관 및 개인정보 처리방침',
                            style: font18w400,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Get.offAll(() => StartLogin());
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '로그아웃',
                            style: font18w400,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 10,
            color: greyColor.withOpacity(0.3),
          ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => CompanyHome());
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '워너두 소개',
                            style: font18w400,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => SettingDeleteContact());
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '탈퇴하기',
                            style: font18w400,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '앱 버전',
                          style: font18w400,
                        ),
                      ),
                      Text(
                        appVersion,
                        style: font16w700.copyWith(
                          color: charcoalColor,
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
