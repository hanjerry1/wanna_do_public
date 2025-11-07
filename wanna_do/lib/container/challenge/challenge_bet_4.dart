import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengeBet4 extends StatefulWidget {
  final Function(String) onNext;
  final VoidCallback onBack;
  final String category;
  final String goal;
  final DateTime selectedDate;

  const ChallengeBet4({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.category,
    required this.goal,
    required this.selectedDate,
  });

  @override
  State<ChallengeBet4> createState() => _ChallengeBet4State();
}

class _ChallengeBet4State extends State<ChallengeBet4> {
  final TextEditingController textEditingController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey();
  final FocusNode focusNode = FocusNode();
  int? selectedButtonIndex;
  final List<String> buttonTexts = [
    '5000',
    '10000',
    '30000',
    '50000',
    '100000',
    '500000',
    '1000000',
  ];

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          appBar: SubAppBar(
            onBackButtonPressed: widget.onBack,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.asset(
                                          'asset/img/money.png',
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      '얼마를 걸까요?',
                                      style: font23w800,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '내기 금액을 설정해주세요',
                                      style: font20w700,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Form(
                                  key: formkey,
                                  autovalidateMode: AutovalidateMode.always,
                                  child: TextFormField(
                                    focusNode: focusNode,
                                    controller: textEditingController,
                                    onChanged: (String? val) {
                                      setState(() {});
                                    },
                                    validator: (String? val) {
                                      if (val == null || val.isEmpty) {
                                        return '';
                                      }
                                      int? betPoint = int.tryParse(val);
                                      if (betPoint == null) {
                                        return '';
                                      }

                                      if (betPoint <= 0) {
                                        return '';
                                      }

                                      if (betPoint > 100000000) {
                                        return '억 단위는 너무 크지 않아요?';
                                      }
                                      if (betPoint == 0 ||
                                          betPoint % 1000 != 0) {
                                        return '천 단위 이상만 가능해요';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintStyle:
                                          font37w700.copyWith(color: greyColor),
                                      hintText: '직접 입력하기',
                                      suffixText: '원',
                                      suffixStyle: font37w800,
                                      counterText: '',
                                    ),
                                    style: font37w800,
                                    cursorColor: mainColor,
                                    cursorWidth: 4,
                                    maxLines: 1,
                                    maxLength: 9,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: List.generate(7, (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          FocusScope.of(context).unfocus();
                                          textEditingController.text =
                                              buttonTexts[index].toString();
                                        });
                                      },
                                      child: StateButtonFirst(
                                        widgetText:
                                            NumberFormat('#,###').format(
                                          int.parse(buttonTexts[index]),
                                        ),
                                        isSelected:
                                            selectedButtonIndex == index,
                                      ),
                                    );
                                  }),
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
              AnimatedOpacity(
                opacity: isKeyboardVisible ? 0.0 : 1.0,
                duration: Duration(milliseconds: 1000),
                child: Visibility(
                  visible: !isKeyboardVisible,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'asset/img/circle_number_one.png',
                              width: 20,
                              color: mainColor.withOpacity(0.1),
                            ),
                            SizedBox(width: 5),
                            Text(
                              widget.category,
                              style: font15w700.copyWith(
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Image.asset(
                              'asset/img/circle_number_two.png',
                              width: 20,
                              color: mainColor.withOpacity(0.1),
                            ),
                            SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                widget.goal,
                                style: font15w700.copyWith(
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Image.asset(
                              'asset/img/circle_number_three.png',
                              width: 20,
                              color: mainColor.withOpacity(0.1),
                            ),
                            SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                DateFormatUtilsThird.formatDay(
                                  widget.selectedDate,
                                ),
                                style: font15w700.copyWith(
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25),
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
                        buttonText: '끝났어요!',
                        onPressed: () {
                          if (formkey.currentState == null) {
                            return;
                          }
                          if (formkey.currentState!.validate()) {
                            formkey.currentState!.save();
                            widget.onNext(textEditingController.text);
                          }
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
