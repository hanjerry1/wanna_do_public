import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/controller/page/challenge_controller.dart';
import 'package:wanna_do/model/challenge/challenge_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/list_item_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class Event {
  String title;
  Event(this.title);
}

class MyChallengeHome extends StatefulWidget {
  const MyChallengeHome({super.key});

  @override
  State<MyChallengeHome> createState() => _MyChallengeHomeState();
}

class _MyChallengeHomeState extends State<MyChallengeHome> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final ChallengeController controller = Get.find<ChallengeController>();
  StreamSubscription<QuerySnapshot>? subscription;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  int selectedButtonIndex = 0;
  Map<DateTime, List<Event>> events = {};
  List<DocumentSnapshot> applyChallengeList = [];
  final List<String> buttonStatusTexts = [
    '전체',
    '인증전',
    '검사진행중',
    '성공',
    '실패',
  ];

  @override
  void initState() {
    super.initState();
    getApplyChallengeListEvent();
    controller.updateSelectedDates(selectedDay);
  }

  void addEventList() {
    Map<DateTime, List<Event>> tempEvents = {};

    for (var challenge in applyChallengeList) {
      DateTime deadline = challenge.get('deadline').toDate();
      DateTime dateKey =
          DateTime.utc(deadline.year, deadline.month, deadline.day);

      if (deadline.hour == 0) {
        dateKey = DateTime.utc(deadline.year, deadline.month, deadline.day - 1);
        if (tempEvents.containsKey(dateKey)) {
          tempEvents[dateKey]!.add(Event('title'));
        } else {
          tempEvents[dateKey] = [Event('title')];
        }
      } else {
        if (tempEvents.containsKey(dateKey)) {
          tempEvents[dateKey]!.add(Event('title'));
        } else {
          tempEvents[dateKey] = [Event('title')];
        }
      }
    }
    setState(() {
      events = tempEvents;
    });
  }

  Future<void> getApplyChallengeListEvent() async {
    Query query = FirebaseFirestore.instance
        .collection('challenge')
        .doc(authUid)
        .collection('challenge')
        .where('status', isEqualTo: 'apply');

    subscription = query.snapshots().listen((snapshot) {
      List<DocumentSnapshot> filteredList = [];

      for (var doc in snapshot.docs) {
        filteredList.add(doc);
      }

      if (mounted) {
        setState(() {
          applyChallengeList = filteredList;
        });
        addEventList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        title: 'My 챌린지',
      ),
      body: Column(
        children: [
          ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: TableCalendar(
              focusedDay: focusedDay,
              firstDay: DateTime(2023),
              lastDay: DateTime.now().add(
                Duration(days: 60),
              ),
              locale: 'ko_KR',
              daysOfWeekHeight: 20,
              onDaySelected: (DateTime selected, DateTime focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = selected;
                });
                controller.updateSelectedDates(selected);
              },
              selectedDayPredicate: (DateTime date) {
                return date.year == selectedDay.year &&
                    date.month == selectedDay.month &&
                    date.day == selectedDay.day;
              },
              eventLoader: (DateTime day) {
                DateTime dateKey = DateTime.utc(day.year, day.month, day.day);
                return events[dateKey] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                singleMarkerBuilder: (context, date, event) {
                  return Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orangeColor,
                    ),
                  );
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: mainColor,
                    width: 1.5,
                  ),
                ),
                todayTextStyle: font14w400,
                selectedDecoration: BoxDecoration(
                  color: mainColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: font14w800.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 40,
            color: mainColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    DateFormatUtilsFirst.formatDay(selectedDay),
                    style: font17w700.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            controller.changeSelectedIndexMyChallenge(index);
                          },
                          child: Obx(
                            () => StateButtonFirst(
                              widgetText: buttonStatusTexts[index],
                              isSelected: controller
                                      .selectedButtonIndexMyChallenge.value ==
                                  index,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: Obx(
                      () {
                        final docStreamList =
                            controller.docStreamMyChallengeList;
                        if (docStreamList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'asset/lottie/wanna_do_checker_animation.json',
                                  height: 150,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '아직 여기에는 챌린지 기록이 없어요',
                                  style: font15w400,
                                ),
                              ],
                            ),
                          );
                        }

                        return ScrollConfiguration(
                          behavior: NoGlowScrollBehavior(),
                          child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot challengeSnapshot =
                                  docStreamList[index];

                              ChallengeModel data = ChallengeModel.fromJson(
                                challengeSnapshot.data()
                                    as Map<String, dynamic>,
                              );

                              return MainListTimeItem(
                                goal: data.goal,
                                time: DateFormatUtilsFourth.formatDay(
                                    data.deadline.toDate()),
                                status: data.status,
                                category: data.category,
                                deadline: data.deadline.toDate(),
                                betPoint: data.betPoint,
                                docId: data.docId,
                                certifyAt: data.certifyAt?.toDate(),
                                certifyUrl: data.certifyUrl,
                                thumbNailUrl: data.thumbNailUrl,
                                checkAt: data.checkAt?.toDate(),
                                checker: data.checker,
                                complainReason: data.complainReason,
                                failReason: data.failReason,
                                isVideo: data.isVideo,
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(
                                thickness: 0.3,
                              );
                            },
                            itemCount: docStreamList.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
