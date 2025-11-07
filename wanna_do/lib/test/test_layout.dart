import 'package:flutter/material.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';

class TestLayout extends StatelessWidget {
  const TestLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SubAppBar(
          title: '디자인 테스트',
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 22.0),
                child: Text(
                  '설정',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /*
              SubButtonSmall(
                buttonText: '송금',
                onPressed: () {},
              ),
               */
              Column(
                children: [
                  Text(
                    'KB 나라사랑 우대통장',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: tossGreyFontColor,
                    ),
                  ),
                  Text(
                    '카테고리: 학습',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              /*
              MainButtonCouple(
                leftButtonText: '뒤로',
                rightButtonText: '확인',
                onPressedLeft: () {},
                onPressedRight: () {},
              ),

               */
              BigButtonFirst(
                buttonText: '다음',
                onPressed: () {
                  // 버튼 클릭 시 수행할 작업
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
