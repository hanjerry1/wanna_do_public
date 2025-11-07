import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';

class ChallengeEnd extends StatelessWidget {
  const ChallengeEnd({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: WillPopScope(
        onWillPop: () async {
          Get.off(() => MainPage());
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'asset/img/check.png',
                          height: 130,
                        ),
                        SizedBox(height: 50),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Wanna Do ',
                              style: fontAppLogo.copyWith(
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '챌린지 등록완료!',
                              style: font25w800,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: BigButtonFirst(
                buttonText: '확인',
                onPressed: () {
                  Get.off(() => MainPage());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
