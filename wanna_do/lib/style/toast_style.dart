import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/text_style.dart';

class InfoGetxToast {
  static void show(BuildContext context, String title, String content) {
    if (Get.isSnackbarOpen) {
      return;
    }
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: font16w800.copyWith(
          color: Colors.white,
          height: 1.0,
        ),
      ),
      messageText: Text(
        content,
        style: font14w300.copyWith(
          color: Colors.white,
        ),
      ),
      icon: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2.5,
            color: subColor,
          ),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.check_rounded,
            size: 25,
            color: subColor,
          ),
        ),
      ),
      duration: Duration(milliseconds: 1700),
      backgroundColor: charcoalColor,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
    );
  }
}

class ErrorGetxToast {
  static void show(BuildContext context, String title, String content) {
    if (Get.isSnackbarOpen) {
      return;
    }
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: font16w800.copyWith(
          color: Colors.white,
          height: 1.0,
        ),
      ),
      messageText: Text(
        content,
        style: font14w300.copyWith(
          color: Colors.white,
        ),
      ),
      icon: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          Icons.error_outlined,
          size: 33,
          color: camelColor,
        ),
      ),
      duration: Duration(seconds: 2),
      colorText: Colors.white,
      backgroundColor: charcoalColor,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
    );
  }
}
