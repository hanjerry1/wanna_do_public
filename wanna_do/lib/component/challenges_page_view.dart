import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/challenge/challenge_bet_4.dart';
import 'package:wanna_do/container/challenge/challenge_deadline_3.dart';
import 'package:wanna_do/container/challenge/challenge_goal_2.dart';
import 'package:wanna_do/container/challenge/challenge_category_1.dart';

class ChallengesPageView extends StatefulWidget {
  final String? editListKey;
  final String? editGoal;

  ChallengesPageView({
    super.key,
    this.editListKey,
    this.editGoal,
  });

  @override
  State<ChallengesPageView> createState() => _ChallengesPageViewState();
}

class _ChallengesPageViewState extends State<ChallengesPageView> {
  final PageController pageController = PageController();
  String category = '';
  String goal = '';
  DateTime selectedDate = DateTime.now();
  String betPoint = '';
  int currentPage = 0;
  int progress = 1;

  @override
  void initState() {
    super.initState();
    if (widget.editGoal != null) {
      setState(() {
        goal = widget.editGoal!;
      });
    }
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

  Future<void> saveChallengeList(String category, String goal,
      DateTime selectedDate, String betPoint) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int totalChallengeList =
        prefs.getInt('totalChallengeList') ?? 0; // 실시간 리스트 총 개수

    String newListKey = 'ChallengeList${totalChallengeList + 1}';

    Map<String, dynamic> challengeData = {
      'listKey': newListKey,
      'category': category,
      'goal': goal,
      'selectedDate': selectedDate.toIso8601String(),
      'betPoint': betPoint,
    };

    String challengeJson = json.encode(challengeData);

    await prefs.setString(newListKey, challengeJson);
    await prefs.setInt('totalChallengeList', totalChallengeList + 1);
  }

  Future<void> editChallengeList(String category, String goal,
      DateTime selectedDate, String betPoint) async {
    Map<String, dynamic> challengeData = {
      'listKey': widget.editListKey,
      'category': category,
      'goal': goal,
      'selectedDate': selectedDate.toIso8601String(),
      'betPoint': betPoint,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? newListKey = widget.editListKey;
    String challengeJson = json.encode(challengeData);

    await prefs.setString(newListKey!, challengeJson);
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
              if (currentPage == 0) SizedBox(height: 4),
              if (currentPage != 0)
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
                      onNext: (inputBetPoint) async {
                        setState(() {
                          betPoint = inputBetPoint;
                        });
          
                        if (widget.editListKey != null) {
                          await editChallengeList(
                            category,
                            goal,
                            selectedDate,
                            betPoint,
                          );
                        } else {
                          await saveChallengeList(
                            category,
                            goal,
                            selectedDate,
                            betPoint,
                          );
                        }
                        Get.back(result: 'updateState');
                      },
                      onBack: () {
                        FocusScope.of(context).unfocus();
                        Future.delayed(Duration(milliseconds: 200), () {
                          pageController.jumpToPage(currentPage - 1);
                        });
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
