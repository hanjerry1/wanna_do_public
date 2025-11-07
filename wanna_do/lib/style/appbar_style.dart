import 'package:flutter/material.dart';
import 'package:wanna_do/style/text_style.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final TextStyle textStyle;

  const MainAppBar({
    super.key,
    required this.title,
    this.actions,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      elevation: 0.1,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      actions: actions,
      title: Text(
        title,
        style: textStyle,
      ),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class SubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onBackButtonPressed;

  SubAppBar({
    this.title,
    this.actions,
    this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      actions: actions,
      elevation: 0,
      leading: onBackButtonPressed != null
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: onBackButtonPressed,
            )
          : null,
      title: Text(
        title ?? '',
        style: font18w700.copyWith(
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
