import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:page_transition/page_transition.dart';

import 'api.dart';
import 'home.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool visible = true;

  @override
  void initState() {
    super.initState();
    _icon();
    API(context).getAllBooks();
    API(context).getAllAccounts();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.green[50],
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));

    return Material(
      color: Colors.green[50],
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        child: Image.asset(
          "assets/icon.png",
        ),
        duration: const Duration(milliseconds: 1300),
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    );
  }

  _icon() {
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
      visible = !visible;
      // width = 260;
      });
    });

      Future<void>.delayed(const Duration(milliseconds: 1700), () {
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.scale, duration: const Duration(milliseconds: 800), alignment: Alignment.bottomCenter, child: const HomePage()));

        // Navigator.pushReplacement(context,
        //     PageRouteBuilder(pageBuilder: (_, __, ___) => const HomePage()));
      });
    // });
  }
}