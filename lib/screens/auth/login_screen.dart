import 'dart:io';
//import 'dart:math' show log;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/screens/home_screen.dart';
import '../../api/apis.dart';
import '../../main.dart';
import 'dart:developer' as dev;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _Animate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500),(){
      setState(() {
        _Animate = true;
      });

    });
  }
  _handleGoogleBtnClick() {

    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        dev.log('\nUser: ${user.user}');
        dev.log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        await APIs.getSelfInfo().then((value) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        });
      }
    });
  }
    Future<UserCredential?>_signInWithGoogle() async {
     try{
       await InternetAddress.lookup('google.com');
       // Trigger the authentication flow
       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

       // Obtain the auth details from the request
       final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

       // Create a new credential
       final credential = GoogleAuthProvider.credential(
         accessToken: googleAuth?.accessToken,
         idToken: googleAuth?.idToken,
       );

       // Once signed in, return the UserCredential
       return await APIs.auth.signInWithCredential(credential);
     }catch(e){
       dev.log('\n_signInWithGoogle: $e');
       Dialogs.showSnackBar(context, 'Something went wrong (check internet!)');
       return null;
     }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // app logo
          AnimatedPositioned(
              top: mq.height * .2,
              right: _Animate ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .5,
              duration: const Duration(seconds: 1),
              child: Image.asset('images/icon.png')),

          // Title & Description
          Positioned(
              top: mq.height * .45,
              width: mq.width,
              child: Column(
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue chatting',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              )),

          // login button
          Positioned(
              bottom: mq.height * .1,
              left: mq.width * .1,
              height: mq.height * .07,
              width: mq.width * .8,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shadowColor: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22))),
                  onPressed: () {
                    _handleGoogleBtnClick();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/google.png',
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }
}
