import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wanna_do/const/example_context.dart';

import '../const/colors.dart';

// 스크롤 글로효과 제거
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

// 빠른 탭바 전환 애니메이션
class FastTabController extends TabController {
  FastTabController({required int length, required TickerProvider vsync})
      : super(length: length, vsync: vsync);

  @override
  Duration get animationDuration => const Duration(milliseconds: 5);
}

// 오늘의 팁 텍스트 랜덤 출력
String todayTipRandomText() {
  List<String> todayTips = [
    todayTip1,
    todayTip2,
    todayTip3,
    todayTip4,
    todayTip5,
    todayTip6,
    todayTip7,
  ];
  Random random = Random();
  return todayTips[random.nextInt(todayTips.length)];
}

class IsTextLink {
  static bool containLink(String text) {
    final urlPattern =
        RegExp(r'\b(?:https?|ftp):\/\/\S+|www\.\S+\b', caseSensitive: false);
    return urlPattern.hasMatch(text);
  }
}

// 날짜 형식 변환기 ex) 2023.9.26 > 9/26 (화)
class DateFormatUtilsFirst {
  static String formatDay(DateTime date) {
    return DateFormat("M/d (EEE)", 'ko_KR').format(date);
  }
}

// 날짜 형식 변환기 ex) 2023.9.26 > 9/26(화) 23:00
class DateFormatUtilsSecond {
  static String formatDay(DateTime date) {
    String formattedDate = DateFormat("M/d(EEE)", 'ko_KR').format(date);
    return "$formattedDate ${DateFormat("HH:mm").format(date)}";
  }
}

// 날짜 형식 변환기 ex) 2023.9.26 > 9/26(화) 오후 3시까지 or 9/26(화) 24시 까지
class DateFormatUtilsThird {
  static String formatDay(DateTime date) {
    String formattedDate = DateFormat("M/d(EEE)", 'ko_KR').format(date);
    String formattedDate24 = DateFormat("M/d(EEE)", 'ko_KR')
        .format(date.subtract(Duration(days: 1)));

    if (date.hour == 0 && date.minute == 0) {
      return "$formattedDate24 24시 까지";
    } else if (date.hour > 0 && date.hour < 12) {
      return "$formattedDate 오전 ${date.hour}시까지";
    } else if (date.hour >= 12 && date.hour <= 23) {
      int hourFor12HourClock = date.hour > 12 ? date.hour - 12 : date.hour;
      return "$formattedDate 오후 ${hourFor12HourClock}시까지";
    }
    return "$formattedDate ${DateFormat("HH").format(date)}시까지";
  }
}

// 시간 형식 변환기 ex) 2023.9.26 00:00 > 오후 3시까지 or 오늘 24시 까지
class DateFormatUtilsFourth {
  static String formatDay(DateTime date) {
    if (date.hour == 0 && date.minute == 0) {
      return "오늘 24시 까지";
    } else if (date.hour > 0 && date.hour < 12) {
      return "오전 ${date.hour}시까지";
    } else if (date.hour >= 12 && date.hour <= 23) {
      int hourFor12HourClock = date.hour > 12 ? date.hour - 12 : date.hour;
      return "오후 ${hourFor12HourClock}시까지";
    }
    return "${DateFormat("H").format(date)}시까지";
  }
}

