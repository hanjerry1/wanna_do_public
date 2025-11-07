import 'package:easy_tooltip/easy_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ChallengeGoal2 extends StatefulWidget {
  final Function(String) onNext;
  final VoidCallback onBack;
  final String initGoal;
  final String category;

  const ChallengeGoal2({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.initGoal,
    required this.category,
  });

  @override
  State<ChallengeGoal2> createState() => _ChallengeGoal2State();
}

class _ChallengeGoal2State extends State<ChallengeGoal2> {
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initGoal != '') {
      textEditingController = TextEditingController(text: widget.initGoal);
    } else {
      textEditingController = TextEditingController();
    }

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
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            appBar: SubAppBar(
              onBackButtonPressed: widget.onBack,
              actions: [
                EasyTooltip(
                  bubbleWidth: 300,
                  backgroundColor: mainColor,
                  text: '내 인스타, 유튜브 링크를 목표에 같이 적으면 '
                      '링크 게시물로 인증 확인도 가능해요! \n(인스타는 태그에 "#워너두" 추가)',
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: orangeColor,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'SNS 인증?',
                            style: font15w800.copyWith(
                              color: orangeColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  textStyle: font14w700.copyWith(
                    color: Colors.white,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
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
                                  '무엇을 할까요?',
                                  style: font23w800,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '챌린지 목표를 자유롭게 적어주세요',
                                  style: font20w700,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  '어떻게 인증하면 성공인지도 꼭 알려주세요',
                                  style: font15w700.copyWith(
                                    color: mainColor,
                                  ),
                                ),
                                SizedBox(height: 10),
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
                                    hintStyle: font14w400.copyWith(
                                      color: charcoalColor,
                                    ),
                                    hintText: exGoalHintText(
                                      widget.category,
                                    ),
                                    counterText: '',
                                  ),
                                  maxLength: 200,
                                  maxLines: 7,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'asset/img/guide.png',
                                      height: 20,
                                      color: charcoalColor,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      '성공기준을 제시하지 않으면?',
                                      style: font15w700.copyWith(
                                        color: charcoalColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '정확한 성공기준을 제시하지 않으면 검사자의 판단에 맡겨야 해요.'
                                  ' 되도록이면 잘 적어놓는게 좋겠죠?',
                                  style: font15w400.copyWith(
                                    height: 1.5,
                                    color: charcoalColor.withOpacity(0.8),
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
                          SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ),
                // 텍스트가 입력되어 있을 경우 버튼을 생성하고, 디자인적인 어색함을 해결하기 위해 투명도를 조절함.
                // KeyboardVisibilityBuilder로 키보드 생성을 제어가능함. 여기는 필요없지만 나중에 쓸수도 있으니 적어둠.
                if (textEditingController.text.isNotEmpty)
                  AnimatedOpacity(
                    opacity: isKeyboardVisible ? 0.0 : 1.0,
                    duration: Duration(milliseconds: 1000),
                    child: Visibility(
                      visible: !isKeyboardVisible,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: BigButtonFirst(
                          buttonText: '다음',
                          onPressed: () {
                            widget.onNext(textEditingController.text);
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
    );
  }
}
