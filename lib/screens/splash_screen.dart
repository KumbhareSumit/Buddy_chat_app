//import 'package:flutter/cupertino.dart';
//import 'dart:math';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat/screens/auth/login_screen.dart';
import 'package:wechat/screens/home_screen.dart';
//import 'package:wechat/screens/home_screen.dart';
import 'dart:developer' as dev;
import '../main.dart';
import '../api/apis.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () async {
      // Exit to full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.deepPurpleAccent,
          statusBarColor: Colors.transparent));

      if (APIs.auth.currentUser != null) {
        dev.log('\nUser: ${APIs.auth.currentUser}');

        //fetch self info
        await APIs.getSelfInfo().then((value) {
          //navigate to home screen
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        });
      } else {
        //navigate to login screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          children: [
            // app logo
            Center(
              child: AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: mq.width * .4,
                child: Image.asset('images/icon.png'),
              ),
            ),

            // Footer
            Positioned(
                bottom: mq.height * .1,
                width: mq.width,
                child: Column(
                  children: [
                    Text(
                      'BUDDY CHAT',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect with friends instantly',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          letterSpacing: .5),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
