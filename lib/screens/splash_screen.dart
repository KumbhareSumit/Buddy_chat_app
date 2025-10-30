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
import '../../main.dart';
import '../api/apis.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 2000),(){
      // Exit to full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(systemNavigationBarColor: Colors.deepPurpleAccent,statusBarColor: Colors.transparent));
          if(APIs.auth.currentUser != null){
            dev.log('\nUser: ${APIs.auth.currentUser}');
            //navigate to home screen
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));
          }else{//navigate to login screen
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen()));}

    });
  }
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      //app bar
      /*appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Buddy Chat'),

      ),*/

      body: Stack(children: [


        // app logo
        AnimatedPositioned(
            top: mq.height * .15,
            right:  mq.width * .25 ,
            width: mq.width * .5,
            duration: Duration(seconds: 1),
            child: Image.asset('images/icon.png')),
        // app sign in
        Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            height: mq.height * .06,
            width: mq.width * .9,
            child:Text('Welcome to over Chat app',textAlign: TextAlign.center ,
              style: TextStyle(fontSize: 19,color: Colors.black87,letterSpacing: 2),)),
      ]),

    );

  }
}
