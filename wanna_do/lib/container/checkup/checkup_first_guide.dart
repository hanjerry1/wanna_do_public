import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/help/agreement_home.dart';
import 'package:wanna_do/container/help/role_home.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:webview_flutter/webview_flutter.dart';

final homeUrl1 = Uri.parse(
    'https://marvelous-cantaloupe-01b.notion.site/82dde54db7de4131ab4328fc33fb56be?pvs=4');

class CheckupFirstGuide extends StatefulWidget {
  const CheckupFirstGuide({super.key});

  @override
  State<CheckupFirstGuide> createState() => _CheckupFirstGuideState();
}

class _CheckupFirstGuideState extends State<CheckupFirstGuide> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final PageController pageController = PageController();
  WebViewController controller1 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl1);
  bool isLoading = false;
  bool isCheck = false;
  int currentPage = 0;
  List<int> selectedCheckIndexs = [];
  final List<String> checkTexts = [
    '[필수] 워너두 이용약관 동의',
    '[필수] 개인정보 수집이용 동의',
    '[필수] 체크업 이용규정 동의',
  ];

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void animateToPage() {
    pageController.animateToPage(
      currentPage + 1,
      duration: Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  Future<void> agreeCheckupAgreement() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
      return;
    }

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference agreementRef = FirebaseFirestore.instance
          .collection('user')
          .doc(authUid)
          .collection('agreement')
          .doc(authUid);

      transaction.update(agreementRef, {
        'termsConditions': true,
        'privacyPolicy': true,
      });
    }).then((result) {
      if (mounted) {
        Get.back(result: false);
      }
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentPage > 0) {
          pageController.jumpToPage(currentPage - 1);
          return false;
        }
        return true;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: SubAppBar(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PageView(
                    controller: pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Center(
                              child: Lottie.asset(
                                'asset/lottie/checkup_first_guide_animation.json',
                                height: 300,
                              ),
                            ),
                            Text(
                              '체크업에 오신걸 환영해요!',
                              style: font23w800,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '체크업에 대해 잠깐 알아볼까요?',
                              style: font20w700,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              '🔥 체크업은 다른 사람의 챌린지를 \n내가 검사해주는 공간이에요',
                              style: font20w800.copyWith(
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              '목표 달성에 실패했다면 \n내기금액 25%를 적립금으로 받을 수 있어요',
                              style: font17w700.copyWith(
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: Image.asset(
                                'asset/img/iphone_checkup_first_guide.png',
                                height: 450,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              '🔥 체크업에는 검사 규칙이 있어요',
                              style: font20w800.copyWith(
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              '아래는 체크업 규정을 요약한 내용이에요',
                              style: font17w700.copyWith(
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              '1. 성공 기준에 맞게 판정하기',
                              style: font18w800.copyWith(
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '챌린지 목표에 성공 기준이 적혀있다면 해당 기준대로 판정해주어야 해요. '
                              '만약 성공 기준이 없다면 검사자님의 판단에 맡기지만 너그럽게 판정해주세요. 목표 달성 여부를 선생님께 검사받는다고 생각해주시면 돼요.',
                              style: font14w700,
                            ),
                            SizedBox(height: 20),
                            Text(
                              '2. 너그럽게 판정하기',
                              style: font18w800.copyWith(
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '"수학 문제 1-10P 풀고 영상찍기"처럼 구체적인 성공 기준이 없는 경우, 인증 영상에 페이지 번호가 잘 보이진 않지만 '
                              '누가봐도 총 10 페이지를 풀었다고 생각할 수 있으면 성공이라 해야해요.',
                              style: font14w700,
                            ),
                            SizedBox(height: 20),
                            Text(
                              '3. 실패 여부를 정확히 판정하기',
                              style: font18w800.copyWith(
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '너그러운 판정과 정확한 판정은 한끝 차이에요. "수학 문제 1-10P 풀고 영상찍기"라도 '
                              '인증 영상에 누가봐도 총 9 페이지만 있다면 실패라고 할 수 있어요.',
                              style: font14w700,
                            ),
                            SizedBox(height: 20),
                            Text(
                              '4. 판정이 확실한 챌린지만 검사하기',
                              style: font18w800.copyWith(
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '성공 기준을 애매하게 작성하여 헷갈리는 경우 혹은 SNS링크가 잘못되어 있거나 '
                              'SNS에서 해당 게시물을 쉽게 찾을 수 없는 경우라도 실패처리 하지 말고 워너두에게 넘겨주세요.',
                              style: font14w700,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '아래 규정을 반드시 정독해주세요',
                              style: font20w800.copyWith(
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: WebViewWidget(
                                controller: controller1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isCheck = !isCheck;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'asset/img/check_mini2.png',
                                      color: isCheck ? mainColor : greyColor,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '규정을 잘 확인하지 않고 부적절한 판정을 할 경우 이용이 제한됨에 동의할게요',
                                        style: font15w700.copyWith(
                                          color: isCheck
                                              ? mainColor
                                              : charcoalColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              '🔥 체크업에서 판정할 때 \n이 3가지를 기억해주세요',
                              style: font20w800.copyWith(
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: Lottie.asset(
                                'asset/lottie/wanna_do_checker_animation.json',
                                width: 250,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              '1. 숙제 검사 해주는 선생님이라 생각하기',
                              style: font18w800.copyWith(
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '2. 너그럽게 판정하기',
                              style: font18w800.copyWith(
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '3. 판정이 확실한 챌린지만 검사하기',
                              style: font18w800.copyWith(
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 40),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: greyColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        3,
                                        (index) {
                                          return Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (selectedCheckIndexs
                                                              .contains(
                                                                  index)) {
                                                            selectedCheckIndexs
                                                                .remove(index);
                                                          } else {
                                                            selectedCheckIndexs
                                                                .add(index);
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        color: greyColor
                                                            .withOpacity(0.0),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      8.0),
                                                          child: Row(
                                                            children: [
                                                              Image.asset(
                                                                'asset/img/check_mini2.png',
                                                                color: selectedCheckIndexs
                                                                        .contains(
                                                                            index)
                                                                    ? mainColor
                                                                    : greyColor,
                                                                height: 17,
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                checkTexts[
                                                                    index],
                                                                style:
                                                                    font15w700,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (index == 0 ||
                                                          index == 1) {
                                                        Get.to(() =>
                                                            AgreementHome());
                                                      } else if (index == 2) {
                                                        Get.to(
                                                            () => RoleHome());
                                                      }
                                                    },
                                                    child: Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      size: 30,
                                                      color: Colors.black
                                                          .withOpacity(0.4),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Image.asset(
                                    'asset/img/guide.png',
                                    height: 17,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '최초 1회 판정을 하면 이 가이드는 더이상 나오지 않아요',
                                      style: font13w400.copyWith(
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: BigButtonFirst(
                    buttonText: currentPage == 4 ? '동의하고 시작하기' : '다음',
                    onPressed: currentPage == 3 && !isCheck
                        ? null
                        : () async {
                            if (currentPage == 4) {
                              setState(() {
                                selectedCheckIndexs.add(0);
                              });
                              await Future.delayed(Duration(milliseconds: 50));
                              setState(() {
                                selectedCheckIndexs.add(1);
                              });
                              await Future.delayed(Duration(milliseconds: 100));
                              setState(() {
                                selectedCheckIndexs.add(2);
                                isLoading = true;
                              });
                              await agreeCheckupAgreement();
                            } else {
                              animateToPage();
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) ShortLoadingFirst(),
        ],
      ),
    );
  }
}
