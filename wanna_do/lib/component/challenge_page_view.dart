import 'package:flutter/material.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/challenge/challenge_bet_4.dart';
import 'package:wanna_do/container/challenge/challenge_deadline_3.dart';
import 'package:wanna_do/container/challenge/challenge_goal_2.dart';
import 'package:wanna_do/container/challenge/challenge_pay_5.dart';
import 'package:wanna_do/container/challenge/challenge_category_1.dart';

class ChallengePageView extends StatefulWidget {
  const ChallengePageView({super.key});

  @override
  State<ChallengePageView> createState() => _ChallengePageViewState();
}

class _ChallengePageViewState extends State<ChallengePageView> {
  final PageController pageController = PageController();
  DateTime selectedDate = DateTime.now();
  String category = '';
  String goal = '';
  String betPoint = '';
  int currentPage = 0;
  int progress = 1;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
        progress = currentPage;
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
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 2),
              if (currentPage == 0 || currentPage == 4 || currentPage == 5)
                SizedBox(height: 4),
              if (currentPage != 0 && currentPage != 4 && currentPage != 5)
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 4,
                      color: greyColor,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * (progress / 3),
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [subColor, mainColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ],
                ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ChallengeCategory1(
                      onNextStudy: (inputCategory) {
                        setState(() {
                          category = inputCategory;
                        });
                        pageController.jumpToPage(currentPage + 1);
                      },
                      onNextLife: (inputCategory) {
                        setState(() {
                          category = inputCategory;
                        });
                        pageController.jumpToPage(currentPage + 1);
                      },
                      onNextRoutine: (inputCategory) {
                        setState(() {
                          category = inputCategory;
                        });
                        pageController.jumpToPage(currentPage + 1);
                      },
                      onNextOther: (inputCategory) {
                        setState(() {
                          category = inputCategory;
                        });
                        pageController.jumpToPage(currentPage + 1);
                      },
                    ),
                    ChallengeGoal2(
                      initGoal: goal,
                      category: category,
                      onNext: (inputGoal) {
                        setState(() {
                          goal = inputGoal;
                        });
                        animateToPage();
                      },
                      onBack: () {
                        FocusScope.of(context).unfocus();
                        Future.delayed(Duration(milliseconds: 200), () {
                          pageController.jumpToPage(currentPage - 1);
                        });
                      },
                    ),
                    ChallengeDeadline3(
                      category: category,
                      goal: goal,
                      onNext: (inputSelectedDate) {
                        setState(() {
                          selectedDate = inputSelectedDate;
                        });
                        animateToPage();
                      },
                      onBack: () {
                        Future.delayed(Duration(milliseconds: 200), () {
                          pageController.jumpToPage(currentPage - 1);
                        });
                      },
                    ),
                    ChallengeBet4(
                      category: category,
                      goal: goal,
                      selectedDate: selectedDate,
                      onNext: (inputBetPoint) {
                        setState(() {
                          betPoint = inputBetPoint;
                        });
                        animateToPage();
                      },
                      onBack: () {
                        FocusScope.of(context).unfocus();
                        Future.delayed(Duration(milliseconds: 200), () {
                          pageController.jumpToPage(currentPage - 1);
                        });
                      },
                    ),
                    ChallengePay5(
                      category: category,
                      goal: goal,
                      selectedDate: selectedDate,
                      betPoint: betPoint,
                      onBack: () {
                        Future.delayed(Duration(milliseconds: 200), () {
                          pageController.jumpToPage(currentPage - 1);
                        });
                      },
                      onFix: () {
                        pageController.jumpToPage(1);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
