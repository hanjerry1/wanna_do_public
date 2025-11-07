import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/user/direct_message_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';

class UserDirectMessage extends StatefulWidget {
  final String uid;

  UserDirectMessage({
    super.key,
    required this.uid,
  });

  @override
  State<UserDirectMessage> createState() => _UserDirectMessageState();
}

class _UserDirectMessageState extends State<UserDirectMessage> {
  TextEditingController textEditingController1 =
      TextEditingController(text: '문의사항 답변');
  TextEditingController textEditingController2 =
      TextEditingController(text: '내용을 입력하세요');
  bool isLoading = false;
  int? selectedButtonIndex;
  final List<String> buttonTexts = [
    '체크업1업뎃',
    '체크업2업뎃',
    '체크업3업뎃',
    '스페이스1업뎃',
    '스페이스2업뎃',
    '스페이스3업뎃',
    '체크업 초기화',
    '스페이스 초기화',
    '명예의 전당 선정',
  ];

  String buttonTitle(int index) {
    switch (index) {
      case 0:
        return '체크업 규정위반 1회 경고';
      case 1:
        return '체크업 규정위반 2회 경고';
      case 2:
        return '체크업 이용 제한';
      case 3:
        return '스페이스 1회 경고';
      case 4:
        return '스페이스 2회 경고';
      case 5:
        return '스페이스 이용 제한';
      case 6:
        return '체크업 이용 제한 해제';
      case 7:
        return '스페이스 이용 제한 해제';
      case 8:
        return '명예의 전당 선정';
      default:
        return '';
    }
  }

  String buttonContent(int index) {
    switch (index) {
      case 0:
        return '부정확한 판정이 확인되어 경고 조치가 되었음을 알려드려요. 경고 3회일 경우, 체크업 이용이 제한되니 체크업 활동에서 규정을 확인하고 꼭 준수해주세요.';
      case 1:
        return '부정확한 판정이 확인되어 경고 조치가 되었음을 알려드려요. 경고 3회일 경우, 체크업 이용이 제한되니 체크업 활동에서 규정을 확인하고 꼭 준수해주세요.';
      case 2:
        return '부정확한 판정으로 경고 3회를 받아 회원님의 체크업 이용이 제한되었어요.';
      case 3:
        return '커뮤니티에서 부적절한 활동이 확인되어 경고 조치가 되었음을 알려드려요. 경고 3회일 경우, 스페이스 이용이 제한되니 스페이스 활동에서 규정을 확인하고 꼭 준수해주세요.';
      case 4:
        return '커뮤니티에서 부적절한 활동이 확인되어 경고 조치가 되었음을 알려드려요. 경고 3회일 경우, 스페이스 이용이 제한되니 스페이스 활동에서 규정을 확인하고 꼭 준수해주세요.';
      case 5:
        return '커뮤니티에서 부적절한 활동으로 경고 3회를 받아 회원님의 스페이스 이용이 제한되었어요.';
      case 6:
        return '회원님을 한번 믿고 체크업 제한을 임시로 풀어 드렸지만 부적절한 판정이 다시 확인되면 영구적으로 이용이 제한돼요. 반드시 체크업 활동에서 규정을 정독하고 이용해주세요.';
      case 7:
        return '회원님을 한번 믿고 스페이스 제한을 임시로 풀어 드렸지만 부적절한 활동이 다시 확인되면 영구적으로 이용이 제한돼요. 반드시 스페이스 활동에서 규정을 정독하고 이용해주세요.';
      case 8:
        return '지난달 명예의 전당에 회원님이 선정되어 월말 랭킹 상금이 지급되었어요. 몇 등 인지 궁금하다면 지금 명예의 전당에서 바로 확인해보세요!';
      default:
        return '';
    }
  }

  Future<void> sendMessage() async {
    try {
      setState(() {
        isLoading = true;
      });

      DirectMessageModel directMessageModel = DirectMessageModel(
        title: textEditingController1.text,
        content: textEditingController2.text,
        status: 'none',
      );

      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .collection('directMessage')
          .add(directMessageModel.toJson());
      setState(() {
        isLoading = false;
      });
      InfoGetxToast.show(context, '개인 공지 완료', '공지가 전송 되었어요');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: SubAppBar(),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: '제목',
                            ),
                            controller: textEditingController1,
                          ),
                        ),
                        SizedBox(width: 10),
                        SmallButtonFirst(
                          onPressed: () {
                            Get.dialog(
                              DialogTwoButton(
                                title: '🔥 ${textEditingController1.text}',
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '안녕하세요 회원님!',
                                      style: font15w700,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      textEditingController2.text,
                                      style: font15w700,
                                    ),
                                  ],
                                ),
                                leftText: '취소',
                                rightText: '확인하고 전송',
                                onLeftButtonPressed: () {
                                  Get.back();
                                },
                                onRightButtonPressed: () async {
                                  Get.back();
                                  await sendMessage();
                                },
                              ),
                            );
                          },
                          backgroundColor: mainColor,
                          content: Text(
                            '전송하기',
                            style: font13w400.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: textEditingController2,
                      decoration: InputDecoration(labelText: '내용'),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: List.generate(9, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    FocusScope.of(context).unfocus();
                                    textEditingController1.text =
                                        buttonTitle(index);
                                    textEditingController2.text =
                                        buttonContent(index);
                                  });
                                },
                                child: StateButtonFirst(
                                  widgetText: buttonTexts[index],
                                  isSelected: selectedButtonIndex == index,
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Column(
                      children: [
                        Text('1. 개인 공지 기록'),
                        SizedBox(height: 10),
                        FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('user')
                                .doc(widget.uid)
                                .collection('directMessage')
                                .orderBy('createdAt', descending: true)
                                .limit(20)
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: Lottie.asset(
                                    'asset/lottie/short_loading_first_animation.json',
                                    height: 100,
                                  ),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: Lottie.asset(
                                    'asset/lottie/short_loading_first_animation.json',
                                    height: 100,
                                  ),
                                );
                              }
                              List<DocumentSnapshot> docTotalList = [];

                              for (var doc in snapshot.data!.docs) {
                                docTotalList.add(doc);
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  DocumentSnapshot documentSnapshot =
                                      docTotalList[index];

                                  DirectMessageModel data =
                                      DirectMessageModel.fromJson(
                                    documentSnapshot.data()
                                        as Map<String, dynamic>,
                                  );

                                  return GestureDetector(
                                    onTap: () {
                                      Get.dialog(
                                        DialogTwoButton(
                                          title: '🔥 ${data.title}',
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '안녕하세요 회원님!',
                                                style: font15w700,
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                data.content,
                                                style: font15w700,
                                              ),
                                            ],
                                          ),
                                          leftText: '취소',
                                          rightText: '확인하고 닫기',
                                          onLeftButtonPressed: () {
                                            Get.back();
                                          },
                                          onRightButtonPressed: () async {
                                            Get.back();
                                          },
                                        ),
                                        barrierDismissible: false,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data.title,
                                                  style: font15w700,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  data.content,
                                                  style: font15w700,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  data.status,
                                                  style: font15w700,
                                                ),
                                                Text(
                                                  data.createdAt!
                                                      .toDate()
                                                      .toString(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(Icons.chevron_right),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Divider(
                                    thickness: 0.3,
                                  );
                                },
                                itemCount: docTotalList.length,
                              );
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) ShortLoadingFirst(),
        ],
      ),
    );
  }
}
