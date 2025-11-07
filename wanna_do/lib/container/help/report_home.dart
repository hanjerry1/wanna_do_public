import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/report/report_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ReportHome extends StatefulWidget {
  final String? title;
  final String? content;
  final String? chat;
  final String? goal;
  final String? category;
  final String? postId;
  final String? chatId;
  final String? docId;
  final String? uid;
  final String? status;
  final String? thumbNailUrl;
  final int? betPoint;
  final bool? isVideo;
  final bool? isVisible;
  final List<String>? certifyUrl;
  final DateTime? deadline;
  final DateTime? postAt;
  final DateTime? certifyAt;
  final DateTime? applyAt;

  const ReportHome({
    super.key,
    this.title,
    this.content,
    this.chatId,
    this.goal,
    this.category,
    this.postId,
    this.chat,
    this.docId,
    this.uid,
    this.status,
    this.thumbNailUrl,
    this.betPoint,
    this.isVideo,
    this.isVisible,
    this.certifyUrl,
    this.deadline,
    this.postAt,
    this.certifyAt,
    this.applyAt,
  });

  @override
  State<ReportHome> createState() => _ReportHomeState();
}

// 삼성 키보드 입력문제 찾음. 쥽,븁,븉 등의 이상한 1단어 입력하면 빈칸생김.
class _ReportHomeState extends State<ReportHome> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController textEditingController = TextEditingController();
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

  Future<void> sendReport() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (widget.category != null) {
        ReportModel reportModel = ReportModel(
          reporterUid: authUid,
          reportedUid: widget.uid!,
          reportReason: textEditingController.text,
          category: widget.category!,
          goal: widget.goal!,
          status: widget.status!,
          docId: widget.docId,
          isVisible: widget.isVisible!,
          betPoint: widget.betPoint!,
          deadline: Timestamp.fromDate(widget.deadline!),
          certifyAt: Timestamp.fromDate(widget.certifyAt!),
          applyAt: Timestamp.fromDate(widget.applyAt!),
        );

        await FirebaseFirestore.instance
            .collection('report')
            .doc('reportCheckup')
            .collection('reportCheckup')
            .add(reportModel.toJson());
      } else {
        ReportModel reportModel = ReportModel(
          chatId: widget.chatId,
          postId: widget.postId,
          reporterUid: authUid,
          reportedUid: widget.uid!,
          reportReason: textEditingController.text,
          postAt: Timestamp.fromDate(widget.postAt!),
          title: widget.title,
          content: widget.content,
          chat: widget.chat,
        );

        await FirebaseFirestore.instance
            .collection('report')
            .doc('reportSpace')
            .collection('reportSpace')
            .add(reportModel.toJson());
      }

      Get.back();
      InfoGetxToast.show(context, '게시물 신고 완료', '우리 함께 건전한 문화를 만들어가요!');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
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
                                            '해당 내용을 신고할까요?',
                                            style: font23w800,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            '신고를 하는 이유를 알려주세요',
                                            style: font20w700,
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            '적절하지 않은 내용일 경우 바로 신고해주세요',
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
                                              BorderRadius.circular(20),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: TextField(
                                            focusNode: focusNode,
                                            controller: textEditingController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintStyle: font14w400,
                                              hintText:
                                                  '욕설 및 불쾌감을 주는 내용이 포함되어 있음',
                                              counterText:
                                                  '${textEditingController.text.length}/200',
                                            ),
                                            onChanged: (String? val) {
                                              setState(() {});
                                            },
                                            maxLength: 200,
                                            maxLines: 5,
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
                                buttonText: '신고 접수하기',
                                onPressed: () async {
                                  await sendReport();
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
