import 'package:flutter/material.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/text_style.dart';

class BigButtonFirst extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  BigButtonFirst({
    required this.buttonText,
    required this.onPressed,
    this.backgroundColor = mainColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: backgroundColor,
            ).copyWith(
              elevation: MaterialStateProperty.resolveWith<double>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return 0;
                  }
                  return 0;
                },
              ),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.black.withOpacity(0.1);
                  }
                  return null;
                },
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Text(
                buttonText,
                style: fontMainButton.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BigButtonSecond extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  const BigButtonSecond({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              buttonText,
              style: font15w700.copyWith(
                color: textColor,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: backgroundColor,
          ).copyWith(
            elevation: MaterialStateProperty.resolveWith<double>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return 0;
                }
                return 0;
              },
            ),
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.black.withOpacity(0.1);
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MediumButtonFirst extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const MediumButtonFirst({
    required this.buttonText,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text(
          buttonText,
          style: font14w800.copyWith(
            color: textColor,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: backgroundColor,
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return 0;
            }
            return 0;
          },
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
    );
  }
}

class MediumButtonSecond extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const MediumButtonSecond({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Text(
          buttonText,
          style: font20w700.copyWith(
            color: textColor,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: backgroundColor,
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return 0;
            }
            return 0;
          },
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
    );
  }
}

class SmallButtonFirst extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget content;

  const SmallButtonFirst({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: backgroundColor,
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return 0;
            }
            return 0;
          },
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
        ),
        child: content,
      ),
    );
  }
}

Container StateButtonFirst(
    {required String widgetText, required bool isSelected}) {
  return Container(
    child: Padding(
      padding: const EdgeInsets.all(9.0),
      child: Text(
        widgetText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w300,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    ),
    decoration: BoxDecoration(
      color: isSelected ? mainColor : null,
      border: Border.all(
        width: 1,
        color: isSelected ? mainColor : greyColor,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}

/* 테스트용 토스 디자인 커플버튼
class MainButtonCouple extends StatelessWidget {
  final String leftButtonText;
  final String rightButtonText;
  final VoidCallback onPressedLeft;
  final VoidCallback onPressedRight;
  final Color backgroundColorLeft;
  final Color backgroundColorRight;
  final Color textColorLeft;
  final Color textColorRight;

  MainButtonCouple({
    required this.leftButtonText,
    required this.rightButtonText,
    required this.onPressedLeft,
    required this.onPressedRight,
    this.backgroundColorLeft = tossSubButtonColor,
    this.backgroundColorRight = mainColor,
    this.textColorLeft = mainColor,
    this.textColorRight = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: onPressedLeft,
              style: mainButtonCouple(
                backgroundColor: backgroundColorLeft,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  leftButtonText,
                  style: fontMainButton.copyWith(
                    color: textColorLeft,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: onPressedRight,
              style: mainButtonCouple(
                backgroundColor: backgroundColorRight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  rightButtonText,
                  style: fontMainButton.copyWith(
                    color: textColorRight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle mainButtonCouple({required Color backgroundColor}) {
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: backgroundColor,
    ).copyWith(
      elevation: MaterialStateProperty.resolveWith<double>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return 0; // 눌렸을 때
          }
          return 0; // 기본 상태
        },
      ),
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.black.withOpacity(0.1); // 길게 눌렀을 때의 오버레이 색상
          }
          return null; // 기본 상태
        },
      ),
    );
  }
}
 */
/* 테스트용 토스 디자인 서브버튼
class SubButtonSmall extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  SubButtonSmall({
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: tossGreyColor,
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return 0; // 눌렸을 때
            }
            return 0; // 기본 상태
          },
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black.withOpacity(0.1); // 길게 눌렀을 때의 오버레이 색상
            }
            return null; // 기본 상태
          },
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0),
        child: Text(
          buttonText,
          style: tossFontSubButton.copyWith(
            color: tossGreyFontColor,
          ),
        ),
      ),
    );
  }
}
 */
