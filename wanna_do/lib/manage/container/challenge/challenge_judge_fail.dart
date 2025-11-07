import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/manage/container/challenge/challenge_judge_manage.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengeJudgeFail extends StatefulWidget {
  final String docId;
  final String uid;
  final String goal;
  final String category;
  final int betPoint;

  const ChallengeJudgeFail({
    super.key,
    required this.docId,
    required this.uid,
    required this.goal,
    required this.category,
    required this.betPoint,
  });

  @override
  State<ChallengeJudgeFail> createState() => _ChallengeJudgeFailState();
}

class _ChallengeJudgeFailState extends State<ChallengeJudgeFail> {
  FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();
  bool isLoading = false;

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

  Future<void> callCheckupToChallengeAndDeleteFunction(
      String checkupDocId) async {
    try {
      final result =
          await FirebaseFunctions.instanceFor(region: 'asia-northeast3')
              .httpsCallable('checkupToChallengeAndDelete')
              .call(<String, dynamic>{
        'checkupDocId': checkupDocId,
      });
      print(result.data);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                resizeToAvoidBottomInset: true,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Image.asset(
                                                'asset/img/write.png',
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            '무엇이 잘못됐나요?',
                                            style: font23w800,
                                          ),
                                          SizedBox(height: 15),
                                          Text(
                                            '실패라고 판단한 이유를 알려주세요',
                                            style: font20w700,
                                          ),
                                          SizedBox(height: 25),
                                          Text(
                                            '적절하지 않은 판정은 규정 위반에 해당하니\n꼼꼼히 판단해주세요',
                                            style: font15w700.copyWith(
                                              color: mainColor,
                                              height: 1.3,
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
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: greyColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: TextField(
                                            focusNode: focusNode,
                                            controller: textEditingController,
                                            onChanged: (String? val) {
                                              setState(() {});
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintStyle: font14w400,
                                              hintText: exFailReasonHintText(
                                                widget.category,
                                              ),
                                              counterText:
                                                  '${textEditingController.text.length}/100',
                                            ),
                                            maxLength: 100,
                                            maxLines: 7,
                                            keyboardType:
                                                TextInputType.multiline,
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
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: BigButtonFirst(
                                buttonText: '실패로 판정하기',
                                onPressed: () async {
                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    WriteBatch batch =
                                        FirebaseFirestore.instance.batch();

                                    QuerySnapshot querySnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('checkup')
                                            .where('docId',
                                                isEqualTo: widget.docId)
                                            .get();

                                    if (querySnapshot.docs.isEmpty) {
                                      Get.offAll(() => ChallengeJudgeManage());
                                      ErrorGetxToast.show(context,
                                          '챌린지가 존재하지 않아요', '다른 챌린지를 검사해주세요');
                                      return;
                                    }

                                    String checkupDocId =
                                        querySnapshot.docs.first.id;

                                    DocumentReference checkupRef =
                                        FirebaseFirestore.instance
                                            .collection('checkup')
                                            .doc(checkupDocId);

                                    Map<String, dynamic> updateData = {
                                      'checker': 'Wanna Do 관리자',
                                      'checkAt':
                                          Timestamp.fromDate(DateTime.now()),
                                      'checkingState': 'checked',
                                      'status': 'lose',
                                      'failReason': textEditingController.text,
                                    };

                                    Map<String, dynamic> originalData =
                                        querySnapshot.docs.first.data()
                                            as Map<String, dynamic>;

                                    ChallengeModel newData =
                                        ChallengeModel.fromJson({
                                      ...originalData,
                                      ...updateData,
                                    });

                                    DocumentReference challengeRef =
                                        FirebaseFirestore.instance
                                            .collection('challenge')
                                            .doc(widget.uid)
                                            .collection('challenge')
                                            .doc(widget.docId);

                                    batch.update(checkupRef, updateData);
                                    batch.set(challengeRef, newData.toJson());

                                    QuerySnapshot requestQueueSnapshot =
                                        await checkupRef
                                            .collection('requestQueue')
                                            .get();
                                    for (var doc in requestQueueSnapshot.docs) {
                                      batch.delete(doc.reference);
                                    }
                                    batch.delete(checkupRef);
                                    await batch.commit();

                                    Get.offAll(() => ChallengeJudgeManage());
                                  } catch (e) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    ErrorGetxToast.show(context, '네트워크를 확인해주세요',
                                        '오류가 계속되면 MY탭에서 문의해주세요');
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isLoading) ShortLoadingFirst(),
            ],
          ),
        );
      },
    );
  }
}
