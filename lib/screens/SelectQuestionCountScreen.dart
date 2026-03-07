import 'package:flutter/material.dart';
import 'quiz_pro_screen.dart';
import 'home_screen.dart';

class SelectQuestionCountScreen extends StatefulWidget {
  const SelectQuestionCountScreen({super.key});

  @override
  State<SelectQuestionCountScreen> createState() =>
      _SelectQuestionCountScreenState();
}

class _SelectQuestionCountScreenState
    extends State<SelectQuestionCountScreen> {
  double _questionCount = 10;

  Color getSliderColor() {
    if (_questionCount <= 15) return Colors.lightBlue.shade400;
    if (_questionCount <= 30) return Colors.blue.shade400;
    return Colors.blue.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2FE),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 35),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),

                      const Icon(
                        Icons.quiz,
                        size: 70,
                        color: Colors.blueAccent,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Select number of questions",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: getSliderColor().withOpacity(.15),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _questionCount.toInt().toString(),
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: getSliderColor(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 8,
                          activeTrackColor: getSliderColor(),
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: getSliderColor(),
                          overlayColor: getSliderColor().withOpacity(.2),
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

                      const SizedBox(height: 40),

                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF42A5F5),
                              Color(0xFF1E88E5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizProScreen(
                                  initialQuestionCount:
                                  _questionCount.toInt(),
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Start Quiz",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.blueAccent, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}