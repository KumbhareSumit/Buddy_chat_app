import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:wechat/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'dart:developer' as dev;
late Size mq;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // enter to full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // for setting orientation to portrait only
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp ,DeviceOrientation.portraitDown]).then((value){
    _initializeFirebase();
    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buddy Chat',
      debugShowCheckedModeBanner: false,
      //app theme
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
            elevation: 1,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 22),
          backgroundColor: Colors.deepPurpleAccent,),
        ),
        //useMaterial3: true,

      home: const SplashScreen()
     // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'for showing message notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'chats',);
  dev.log('\nNotification Channel Result : $result');
}



