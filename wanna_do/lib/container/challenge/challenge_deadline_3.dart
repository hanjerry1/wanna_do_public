import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengeDeadline3 extends StatefulWidget {
  final Function(DateTime) onNext;
  final VoidCallback onBack;
  final String category;
  final String goal;

  const ChallengeDeadline3({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.category,
    required this.goal,
  });

  @override
  State<ChallengeDeadline3> createState() => _ChallengeDeadline3State();
}

class _ChallengeDeadline3State extends State<ChallengeDeadline3> {
  DateTime currentDate = DateTime.now();
  double dateSliderValue = 0;
  double timeSliderValue = 24;

  @override
  void initState() {
    super.initState();
    getInternetDateTimeDio().then((internetTime) {
      setState(() {
        currentDate = internetTime;
      });
    }).catchError((error) {
      print(error);
    });
  }

  Future<DateTime> getInternetDateTimeDio() async {
    var dio = Dio();
    var url = 'https://worldtimeapi.org/api/timezone/Asia/Seoul';

    try {
      var response = await dio.get(url);
      String dateTime = response.data['datetime'];
      DateTime now = DateTime.parse(dateTime);
      return now.toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  String get selectedDateText {
    if (dateSliderValue == 0) return "오늘";
    return "${dateSliderValue.toInt()}일뒤";
  }

  String get selectedTimeText {
    int hour = timeSliderValue.toInt();
    if (hour == 0) return " 오전0시";
    if (hour < 12) return " 오전$hour시";
    if (hour == 12) return " 12시";
    if (hour == 24) return " 24시";
    return " 오후${hour - 12}시";
  }

  String get formattedDate {
    DateTime targetDate =
        currentDate.add(Duration(days: dateSliderValue.toInt()));
    String formatted = DateFormatUtilsFirst.formatDay(
      targetDate,
    );
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(
        onBackButtonPressed: widget.onBack,
      ),
      body: Column(
        children: [
          Expanded(
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                'asset/img/deadline.png',
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '언제까지 할까요?',
                            style: font23w800,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '이때까지 인증하지 않으면 실패에요',
                            style: font20w700,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Container(
                            width: 90,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Center(
                                child: Text(
                                  '${formattedDate}',
                                  style: font13w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            '${selectedDateText}${selectedTimeText} 까지',
                            style: font37w800.copyWith(color: mainColor),
                          ),
                          SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '오늘',
                                style: font13w700.copyWith(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                              Text(
                                '30일',
                                style: font13w700.copyWith(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SliderTheme(
                        data: SliderThemeData(
                          tickMarkShape: RoundSliderTickMarkShape(
                            tickMarkRadius: 10.0,
                          ),
                          trackHeight: 8.0,
                        ),
                        child: Slider(
                          value: dateSliderValue,
                          onChanged: (newValue) {
                            setState(() {
                              dateSliderValue = newValue;
                            });
                          },
                          min: 0,
                          max: 30,
                          divisions: 30,
                          activeColor: mainColor.withOpacity(0.7),
                          inactiveColor: mainColorLight,
                          thumbColor: mainColor.withOpacity(0.9),
                        ),
                      ),
                    ),
                    SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '0시',
                                style: font13w700.copyWith(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                              Text(
                                '24시',
                                style: font13w700.copyWith(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SliderTheme(
                        data: SliderThemeData(
                          tickMarkShape: RoundSliderTickMarkShape(
                            tickMarkRadius: 10.0,
                          ),
                          trackHeight: 8.0,
                        ),
                        child: Slider(
                          value: timeSliderValue,
                          onChanged: (newValue) {
                            setState(() {
                              timeSliderValue = newValue;
                            });
                          },
                          min: 0,
                          max: 24,
                          divisions: 24,
                          activeColor: mainColor.withOpacity(0.7),
                          inactiveColor: mainColorLight,
                          thumbColor: mainColor.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'asset/img/circle_number_one.png',
                      width: 20,
                      color: mainColor.withOpacity(0.1),
                    ),
                    SizedBox(width: 5),
                    Text(
                      widget.category,
                      style: font15w700.copyWith(
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(
                      'asset/img/circle_number_two.png',
                      width: 20,
                      color: mainColor.withOpacity(0.1),
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        widget.goal,
                        style: font15w700.copyWith(
                          color: Colors.black.withOpacity(0.1),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: BigButtonFirst(
              buttonText: '다음',
              onPressed: () {
                DateTime selectedDate = DateTime(
                  currentDate.year,
                  currentDate.month,
                  currentDate.day + dateSliderValue.toInt(),
                  timeSliderValue.toInt(),
                  0,
                  0,
                  0,
                  0,
                );

                if (selectedDate.isBefore(currentDate) ||
                    selectedDate.isAtSameMomentAs(currentDate)) {
                  ErrorGetxToast.show(
                      context, '마감시간 재선택', '현재 시간보다 늦은 시간을 선택해주세요');
                } else {
                  widget.onNext(selectedDate);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
