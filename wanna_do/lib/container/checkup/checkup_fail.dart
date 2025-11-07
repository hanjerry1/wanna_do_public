import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/controller/page/main_page_controller.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/model/checkup/checkup_log_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class CheckupFail extends StatefulWidget {
  final String docId;
  final String uid;
  final String goal;
  final String category;
  final int betPoint;

  const CheckupFail({
    super.key,
    required this.docId,
    required this.category,
    required this.uid,
    required this.goal,
    required this.betPoint,
  });

  @override
  State<CheckupFail> createState() => _CheckupFailState();
}

class _CheckupFailState extends State<CheckupFail> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController textEditingController = TextEditingController();
  DateTime internetTime = DateTime.now();
  FocusNode focusNode = FocusNode();
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

  Future<void> sendLoseChallenge() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
        return;
      }

      setState(() {
        isLoading = true;
      });

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('checkup')
          .where('docId', isEqualTo: widget.docId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 1));
        }));
        ErrorGetxToast.show(context, '이미 처리된 챌린지에요', '다른 챌린지를 검사해주세요');
        return;
      }

      String checkupDocId = querySnapshot.docs.first.id;

      DocumentReference checkupRef =
          FirebaseFirestore.instance.collection('checkup').doc(checkupDocId);

      Map<String, dynamic> updateData = {
        'checker': authUid,
        'checkAt': Timestamp.fromDate(internetTime),
        'checkingState': 'checked',
        'status': 'lose',
        'failReason': textEditingController.text,
      };

      Map<String, dynamic> originalData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      ChallengeModel newData = ChallengeModel.fromJson({
        ...originalData,
        ...updateData,
      });

      DocumentReference checkupLogRef = FirebaseFirestore.instance
          .collection('log')
          .doc('checkupLog')
          .collection('checkupLog')
          .doc();

      CheckupRecordModel checkupRecordModel = CheckupRecordModel(
        thatDocId: widget.docId,
        uid: widget.uid,
        goal: widget.goal,
        category: widget.category,
        status: 'lose',
        pointState: 'wait',
        betPoint: widget.betPoint,
      );

      DocumentReference checkupRecordRef = FirebaseFirestore.instance
          .collection('checkupRecord')
          .doc(authUid)
          .collection('checkupRecord')
          .doc(widget.docId);

      DocumentReference challengeRef = FirebaseFirestore.instance
          .collection('challenge')
          .doc(widget.uid)
          .collection('challenge')
          .doc(widget.docId);

      DocumentReference statisticRef =
          FirebaseFirestore.instance.collection('statistic').doc(authUid);

      QuerySnapshot requestQueueSnapshot =
          await checkupRef.collection('requestQueue').get();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(checkupLogRef, newData.toJson());
        transaction.set(checkupRecordRef, checkupRecordModel.toJson());
        transaction.set(challengeRef, newData.toJson());
        transaction.update(statisticRef, {
          'totalCheckup': FieldValue.increment(1),
          'monthCheckup': FieldValue.increment(1),
        });

        for (var doc in requestQueueSnapshot.docs) {
          transaction.delete(doc.reference);
        }
        transaction.delete(checkupRef);
      }).then((result) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 1));
        }));
        InfoGetxToast.show(context, '실패 처리 완료', '언제나 꼼꼼하고 세심하게 봐주셔서 감사해요');
      }).catchError((e) {
        setState(() {
          isLoading = false;
        });
        ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> getInternetDateTimeDio() async {
    var dio = Dio();
    var url = 'https://worldtimeapi.org/api/timezone/Asia/Seoul';
    try {
      var response = await dio.get(url);
      String dateTime = response.data['datetime'];
      DateTime now = DateTime.parse(dateTime);
      setState(() {
        internetTime = now.toLocal();
      });
    } catch (e) {
      setState(() {
        internetTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: KeyboardVisibilityBuilder(
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
                                          padding: const EdgeInsets.all(4.0),
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
                                      SizedBox(height: 10),
                                      Text(
                                        '실패라고 판단한 이유를 알려주세요',
                                        style: font20w700,
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        '부적절한 판정은 규정 위반에 해당하니\n신중히 판단해주세요',
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
                                          hintText: exFailReasonHintText(
                                            widget.category,
                                          ),
                                          counterText:
                                              '${textEditingController.text.length}/200',
                                        ),
                                        maxLength: 200,
                                        maxLines: 6,
                                        keyboardType: TextInputType.multiline,
                                      ),
                                    ),
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
                                buttonText: '실패로 판정하기',
                                onPressed: () async {
                                  await sendLoseChallenge();
                                },
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
      ),
    );
  }
}
