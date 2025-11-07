import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:wanna_do/style/text_style.dart';
import '../const/colors.dart';

class UnableMainPage extends StatelessWidget {
  const UnableMainPage({super.key});

  Future<void> sendEmail() async {
    final Email email = Email(
      body: '',
      subject: '[Wanna Do 이용 문의]'
          '\n문의자: ${FirebaseAuth.instance.currentUser!.uid}'
          '\n\n회원님의 부적절한 활동이 확인되어 이용이 제한되었어요.'
          '\n혹시 부적절한 활동을 한 적이 없는데 이용 제한이 된 경우 저희에게 알려주세요.',
      recipients: ['climbers.hst@gmail.com'],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '워너두 이용 제한 안내',
                      style: font18w800,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '부적절한 사용자로 확인되어 워너두를 이용할 수 없어요. 다시 이용을 원할 경우 고객센터 이메일로 직접 문의해주세요.',
                      style: font15w400.copyWith(
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        await sendEmail();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '이메일 문의',
                            style: font16w800.copyWith(
                              color: mainColor,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
