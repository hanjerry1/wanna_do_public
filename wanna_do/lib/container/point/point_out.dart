import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/point/point_account.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class PointOut extends StatefulWidget {
  final int point;

  const PointOut({
    super.key,
    required this.point,
  });

  @override
  State<PointOut> createState() => _PointOutState();
}

class _PointOutState extends State<PointOut> {
  final TextEditingController textEditingController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey();
  final FocusNode focusNode = FocusNode();

  int? selectedButtonIndex;
  final List<String> buttonTexts = [
    '적립금 전부',
    '적립금 50%',
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
          resizeToAvoidBottomInset: false,
          appBar: SubAppBar(),
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
                                      '얼마를 출금할까요?',
                                      style: font23w800,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '출금 금액을 설정해주세요',
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
                                      int? point = int.tryParse(val);
                                      if (point == null) {
                                        return '';
                                      }
                                      if (point > widget.point) {
                                        return '잔액을 확인해주세요';
                                      }
                                      if (point == 0 || point % 1000 != 0) {
                                        return '천 단위 이상만 가능해요';
                                      }
                                      if (point > 1000000) {
                                        return '100만원 이하로 출금 가능해요';
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
                                    maxLength: 7,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: greyColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      '적립금 잔액 ${widget.point}원',
                                      style: font13w400,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Wrap(
                                      spacing: 5,
                                      runSpacing: 5,
                                      children: List.generate(2, (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              FocusScope.of(context).unfocus();

                                              if (index == 0) {
                                                textEditingController.text =
                                                    widget.point.toString();
                                              } else if (index == 1) {
                                                textEditingController.text =
                                                    (widget.point.toDouble() *
                                                            0.5)
                                                        .toInt()
                                                        .toString();
                                              }
                                            });
                                          },
                                          child: StateButtonFirst(
                                            widgetText: buttonTexts[index],
                                            isSelected:
                                                selectedButtonIndex == index,
                                          ),
                                        );
                                      }),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: BigButtonFirst(
                    buttonText: '다음',
                    onPressed: () {
                      if (formkey.currentState == null) {
                        return;
                      }
                      if (formkey.currentState!.validate()) {
                        formkey.currentState!.save();
                        Get.to(
                          () => PointAccount(
                            outPoint: int.parse(textEditingController.text),
                          ),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
