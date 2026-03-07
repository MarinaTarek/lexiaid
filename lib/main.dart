import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_pro_screen.dart';
import 'screens/about_screen.dart';
import 'screens/writing_screen.dart';
import 'screens/reading_screen.dart';
import 'screens/progress_tracking_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/SelectQuestionCountScreen.dart';
import 'screens/Streak_Service.dart';
import 'screens/ai_voice_screen.dart';
import 'screens/login.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/writingWriting': (context) => const WritingScreen(),
        '/writing': (context) => const ReadingScreen(),
        '/progress': (context) => const ProgressTrackingScreen(),
        '/focus': (context) => const FocusScreen(),
        '/about': (context) => const AboutScreen(),
        '/selectQuestionCount': (context) => const SelectQuestionCountScreen(),
        '/ai': (context) => const AIVoiceScreen(),
        '/login': (context) => const LoginScreen(),
        '/chat': (context) => const ChatScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(),
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