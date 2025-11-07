import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/setting/setting_delete.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class SettingDeleteContact extends StatefulWidget {
  const SettingDeleteContact({super.key});

  @override
  State<SettingDeleteContact> createState() => _SettingDeleteContactState();
}

class _SettingDeleteContactState extends State<SettingDeleteContact> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

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
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          appBar: SubAppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => SettingDelete(),
                    );
                  },
                  child: Text(
                    '넘어가기',
                    style: font15w400,
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
                                      '탈퇴 이유가 무엇인가요?',
                                      style: font23w800,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '탈퇴를 원하는 이유를 알려주세요',
                                      style: font20w700,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      '개선할 점이 있다면 고치도록 노력할게요',
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
                                        hintText: '',
                                        counterText:
                                            '${textEditingController.text.length}/1000',
                                      ),
                                      maxLength: 1000,
                                      maxLines: 5,
                                      keyboardType: TextInputType.multiline,
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
                        buttonText: '다음',
                        onPressed: () async {
                          Get.to(
                            () => SettingDelete(
                              content: textEditingController.text,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
