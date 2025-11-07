import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/component/challenges_page_view.dart';
import 'package:wanna_do/container/challenge/challenges_only_pay.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengesHome extends StatefulWidget {
  const ChallengesHome({super.key});

  @override
  State<ChallengesHome> createState() => _ChallengesHomeState();
}

class _ChallengesHomeState extends State<ChallengesHome> {
  int challengeListLength = 0;

  @override
  void initState() {
    super.initState();
    initLoadChallengeList();
  }

  @override
  void dispose() {
    clearPreferences();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> initLoadChallengeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int totalChallengeList = prefs.getInt('totalChallengeList') ?? 0;
    List<Map<String, dynamic>> allData = [];

    for (int i = 1; i <= totalChallengeList; i++) {
      String? jsonString = prefs.getString('ChallengeList$i');
      if (jsonString != null) {
        Map<String, dynamic> data = json.decode(jsonString);
        allData.add(data);
      }
    }
    challengeListLength = allData.length;
    setState(() {});
    return allData;
  }

  Future<List<Map<String, dynamic>>> loadChallengeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int totalChallengeList = prefs.getInt('totalChallengeList') ?? 0;
    List<Map<String, dynamic>> allData = [];

    for (int i = 1; i <= totalChallengeList; i++) {
      String? jsonString = prefs.getString('ChallengeList$i');
      if (jsonString != null) {
        Map<String, dynamic> data = json.decode(jsonString);
        allData.add(data);
      }
    }
    challengeListLength = allData.length;
    return allData;
  }

  // 특정 리스트 하나 삭제. 그리고 그 빈자리를 뒷번호인 리스트가 채우는 과정임.
  // 더 효율적인 데이터 관리 방법이 있다면 나중에 그걸로 대체필요.
  Future<void> removeChallengeList(int index) async {
    final prefs = await SharedPreferences.getInstance();
    int totalChallengeList = prefs.getInt('totalChallengeList') ?? 0;

    prefs.remove('ChallengeList$index');

    // 리스트를 모두 조회하고 삭제한 리스트 뒤에 있던것들 중, null이 아닌 것들(삭제안된 리스트들)만 뽑아 리스트키 이름을 순차적으로 변경.
    for (int i = index + 1; i <= totalChallengeList; i++) {
      String? jsonString = prefs.getString('ChallengeList$i');
      if (jsonString != null) {
        Map<String, dynamic> challengeData = json.decode(jsonString);

        String newListKey = 'ChallengeList${i - 1}';
        challengeData['listKey'] = newListKey;

        String updatedJsonString = json.encode(challengeData);
        prefs.setString('ChallengeList${i - 1}', updatedJsonString);
      }
    }

    prefs.setInt('totalChallengeList', totalChallengeList - 1);
    challengeListLength = totalChallengeList - 1;
    setState(() {});
  }

  void clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Column(
                  children: [
                    SizedBox(height: 10),
                    Container(
                      width: 55,
                      height: 55,
                      child: SvgPicture.asset(
                        'asset/svg/challenges_plus.svg',
                        color: mainColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '여러 챌린지를 한번에 작성하고 \n등록할 수 있어요',
                      style: font23w800.copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    GestureDetector(
                      onTap: () async {
                        if (challengeListLength >= 10) {
                          ErrorGetxToast.show(
                              context, '한번에 10개까지만 가능해요', '더이상 챌린지를 추가할 수 없어요');
                        } else {
                          var result = await Get.to(() => ChallengesPageView());

                          if (result == 'updateState') {
                            await loadChallengeList();
                            setState(() {});
                          }
                        }
                      },
                      child: Container(
                        width: 200,
                        height: 60,
                        decoration: BoxDecoration(
                          color: greyColor.withOpacity(0.2),
                          border: Border.all(
                            width: 2,
                            color: greyColor.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 30,
                              color: Colors.black.withOpacity(0.4),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '챌린지 추가하기',
                              style: font20w700.copyWith(
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ScrollConfiguration(
                      behavior: NoGlowScrollBehavior(),
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: loadChallengeList(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Lottie.asset(
                                  'asset/lottie/short_loading_first_animation.json',
                                  height: 100,
                                ),
                              );
                            }

                            if (snapshot.data!.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'asset/lottie/wanna_do_checker_animation.json',
                                      height: 200,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '버튼을 눌러 챌린지를 추가해주세요',
                                      style: font16w700,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                var challenge = snapshot.data![index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await removeChallengeList(index + 1);
                                        },
                                        child: Container(
                                          height: 22,
                                          width: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                redColorLight.withOpacity(0.5),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 18,
                                              color: redColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        width: 55,
                                        height: 55,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            CategoryIconAssetUtils.getIcon(
                                              challenge['category'],
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: CategoryBackgroundColorUtils
                                              .getColor(
                                            challenge['category'],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              challenge['goal'],
                                              style: font15w700,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              DateFormatUtilsThird.formatDay(
                                                DateTime.parse(
                                                    challenge['selectedDate']),
                                              ),
                                              style: font13w400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          var result = await Get.to(
                                            ChallengesPageView(
                                              editListKey: challenge['listKey'],
                                              editGoal: challenge['goal'],
                                            ),
                                          );

                                          if (result == 'updateState') {
                                            await loadChallengeList();
                                            setState(() {});
                                          }
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.black.withOpacity(0.2),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(
                                  thickness: 0.3,
                                );
                              },
                            );
                          }),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          if (challengeListLength != 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: BigButtonFirst(
                buttonText: '${challengeListLength}개 챌린지 모두 등록하기',
                onPressed: () {
                  Get.to(() => ChallengesOnlyPay());
                },
              ),
            ),
        ],
      ),
    );
  }
}
