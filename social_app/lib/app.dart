import 'package:flutter/material.dart';
import 'package:social_app/features/auth/presentation/pages/auth.dart';
import 'package:social_app/features/themes/light_mode.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightMode,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const AuthPage(),
    );
  }
}
