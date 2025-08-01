import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('lo', 'LA'),
      ],
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        onFinish: () {
          // ใช้ navigatorKey เพื่อให้ context ทำงานได้
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),
      navigatorKey: navigatorKey,
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();