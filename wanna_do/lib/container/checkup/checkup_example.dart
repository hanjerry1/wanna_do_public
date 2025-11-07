import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:webview_flutter/webview_flutter.dart';

final homeUrl1 = Uri.parse(
    'https://marvelous-cantaloupe-01b.notion.site/c5683eb2a8cb4d54943d10d5ad8302b8?pvs=4');

class CheckupExample extends StatefulWidget {
  CheckupExample({super.key});

  @override
  State<CheckupExample> createState() => _CheckupExampleState();
}

class _CheckupExampleState extends State<CheckupExample> {
  WebViewController controller1 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl1);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller1,
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Lottie.asset(
                    'asset/lottie/short_loading_first_animation.json',
                    height: 100,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
