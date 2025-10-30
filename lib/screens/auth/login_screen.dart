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
      if (user != null){
        dev.log('\nUser: ${user.user}');
        dev.log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if((await APIs.userExists())){
          Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }else{
          await APIs.createUser().then((value){
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    } );
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
   // mq = MediaQuery.of(context).size;
    return Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Buddy Chat'),

      ),

      body: Stack(children: [


        // app logo
        AnimatedPositioned(
            top: mq.height * .15,
            right: _Animate ? mq.width * .25 : - mq.width * .5,
            width: mq.width * .5,
            duration: Duration(seconds: 1),
            child: Image.asset('images/icon.png')),
        // app sign in
        Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            height: mq.height * .06,
            width: mq.width * .9,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
                onPressed: (){
                  _handleGoogleBtnClick();
                },

                // google icon
                icon:Image.asset('images/google.png',height: mq.height *.04,) ,
                //login with google
                label:RichText(text: TextSpan(
                    style: TextStyle(color: Colors.black,fontSize: 20),
                    children: [
                  TextSpan(text: 'Login with'),
                  TextSpan(text: ' Google',style: TextStyle(fontWeight: FontWeight.w500))
                ]))))
      ],),

    );

  }
}
