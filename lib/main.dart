import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_pro_screen.dart';
import 'screens/about_screen.dart';
import 'screens/writing_screen.dart';
import 'screens/reading_mode_screen.dart';
import 'screens/progress_tracking_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/SelectQuestionCountScreen.dart'; // الاسم مطابق للكلاس
import 'screens/Streak_Service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 🔥 الخلفية العامة (زي صفحة الكويز)
  Widget _appBackground(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF5F2C82),
            Color(0xFF49A09D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        primarySwatch: Colors.deepPurple,
      ),
      builder: (context, child) {
        // كل الشاشات هيكون ليها نفس الخلفية الملونة
        return _appBackground(child!);
      },
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/writingWriting': (context) => const WritingScreen(),
        '/writing': (context) => const ReadingModeScreen(),
        '/progress': (context) => const ProgressTrackingScreen(),
        '/focus': (context) => const FocusScreen(),
        '/about': (context) => const AboutScreen(),
        '/selectQuestionCount': (context) => const SelectQuestionCountScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final String userName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(userName: userName),
          );
        }

        if (settings.name == '/quizPro') {
          final args = settings.arguments as Map<String, dynamic>?;

          int questionCount = 10;
          if (args != null && args.containsKey('questionCount')) {
            questionCount = args['questionCount'];
          }

          return MaterialPageRoute(
            builder: (context) =>
                QuizProScreen(initialQuestionCount: questionCount),
          );
        }

        return null;
      },
    );
  }
}