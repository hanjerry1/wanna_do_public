import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/text_style.dart';

class SpaceMyProfile extends StatefulWidget {
  final String nickname;

  const SpaceMyProfile({
    super.key,
    required this.nickname,
  });

  @override
  State<SpaceMyProfile> createState() => _SpaceMyProfileState();
}

class _SpaceMyProfileState extends State<SpaceMyProfile> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.nickname != '') {
      textEditingController = TextEditingController(text: widget.nickname);
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
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SubAppBar(
          title: '닉네임 수정',
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: textEditingController.text.isEmpty ||
                          textEditingController.text == widget.nickname
                      ? null
                      : () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          await FirebaseFirestore.instance
                              .collection('user')
                              .doc(authUid)
                              .update({'nickname': textEditingController.text});
                          Get.back();
                        },
                  child: Text(
                    '변경',
                    style: font18w800.copyWith(
                      color: textEditingController.text.isEmpty ||
                              textEditingController.text == widget.nickname
                          ? Colors.black.withOpacity(0.5)
                          : mainColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: '닉네임을 입력해주세요',
                  hintStyle: font15w700,
                  counterText: '',
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black.withOpacity(0.5)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                  ),
                ),
                onChanged: (String? val) {
                  setState(() {});
                },
                cursorColor: mainColor,
                maxLength: 10,
                maxLines: 1,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
