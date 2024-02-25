import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odyssey/pages/splash_screen.dart';
import 'package:odyssey/utils/string_constants.dart';
import 'package:odyssey/utils/theme.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(const ProviderScope(child: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConstants.appName,
      theme: ThemeData(
        fontFamily: 'VT323',
        hintColor: Colors.white,
        scaffoldBackgroundColor: ThemesDark().normalColor,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: ThemesDark().oppositeColor,
            ),
          ),
          hintStyle: TextStyle(color: ThemesDark().oppositeColor),
        ),

      ),
      home: const SplashScreen(),
    );
  }
}

