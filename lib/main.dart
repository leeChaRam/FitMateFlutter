import 'package:flutter/material.dart';
import 'theme/FitMateTheme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// 로그인 화면 import (features/auth 폴더로 이동)
import 'features/auth/screens/login.dart';

void main() {
  runApp(const FitMateApp());
}

class FitMateApp extends StatelessWidget {
  const FitMateApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMate',
      theme: FitMateTheme.lightTheme,
      darkTheme: FitMateTheme.darkTheme,
      themeMode: ThemeMode.system,
      // 앱 시작 화면 = 로그인 화면
      // 로그인 성공 시 login.dart 안에서 MainNavigationScreen으로 이동합니다.
      home: const Login(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
    );
  }
}

