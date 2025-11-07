import 'package:flutter/material.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:webview_flutter/webview_flutter.dart';

final homeUrl1 = Uri.parse(
    'https://marvelous-cantaloupe-01b.notion.site/86cca8895735425db84a7084f8b19e0f?v=a50dcc5fe3e74fa9a31aa962d39a5c15&pvs=4');

class CompanyHome extends StatefulWidget {
  CompanyHome({super.key});

  @override
  State<CompanyHome> createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {
  WebViewController controller1 = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(homeUrl1);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SubAppBar(),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller1,
          ),
          if (isLoading) ShortLoadingFirst(),
        ],
      ),
    );
  }
}
