import 'package:easy_tooltip/easy_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengeCategory1 extends StatefulWidget {
  final Function(String) onNextStudy;
  final Function(String) onNextLife;
  final Function(String) onNextRoutine;
  final Function(String) onNextOther;

  ChallengeCategory1({
    super.key,
    required this.onNextStudy,
    required this.onNextLife,
    required this.onNextRoutine,
    required this.onNextOther,
  });

  @override
  State<ChallengeCategory1> createState() => _ChallengeCategory1State();
}

class _ChallengeCategory1State extends State<ChallengeCategory1> {
  double progress = 1;
  int currentPage = 0;
  int? selectedButtonIndexStudy;
  int? selectedButtonIndexLife;
  int? selectedButtonIndexRoutine;
  final List<String> buttonTextsStudy = [
    '문제풀기',
    '강의',
    '노트/계획',
    '시험점수',
    '학습기타',
  ];
  final List<String> buttonTextsLife = [
    '등산',
    '여행가기',
    '문서작성',
    '건강/헬스',
    '생활기타',
  ];
  final List<String> buttonTextsRoutine = [
    '기상/수면',
    '운동',
    '일기쓰기',
    '책읽기',
    '루틴기타',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SvgPicture.asset(
                                'asset/svg/my_challenge_recode.svg',
                                color: mainColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '목표 카테고리 선택',
                            style: font23w800,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '챌린지를 신청할 카테고리를 골라주세요',
                            style: font20w700,
                          ),
                          SizedBox(height: 20),
                          Text(
                            '크게 중요하진 않으니, 기타를 선택해도 좋아요',
                            style: font15w700.copyWith(
                              color: mainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '학습',
                            style: font18w700,
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Wrap(
                              spacing: 3,
                              runSpacing: 7,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    widget.onNextStudy(
                                      '학습(${buttonTextsStudy[index]})',
                                    );
                                  },
                                  child: StateButtonFirst(
                                    widgetText: buttonTextsStudy[index],
                                    isSelected:
                                        selectedButtonIndexStudy == index,
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '생활',
                            style: font18w700,
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Wrap(
                              spacing: 3,
                              runSpacing: 7,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    widget.onNextLife(
                                      '생활(${buttonTextsLife[index]})',
                                    );
                                  },
                                  child: StateButtonFirst(
                                    widgetText: buttonTextsLife[index],
                                    isSelected:
                                        selectedButtonIndexLife == index,
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                '루틴 (인증 여러번)',
                                style: font18w700,
                              ),
                              SizedBox(width: 5),
                              EasyTooltip(
                                bubbleWidth: 300,
                                backgroundColor: mainColor,
                                text: '"매일 7시 기상"처럼 인증이 매번 필요한 챌린지를 말해요. '
                                    '하지만 매번 인증할 필요는 없고 한번에 전부 올리면 돼요.',
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  color: greyColorDark,
                                ),
                                textStyle: font14w700.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Wrap(
                              spacing: 3,
                              runSpacing: 7,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    widget.onNextRoutine(
                                      '루틴(${buttonTextsRoutine[index]})',
                                    );
                                  },
                                  child: StateButtonFirst(
                                    widgetText: buttonTextsRoutine[index],
                                    isSelected:
                                        selectedButtonIndexRoutine == index,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: BigButtonFirst(
              buttonText: '여기에도 없다면 누르세요!',
              onPressed: () {
                widget.onNextOther('기타');
              },
              backgroundColor: mainColorLight,
              textColor: mainColor,
            ),
          ),
        ],
      ),
    );
  }
}
