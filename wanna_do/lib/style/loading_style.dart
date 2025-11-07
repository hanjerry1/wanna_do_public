import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class LongLoadingFirst extends StatelessWidget {
  final String title;
  final String subTitle;

  const LongLoadingFirst({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 90),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: font23w800.copyWith(height: 1.5),
                  ),
                  SizedBox(height: 20),
                  Text(
                    subTitle,
                    style: font15w700.copyWith(color: mainColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Lottie.asset(
                  'asset/lottie/long_loading_first_animation.json',
                  height: 300,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'asset/svg/today_tip_icon.svg',
                        height: 20,
                        color: Colors.black.withOpacity(0.7),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '오늘의 팁',
                        style: font15w700.copyWith(
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    todayTipRandomText(),
                    style: font15w400.copyWith(
                      height: 1.5,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 10),

                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ShortLoadingFirst extends StatelessWidget {
  double? opacity;

  ShortLoadingFirst({
    super.key,
    this.opacity = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(opacity!),
        child: Center(
          child: Lottie.asset(
            'asset/lottie/short_loading_first_animation.json',
            height: 100,
          ),
        ),
      ),
    );
  }
}
