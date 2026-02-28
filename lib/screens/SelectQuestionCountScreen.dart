import 'package:flutter/material.dart';
import 'quiz_pro_screen.dart';

class SelectQuestionCountScreen extends StatefulWidget {
  const SelectQuestionCountScreen({super.key});

  @override
  State<SelectQuestionCountScreen> createState() =>
      _SelectQuestionCountScreenState();
}

class _SelectQuestionCountScreenState
    extends State<SelectQuestionCountScreen> {
  double _questionCount = 10;

  // اللون حسب قيمة Slider
  Color getSliderColor() {
    if (_questionCount <= 15) return Colors.green;
    if (_questionCount <= 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                color: Colors.white.withOpacity(0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 8,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Select number of questions",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _questionCount.toInt().toString(),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: getSliderColor(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: getSliderColor(),
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: getSliderColor(),
                          overlayColor: getSliderColor().withOpacity(0.2),
                          valueIndicatorColor: getSliderColor(),
                          valueIndicatorTextStyle:
                          const TextStyle(color: Colors.white),
                        ),
                        child: Slider(
                          value: _questionCount,
                          min: 5,
                          max: 50,
                          divisions: 45,
                          label: _questionCount.toInt().toString(),
                          onChanged: (value) {
                            setState(() {
                              _questionCount = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizProScreen(
                                  initialQuestionCount:
                                  _questionCount.toInt()),
                            ),
                          );
                        },
                        child: const Text(
                          "Start Quiz",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}