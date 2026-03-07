import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:confetti/confetti.dart';
import 'streak_service.dart';

class QuizProScreen extends StatefulWidget {
  final int initialQuestionCount;

  const QuizProScreen({super.key, required this.initialQuestionCount});

  @override
  State<QuizProScreen> createState() => _QuizProScreenState();
}

class _QuizProScreenState extends State<QuizProScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allQuestions = [];
  List<Map<String, dynamic>> quizQuestions = [];

  int currentIndex = 0;
  int score = 0;
  int xp = 0;

  bool loading = true;
  bool showResult = false;

  String? selectedAnswer;

  int? questionCount;

  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    questionCount = widget.initialQuestionCount;

    loadLocalQuestions();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  Future<void> loadLocalQuestions() async {
    try {
      final easy = await rootBundle.loadString('assets/easy.json');
      final medium = await rootBundle.loadString('assets/medium.json');
      final hard = await rootBundle.loadString('assets/hard.json');

      List<Map<String, dynamic>> questions = [];

      void parse(String data, String difficulty, {bool oldFormat = false}) {
        final decoded = jsonDecode(data);
        final list = decoded['results'] as List;

        for (var q in list) {
          List<String> options = oldFormat
              ? List<String>.from(q['options'])
              : (List<String>.from(q['incorrect_answers'])
            ..add(q['correct_answer']))
              .toSet()
              .toList();

          options.shuffle();

          questions.add({
            "question": q['question'],
            "options": options,
            "correct": q['correct_answer'],
            "difficulty": difficulty
          });
        }
      }

      parse(easy, "Easy");
      parse(medium, "Medium", oldFormat: true);
      parse(hard, "Hard", oldFormat: true);

      questions.shuffle();

      setState(() {
        allQuestions = questions;
        quizQuestions = allQuestions.take(questionCount!).toList();
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading questions $e");
      loading = false;
    }
  }

  void selectAnswer(String answer) async {
    if (selectedAnswer != null) return;

    bool correct = answer == quizQuestions[currentIndex]['correct'];

    if (correct) confettiController.play();

    setState(() {
      selectedAnswer = answer;

      if (correct) {
        score++;
        xp += quizQuestions[currentIndex]['difficulty'] == "Easy"
            ? 10
            : quizQuestions[currentIndex]['difficulty'] == "Medium"
            ? 20
            : 30;
      }
    });

    Future.delayed(const Duration(milliseconds: 700), () async {
      if (currentIndex + 1 < quizQuestions.length) {
        setState(() {
          currentIndex++;
          selectedAnswer = null;
        });
      } else {
        await StreakService.addPoints(xp);

        setState(() {
          showResult = true;
        });
      }
    });
  }

  Color difficultyColor(String diff) {
    switch (diff) {
      case "Medium":
        return const Color(0xFF60A5FA);
      case "Hard":
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF93C5FD);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (showResult) {
      double percent = (score / quizQuestions.length) * 100;

      String message = percent == 100
          ? "🌟 Perfect!"
          : percent >= 70
          ? "👏 Great Job!"
          : "💪 Keep Practicing";

      return Scaffold(
        appBar: AppBar(
          title: const Text("Result"),
          backgroundColor: const Color(0xFF7C8CF8),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6366F1),
                Color(0xFF60A5FA),
                Color(0xFFE0F2FE),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Score: $score / ${quizQuestions.length}"),
                  Text("XP: $xp ⭐"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                    ),
                    onPressed: () {
                      setState(() {
                        currentIndex = 0;
                        score = 0;
                        xp = 0;
                        showResult = false;
                        selectedAnswer = null;
                        quizQuestions.shuffle();
                      });
                    },
                    child: const Text("Play Again"),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    final current = quizQuestions[currentIndex];
    double progress = (currentIndex + 1) / quizQuestions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        backgroundColor: const Color(0xFF7C8CF8),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF1F5FF),
                  Color(0xFFE6EEFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: const Color(0xFF7C8CF8),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  "Question ${currentIndex + 1} / ${quizQuestions.length}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: difficultyColor(current['difficulty']),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    current['question'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ...current['options'].map<Widget>((option) {
                  bool isSelected = option == selectedAnswer;
                  bool isCorrect = option == current['correct'];

                  Color targetColor = Colors.white;

                  if (selectedAnswer != null) {
                    if (isCorrect) {
                      targetColor = const Color(0xFF86EFAC);
                    } else if (isSelected && !isCorrect) {
                      targetColor = const Color(0xFFFCA5A5);
                    }
                  }

                  return GestureDetector(
                    onTap: () => selectAnswer(option),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: targetColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 20,
            ),
          ),
        ],
      ),
    );
  }
}