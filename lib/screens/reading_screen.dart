import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class ReadingScreen extends StatefulWidget {
  final String userName;

  // هنا خليت userName اختياري وفي حالة عدم وجوده هيكون "Friend"
  const ReadingScreen({super.key, this.userName = "Friend"});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  List<String> words = [];
  int currentWord = 0;
  int wordsRead = 0;
  int regressions = 0;
  int readingSpeed = 200;
  bool isReading = false;
  Timer? timer;

  final String text =
      "This is a simple speed reading demo to help you train your eyes to move faster across the text without going back.";

  @override
  void initState() {
    super.initState();
    words = text.split(" ");
  }

  void startReading() {
    timer?.cancel();

    timer = Timer.periodic(
      Duration(milliseconds: (60000 / readingSpeed).round()),
          (timer) {
        if (currentWord < words.length - 1) {
          setState(() {
            currentWord++;
            wordsRead++;
          });
        } else {
          timer.cancel();
          setState(() {
            isReading = false;
          });
        }
      },
    );
  }

  void toggleReading() {
    setState(() {
      isReading = !isReading;
    });

    if (isReading) {
      startReading();
    } else {
      timer?.cancel();
    }
  }

  void reset() {
    timer?.cancel();
    setState(() {
      currentWord = 0;
      wordsRead = 0;
      regressions = 0;
      isReading = false;
    });
  }

  void handleWordClick(int index) {
    if (index < currentWord) {
      setState(() {
        regressions++;
        currentWord = index;
      });
    }
  }

  Widget _buildStatCard(
      {required IconData icon,
        required Color color,
        required String value,
        required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(label, style: const TextStyle(fontSize: 12))
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff88b0da),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    "Hi, ${widget.userName}!",
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 60),
                ],
              ),

              const SizedBox(height: 50),

              /// Text Box
              Container(
                padding: const EdgeInsets.all(50),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Wrap(
                  children: List.generate(words.length, (index) {
                    bool isCurrent = index == currentWord;

                    return GestureDetector(
                      onTap: () => handleWordClick(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        padding:
                        isCurrent ? const EdgeInsets.all(6) : EdgeInsets.zero,
                        decoration: isCurrent
                            ? BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(8),
                        )
                            : null,
                        child: Text(
                          words[index],
                          style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: index < currentWord
                                  ? Colors.green
                                  : Colors.black,
                              fontSize: 25),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              /// Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: toggleReading,
                      icon:
                      Icon(isReading ? Icons.pause : Icons.play_arrow),
                      label: Text(
                        isReading
                            ? "Pause"
                            : (currentWord == 0
                            ? "Start Reading"
                            : "Resume"),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: reset,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text("Reset"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent.shade200,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Speed Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reading Speed (words per minute)",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Slider(
                    value: readingSpeed.toDouble(),
                    min: 100,
                    max: 400,
                    divisions: 6,
                    label: readingSpeed.toString(),
                    onChanged: (value) {
                      setState(() {
                        readingSpeed = value.round();
                        if (isReading) startReading();
                      });
                    },
                  ),
                ],
              ),

              const Spacer(),

              /// Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.visibility,
                      color: Colors.blueAccent,
                      value: "$wordsRead",
                      label: "Words Read",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.speed,
                      color: Colors.green,
                      value:
                      "${((currentWord / words.length) * 100).round()}%",
                      label: "Progress",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.warning,
                      color: Colors.redAccent,
                      value: "$regressions",
                      label: "Regressions",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}