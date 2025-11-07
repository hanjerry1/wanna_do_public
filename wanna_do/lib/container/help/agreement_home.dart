import 'package:flutter/material.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';
import 'package:webview_flutter/webview_flutter.dart';

final homeUrl1 = Uri.parse(
    'https://marvelous-cantaloupe-01b.notion.site/Wanna-Do-d0e3375f34b8423488a4393d1b40bb77?pvs=4');
final homeUrl2 = Uri.parse(
    'https://marvelous-cantaloupe-01b.notion.site/Wanna-Do-9c646363d38f41e5a2e968f96eb830c6?pvs=4');

class AgreementHome extends StatefulWidget {
  const AgreementHome({super.key});

  @override
  State<AgreementHome> createState() => _AgreementHomeState();
}

class _AgreementHomeState extends State<AgreementHome> {
  WebViewController controller1 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl1);
  WebViewController controller2 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl2);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: SubAppBar(),
          body: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: '이용 약관'),
                  Tab(text: '개인정보 처리방침'),
                ],
                labelColor: charcoalColor,
                labelStyle: font18w800.copyWith(fontFamily: 'NanumSquare'),
                unselectedLabelColor: charcoalColor.withOpacity(0.3),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2,
                    color: charcoalColor,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        WebViewWidget(
                          controller: controller1,
                        ),
                        WebViewWidget(
                          controller: controller2,
                        ),
                      ],
                    ),
                    if (isLoading) ShortLoadingFirst(),
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
