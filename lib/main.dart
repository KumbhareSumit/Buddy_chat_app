import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:wechat/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'dart:developer' as dev;

late Size mq;

// Global notifier for theme mode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // enter to full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // for setting orientation to portrait only
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await _initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Buddy Chat',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C5CE7),
              primary: const Color(0xFF6C5CE7),
              surface: const Color(0xFFF8F9FD),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9FD),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF1E1E2D)),
              titleTextStyle: TextStyle(
                  color: Color(0xFF1E1E2D),
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: -0.6),
              backgroundColor: Colors.transparent,
            ),
            cardTheme: CardTheme(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.black.withValues(alpha: 0.04), width: 1),
              ),
              color: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF1E1E2D)),
              bodyMedium: TextStyle(color: Color(0xFF636E72)),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C5CE7),
              primary: const Color(0xFF6C5CE7),
              surface: const Color(0xFF161622),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0F0F17),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: -0.6),
              backgroundColor: Colors.transparent,
            ),
            cardTheme: CardTheme(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
              ),
              color: const Color(0xFF181824),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Color(0xFFA0A0B2)),
            ),
          ),
          home: const SplashScreen(),
        );
      },
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
    name: 'chats',
  );
  dev.log('\nNotification Channel Result : $result');
}
