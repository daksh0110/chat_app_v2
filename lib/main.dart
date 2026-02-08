import 'package:flutter/material.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/screens/home.dart';
import 'package:my_app/screens/log_in.dart';
import 'package:my_app/screens/onboarding_screen.dart';
import 'package:my_app/screens/sign_up.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Caros"),

      initialRoute: AppRoutes.home,

      routes: {
        AppRoutes.home: (context) => Home(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.logIn: (context) => const LogIn(),
        AppRoutes.signUp: (context) => const SignUp(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
