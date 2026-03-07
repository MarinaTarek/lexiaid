import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int timeLeft = 25 * 60;
  bool isActive = false;
  int currentSession = 1;
  int sessionsCompleted = 0;
  bool showDistraction = false;

  Timer? timer;
  Timer? distractionTimer;
  Random random = Random();

  void startTimer() {
    if (timer != null) timer!.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        stopTimer();
        setState(() {
          sessionsCompleted++;
          timeLeft = 5 * 60;
        });
      }
    });

    distractionTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (random.nextDouble() > 0.7) {
        setState(() {
          showDistraction = true;
        });
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            showDistraction = false;
          });
        });
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    distractionTimer?.cancel();
    setState(() {
      isActive = false;
    });
  }

  void toggleTimer() {
    setState(() {
      isActive = !isActive;
    });
    if (isActive) startTimer();
    else stopTimer();
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      timeLeft = 25 * 60;
    });
  }

  String formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  void dispose() {
    timer?.cancel();
    distractionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (25 * 60 - timeLeft) / (25 * 60);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Stack(
          children: [
            ...List.generate(10, (i) {
              double left = random.nextDouble() * MediaQuery.of(context).size.width;
              double top = random.nextDouble() * MediaQuery.of(context).size.height;
              Color color = i % 3 == 0
                  ? Colors.lightBlue.withOpacity(0.3)
                  : i % 3 == 1
                  ? Colors.blueAccent.withOpacity(0.3)
                  : Colors.cyan.withOpacity(0.3);
              return Positioned(
                left: left,
                top: top,
                child: AnimatedContainer(
                  duration: const Duration(seconds: 5),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              );
            }),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                      ),
                      const Text('Focus Zone',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 8,
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.lightBlue,
                              child: Text("🧠", style: TextStyle(fontSize: 40))),
                          const SizedBox(height: 12),
                          Text("Pomodoro Session $currentSession",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text("Stay focused and learn better!",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 20),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.blue[100],
                                  color: Colors.lightBlue,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(formatTime(timeLeft),
                                      style: const TextStyle(
                                          fontSize: 36, fontWeight: FontWeight.bold)),
                                  Text(
                                      isActive ? "Stay focused!" : "Ready to start?",
                                      style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: toggleTimer,
                                icon: Icon(isActive ? Icons.pause : Icons.play_arrow),
                                label: Text(isActive ? "Pause" : "Start"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton.icon(
                                onPressed: resetTimer,
                                icon: const Icon(Icons.rotate_left,
                                    color: Colors.lightBlue),
                                label: const Text("Reset",
                                    style: TextStyle(color: Colors.lightBlue)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  side: const BorderSide(color: Colors.lightBlue),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (showDistraction)
                    Card(
                      color: Colors.blue[100],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text("👀", style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            const Text("Are you still here?",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const Text("Stay focused! You're doing great! 💪",
                                textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showDistraction = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent),
                              child: const Text("Yes, I'm here! ✨"),
                            )
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text("🎯", style: TextStyle(fontSize: 28)),
                          Text("$sessionsCompleted",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue)),
                          const Text("Sessions Done",
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("⏱️", style: TextStyle(fontSize: 28)),
                          Text("${sessionsCompleted * 25}",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent)),
                          const Text("Minutes Focused",
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("🔥", style: TextStyle(fontSize: 28)),
                          Text("$currentSession",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan)),
                          const Text("Current Session",
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}