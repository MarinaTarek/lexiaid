import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:confetti/confetti.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Colorful Quiz",
      home: const QuestionCountScreen(),
    );
  }
}

// =========================
// Screen لاختيار عدد الأسئلة
// =========================
class QuestionCountScreen extends StatefulWidget {
  const QuestionCountScreen({super.key});

  @override
  State<QuestionCountScreen> createState() => _QuestionCountScreenState();
}

class _QuestionCountScreenState extends State<QuestionCountScreen> {
  int selectedCount = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Number of Questions")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Choose how many questions you want:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: selectedCount,
              items: [5,10,15,20,25].map((e) => DropdownMenuItem(value: e, child: Text("$e"))).toList(),
              onChanged: (v) => setState(() => selectedCount = v!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => QuizProScreen(initialQuestionCount: selectedCount)
                ));
              },
              child: const Text("Start Quiz"),
            )
          ],
        ),
      ),
    );
  }
}

// =========================
// Quiz Screen
// =========================
class QuizProScreen extends StatefulWidget {
  final int initialQuestionCount; // عدد الأسئلة اللي وصل من الـ Welcome Screen
  const QuizProScreen({super.key, required this.initialQuestionCount});

  @override
  State<QuizProScreen> createState() => _QuizProScreenState();
}

class _QuizProScreenState extends State<QuizProScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allQuestions = [];
  List<Map<String, dynamic>> quizQuestions = [];
  int currentIndex = 0;
  int score = 0;
  int xp = 0;
  String? selectedAnswer;
  bool loading = true;
  bool showResult = false;

  int? questionCount; // متغير جديد لاختيار عدد الأسئلة داخل الكويز

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    // استدعاء Dialog بعد الـ first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectQuestionCountDialog();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // =========================
  // Dialog لاختيار عدد الأسئلة داخل الكويز
  // =========================
  void selectQuestionCountDialog() async {
    final int? count = await showDialog<int>(
      context: context,
      barrierDismissible: false, // لازم يختار
      builder: (context) => AlertDialog(
        title: const Text("Select number of questions"),
        content: DropdownButton<int>(
          value: widget.initialQuestionCount,
          items: [5, 10, 15, 20, 25]
              .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
              .toList(),
          onChanged: (v) {
            Navigator.of(context).pop(v);
          },
        ),
      ),
    );

    setState(() {
      questionCount = count ?? widget.initialQuestionCount;
    });

    loadLocalQuestions(); // تحميل الأسئلة بعد اختيار العدد
  }

  // =========================
  // تحميل الأسئلة
  // =========================
  Future<void> loadLocalQuestions() async {
    try {
      final easyData = await rootBundle.loadString('assets/easy.json');
      final mediumData = await rootBundle.loadString('assets/medium.json');
      final hardData = await rootBundle.loadString('assets/hard.json');

      List<Map<String, dynamic>> questions = [];

      void parseJson(String data, String difficulty, {bool oldFormat=false}) {
        final decoded = jsonDecode(data);
        final listData = decoded['results'] as List<dynamic>;
        for (var q in listData) {
          List<String> options = oldFormat
              ? List<String>.from(q['options'])
              : List<String>.from(q['incorrect_answers'])..add(q['correct_answer']);
          options.shuffle();
          questions.add({
            'question': q['question'],
            'options': options,
            'correct': q['correct_answer'],
            'difficulty': difficulty
          });
        }
      }

      parseJson(easyData, 'Easy');
      parseJson(mediumData, 'Medium', oldFormat: true);
      parseJson(hardData, 'Hard', oldFormat: true);

      questions.shuffle();

      setState(() {
        allQuestions = questions;
        quizQuestions = allQuestions.take(questionCount!).toList();
        loading = false;
      });
    } catch (e) {
      print("Error loading local questions: $e");
      setState(() => loading = false);
    }
  }

  void selectAnswer(String answer) {
    if (selectedAnswer != null) return;

    bool correct = answer == quizQuestions[currentIndex]['correct'];
    if (correct) _confettiController.play();

    setState(() {
      selectedAnswer = answer;
      if (correct) {
        score++;
        xp += quizQuestions[currentIndex]['difficulty'] == 'Easy'
            ? 10
            : quizQuestions[currentIndex]['difficulty'] == 'Medium'
            ? 20
            : 30;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (currentIndex + 1 < quizQuestions.length) {
        setState(() {
          currentIndex++;
          selectedAnswer = null;
        });
      } else {
        setState(() {
          showResult = true;
        });
      }
    });
  }

  Color difficultyColor(String difficulty) {
    switch (difficulty) {
      case "Medium": return Colors.orange;
      case "Hard": return Colors.red;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (quizQuestions.isEmpty) return const Scaffold(body: Center(child: Text("No questions available")));

    if (showResult) {
      double percentage = (score / quizQuestions.length) * 100;
      String message = percentage == 100 ? "🌟 Perfect Score!" :
      percentage >= 70 ? "👏 Great Job!" : "💪 Keep Practicing!";
      return Scaffold(
        appBar: AppBar(
          title: const Text("Quiz Result"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.purple, Colors.blue]),
                borderRadius: BorderRadius.circular(30)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text("Score: $score / ${quizQuestions.length}", style: const TextStyle(color: Colors.white)),
                Text("XP Earned: $xp ⭐", style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentIndex = 0; score = 0; xp = 0;
                      selectedAnswer = null; showResult = false;
                      quizQuestions.shuffle();
                    });
                  },
                  child: const Text("Play Again"),
                )
              ],
            ),
          ),
        ),
      );
    }

    final current = quizQuestions[currentIndex];
    double progress = (currentIndex + 1) / quizQuestions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Time!"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.yellow.shade200, Colors.pink.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                )
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                            progress < 0.5 ? Colors.green : (progress < 0.8 ? Colors.orange : Colors.red)
                        ),
                        minHeight: 12
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                      "Question ${currentIndex + 1} / ${quizQuestions.length}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: difficultyColor(current['difficulty']))
                  ),
                  const SizedBox(height: 15),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade100, Colors.purple.shade100],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade400, blurRadius: 8, offset: const Offset(2, 4))
                        ]
                    ),
                    child: Text(current['question'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  ...current['options'].map<Widget>((option) {
                    bool isSelected = option == selectedAnswer;
                    bool isCorrect = option == current['correct'];

                    Color bgColor = Colors.white;
                    if (selectedAnswer != null) {
                      if (isSelected && isCorrect) bgColor = Colors.greenAccent.shade400;
                      else if (isSelected && !isCorrect) bgColor = Colors.redAccent.shade400;
                      else if (!isSelected && isCorrect) bgColor = Colors.greenAccent.shade100;
                    } else {
                      bgColor = Colors.primaries[Random().nextInt(Colors.primaries.length)].shade100;
                    }

                    return GestureDetector(
                      onTap: () => selectAnswer(option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.shade400, blurRadius: 6, offset: const Offset(2,4))
                            ]
                        ),
                        child: Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow, Colors.cyan],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );

  }

}