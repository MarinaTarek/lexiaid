import 'dart:async';
import 'package:flutter/material.dart';

class ReadingModeScreen extends StatefulWidget {
  final String userName; // الاسم اللي هيوصل من WelcomeScreen/HomeScreen
  const ReadingModeScreen({super.key, this.userName = "Friend"});

  @override
  State<ReadingModeScreen> createState() => _ReadingModeScreenState();
}

class _ReadingModeScreenState extends State<ReadingModeScreen> {
  bool isReading = false;
  int currentWord = 0;
  int readingSpeed = 250; // كلمات في الدقيقة
  int regressions = 0;
  int wordsRead = 0;

  final String sampleText =
      "The quick brown fox jumps over the lazy dog. Reading is a wonderful way to learn new things and explore different worlds. Practice makes perfect, and every day you read, you get better and better!";
  late List<String> words;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    words = sampleText.split(' ');
  }

  void startReading() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: (60000 / readingSpeed).round()),
          (timer) {
        if (currentWord >= words.length - 1) {
          stopReading();
        } else {
          setState(() {
            currentWord++;
            wordsRead++;
          });
        }
      },
    );
  }

  void stopReading() {
    _timer?.cancel();
    setState(() {
      isReading = false;
    });
  }

  void toggleReading() {
    if (isReading) {
      stopReading();
    } else {
      setState(() {
        isReading = true;
      });
      startReading();
    }
  }

  void handleWordClick(int index) {
    if (index < currentWord) {
      setState(() {
        regressions++;
      });
    }
    setState(() {
      currentWord = index;
    });
  }

  void reset() {
    stopReading();
    setState(() {
      currentWord = 0;
      wordsRead = 0;
      regressions = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6), Color(0xFFE0FFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Header مع تحية الاسم
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                  Text(
                    "Hi, ${widget.userName}!", // التحية
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),

              // Text area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue.shade200,
                        blurRadius: 15,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: Wrap(
                  children: List.generate(words.length, (index) {
                    bool isCurrent = index == currentWord;
                    return GestureDetector(
                      onTap: () => handleWordClick(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        padding: isCurrent ? const EdgeInsets.all(6) : EdgeInsets.zero,
                        decoration: isCurrent
                            ? BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.yellow.shade200,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2))
                            ])
                            : null,
                        child: Text(
                          words[index],
                          style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: index < currentWord
                                  ? Colors.green
                                  : Colors.black,
                              fontSize: 18),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // Controls
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: toggleReading,
                      icon: Icon(isReading ? Icons.pause : Icons.play_arrow),
                      label: Text(
                          isReading ? 'Pause' : (currentWord == 0 ? 'Start Reading' : 'Resume')),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.greenAccent.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: reset,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.pinkAccent.shade200,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Speed control
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reading Speed (words per minute)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                    activeColor: Colors.blueAccent,
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.visibility, size: 32, color: Colors.blueAccent),
                      const SizedBox(height: 4),
                      Text('$wordsRead', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('Words Read')
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.speed, size: 32, color: Colors.green),
                      const SizedBox(height: 4),
                      Text('${((currentWord / words.length) * 100).round()}%',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('Progress')
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.warning, size: 32, color: Colors.redAccent),
                      const SizedBox(height: 4),
                      Text('$regressions', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('Regressions')
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (regressions > 3)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Text(
                    'Try to avoid going back! Reading forward helps comprehension. 💪',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),

              if (!isReading && currentWord >= words.length - 1 && wordsRead > 0)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: const [
                      Text('🎉 Great Job!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('You finished the passage! Your reading is improving! 🌟'),
                      SizedBox(height: 12),
                      Text('+10 Stars Earned!')
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