// 날짜 형식 변환기 ex) 2023.9.26 00:00 > 1분전 or 1시간전
class DateFormatUtilsFifth {
  static String formatDay(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}

class DateFormatUtilsSixth {
  static String formatDay(DateTime date) {
    Duration diff = DateTime.now().difference(date);

    int yearDiff = DateTime.now().year - date.year;
    if (yearDiff > 0) {
      return '${yearDiff}년 전';
    }

    if (diff.inDays >= 1) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}시간 전';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

// 날짜 형식 변환기 ex) 2023.9.26 13:00 > 2023년 9월 26일 13시 00분
class DateFormatUtilsSeven {
  static String formatDay(DateTime date) {
    return DateFormat("yyyy년 M월 d일 HH시 mm분").format(date);
  }
}

// 날짜 월 출력 변환기 ex) 1월,2월,..,12월
class DateFormatUtilsEight {
  static String formatDay(DateTime date) {
    return DateFormat('MMMM', 'ko_KR').format(date);
  }
}

class DateFormatUtilsNine {
  static String formatDay(DateTime date) {
    return DateFormat('y년 M월', 'ko_KR').format(date);
  }
}

class TextFormatUtilsOne {
  static String formatText(String text) {
    if (text.length > 17) {
      return '${text.substring(0, 17)}...';
    } else {
      return text;
    }
  }
}

// 영문 챌린지 상태 한국말 번역기
String challengeStatusTranslate(String status) {
  switch (status) {
    case 'apply':
      return '인증전';
    case 'certify':
      return '검사진행중';
    case 'win':
      return '성공';
    case 'lose':
      return '실패';
    case 'complain':
      return '이의신청중';
    default:
      return '상태';
  }
}

// 챌린지 카테고리별 아이콘 배경색
class CategoryBackgroundColorUtils {
  static Color getColor(String category) {
    if (category.contains('학습')) {
      return Color(0xFFFFFFF);
    } else if (category.contains('생활')) {
      return Color(0xFFFFFFF);
    } else if (category.contains('루틴')) {
      return Color(0xFFFFFFF);
    } else {
      return Color(0xFFFFFFF);
    }
  }
}

// 챌린지 카테고리별 아이콘 이미지 주소
class CategoryIconAssetUtils {
  static String getIcon(String category) {
    if (category.contains('학습')) {
      return 'asset/img/category_study.png';
    } else if (category.contains('생활(등산)')) {
      return 'asset/img/category_climbing.png';
    } else if (category.contains('생활(여행가기)')) {
      return 'asset/img/category_travel.png';
    } else if (category.contains('생활(문서작성)')) {
      return 'asset/img/category_document.png';
    } else if (category.contains('생활(건강/헬스)')) {
      return 'asset/img/category_health.png';
    } else if (category.contains('생활')) {
      return 'asset/img/category_life.png';
    } else if (category.contains('루틴(기상/수면)')) {
      return 'asset/img/category_bed.png';
    } else if (category.contains('루틴(운동)')) {
      return 'asset/img/category_routine.png';
    } else if (category.contains('루틴(일기쓰기)')) {
      return 'asset/img/category_diary.png';
    } else if (category.contains('루틴(책읽기)')) {
      return 'asset/img/category_reading.png';
    } else if (category.contains('루틴')) {
      return 'asset/img/category_routine.png';
    } else {
      return 'asset/img/category_other.png';
    }
  }
}

// 챌린지 상태 표시 백그라운드 색
Color challengeStatusToBackgroundColor(String status) {
  switch (status) {
    case 'apply':
      return challengeStatusBackgroundColorApply;
    case 'certify':
      return challengeStatusBackgroundColorCertify;
    case 'win':
      return challengeStatusBackgroundColorWin;
    case 'lose':
      return challengeStatusBackgroundColorLose;
    case 'complain':
      return challengeStatusBackgroundColorComplain;
    default:
      return challengeStatusBackgroundColorApply;
  }
}

// 챌린지 상태 표시 텍스트 색
Color challengeStatusToTextColor(String status) {
  switch (status) {
    case 'apply':
      return challengeStatusTextColorApply;
    case 'certify':
      return challengeStatusTextColorCertify;
    case 'win':
      return challengeStatusTextColorWin;
    case 'lose':
      return challengeStatusTextColorLose;
    case 'complain':
      return challengeStatusTextColorComplain;
    default:
      return challengeStatusBackgroundColorApply;
  }
}

// 챌린지 목표 예시문장 카테고리별 맞춤 출력기
String exGoalHintText(String category) {
  switch (category) {
    case '학습(문제풀기)':
      return exGoalStudySolve;
    case '학습(강의)':
      return exGoalStudyLecture;
    case '학습(노트/계획)':
      return exGoalStudyWriting;
    case '학습(시험점수)':
      return exGoalStudyGrade;
    case '학습(학습기타)':
      return exGoalStudyEtc;
    case '생활(등산)':
      return exGoalLifeClimbing;
    case '생활(여행가기)':
      return exGoalLifeTravel;
    case '생활(문서작성)':
      return exGoalLifeWork;
    case '생활(건강/헬스)':
      return exGoalLifeHealth;
    case '생활(생활기타)':
      return exGoalLifeEtc;
    case '루틴(기상/수면)':
      return exGoalRoutineSleep;
    case '루틴(운동)':
      return exGoalRoutineExercise;
    case '루틴(일기쓰기)':
      return exGoalRoutineDiary;
    case '루틴(책읽기)':
      return exGoalRoutineBook;
    case '루틴(루틴기타)':
      return exGoalRoutineEtc;
    default:
      return exGoalEtc;
  }
}

// 체크업 실패사유 예시 문장 카테고리별 맞춤 출력기
String exFailReasonHintText(String category) {
  switch (category) {
    case '학습(문제풀기)':
      return exFailReasonStudySolve;
    case '학습(강의)':
      return exFailReasonStudyLecture;
    case '학습(노트/계획)':
      return exFailReasonStudyWriting;
    case '학습(시험점수)':
      return exFailReasonStudyGrade;
    case '학습(학습기타)':
      return exFailReasonStudyEtc;
    case '생활(등산)':
      return exFailReasonLifeClimbing;
    case '생활(여행가기)':
      return exFailReasonLifeTravel;
    case '생활(문서작성)':
      return exFailReasonLifeWork;
    case '생활(건강/헬스)':
      return exFailReasonLifeHealth;
    case '생활(생활기타)':
      return exFailReasonLifeEtc;
    case '루틴(기상/수면)':
      return exFailReasonRoutineSleep;
    case '루틴(운동)':
      return exFailReasonRoutineExercise;
    case '루틴(일기쓰기)':
      return exFailReasonRoutineDiary;
    case '루틴(책읽기)':
      return exFailReasonRoutineBook;
    case '루틴(루틴기타)':
      return exFailReasonRoutineEtc;
    default:
      return exFailReasonEtc;
  }
}
