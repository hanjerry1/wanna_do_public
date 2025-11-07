import 'package:flutter/material.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/text_style.dart';

class DialogOneButton extends StatelessWidget {
  final String title;
  final Widget content;
  final String buttonText;
  final VoidCallback onButtonPressed;

  DialogOneButton({
    required this.title,
    required this.content,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: font18w800,
      ),
      content: content,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
              child: GestureDetector(
                onTap: onButtonPressed,
                child: Text(
                  buttonText,
                  style: font16w700.copyWith(
                    color: mainColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DialogTwoButton extends StatelessWidget {
  final String title;
  final Widget content;
  final String leftText;
  final String rightText;
  final VoidCallback onLeftButtonPressed;
  final VoidCallback onRightButtonPressed;

  DialogTwoButton({
    required this.title,
    required this.content,
    required this.leftText,
    required this.rightText,
    required this.onLeftButtonPressed,
    required this.onRightButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: font18w800,
      ),
      content: content,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onLeftButtonPressed,
                child: Container(
                  width: 100,
                  child: Center(
                    child: Text(
                      leftText,
                      style: font16w700.copyWith(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 40),
              GestureDetector(
                onTap: onRightButtonPressed,
                child: Container(
                  width: 100,
                  child: Center(
                    child: Text(
                      rightText,
                      style: font16w700.copyWith(
                        color: mainColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
