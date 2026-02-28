import 'dart:math';
import 'package:flutter/material.dart';
import 'Streak_Service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, this.userName = "Friend"})
  ;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    // 🔥 تحديث الستريك أول ما الهوم يفتح
    StreakService.updateStreak();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget buildStreakBox() {
    return FutureBuilder(
      future: Future.wait([
        StreakService.getStreak(),
        StreakService.getPoints(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        int streak = snapshot.data![0] as int;
        int points = snapshot.data![1] as int;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withAlpha(80),
                blurRadius: 15,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text("🔥", style: TextStyle(fontSize: 28)),
                  Text(
                    "$streak Days",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text("⭐", style: TextStyle(fontSize: 28)),
                  Text(
                    "$points XP",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildFeatureCard({
    required String title,
    required String description,
    required String emoji,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  })

  {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: startColor.withAlpha(77),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 14)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String getGreeting() {
    if (widget.userName.toLowerCase() == "jo") {
      return "Hi, ${widget.userName}!";
    } else {
      return "Hey, ${widget.userName}!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6E6FA), Color(0xFFFFB6C1), Color(0xFF98FB98)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Floating sparkles
            ...List.generate(8, (i) {
              final random = Random();
              return Positioned(
                left: random.nextDouble() * screenWidth,
                top: random.nextDouble() * screenHeight,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              );
            }),

            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Header
                  Text(
                    getGreeting(),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF9370DB), Color(0xFFFF69B4)],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  buildStreakBox(),   // 🔥 هنا الستريك

                  const SizedBox(height: 20),

                  const Text(
                    "What would you like to learn today?",
                    style: TextStyle(fontSize: 18, color: Color(0xFF6B5B95)),
                  ),

                  const SizedBox(height: 30),

                  // Feature Cards
                  // 1️⃣ Writing Screen
                  buildFeatureCard(
                    title: 'Writing Detective',
                    description: 'Get instant help with your writing',
                    emoji: '✍️',
                    startColor: const Color(0xFFFF7F7F),
                    endColor: const Color(0xFFFFB6C1),
                    onTap: () {
                      Navigator.pushNamed(context, '/writingWriting');
                      // هنا رابط شاشة الكتابة الفعلية
                    },
                  ),
                  // 2️⃣ Reading Screen
                  buildFeatureCard(
                    title: 'Reading Tracker',
                    description: 'Track and improve your reading',
                    emoji: '📖',
                    startColor: const Color(0xFF87CEEB),
                    endColor: const Color(0xFFB0E0E6),
                    onTap: () {
                      Navigator.pushNamed(context, '/writing');
                      // هذا رابط ReadingModeScreen
                    },
                  ),
                  // 3️⃣ Progress
                  buildFeatureCard(
                    title: 'My Progress',
                    description: "See how much you've grown",
                    emoji: '🌟',
                    startColor: const Color(0xFF98FB98),
                    endColor: const Color(0xFF90EE90),
                    onTap: () {
                      Navigator.pushNamed(context, '/progress');
                    },
                  ),
                  // 4️⃣ Focus
                  buildFeatureCard(
                    title: 'Focus Zone',
                    description: 'Stay focused and learn better',
                    emoji: '🎯',
                    startColor: const Color(0xFFE6E6FA),
                    endColor: const Color(0xFFDDA0DD),
                    onTap: () {
                      Navigator.pushNamed(context, '/focus');
                    },
                  ),
                  // 5️⃣ About
                  buildFeatureCard(
                    title: 'About LexiAid',
                    description: 'Learn more about our mission & team',
                    emoji: '💜',
                    startColor: const Color(0xFF9370DB),
                    endColor: const Color(0xFFDDA0DD),
                    onTap: () {
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                  // 6️⃣ Quiz Pro
                  buildFeatureCard(
                    title: 'Quiz Pro',
                    description: 'Challenge yourself & earn XP',
                    emoji: '🚀',
                    startColor: const Color(0xFF9370DB),
                    endColor: const Color(0xFFFF69B4),
                    onTap: () {
                      Navigator.pushNamed(context, '/quizPro');
                    },
                  ),

                  const SizedBox(height: 30),

                  // AI Bubble
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withAlpha(77),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      children: const [
                        Text('🤖', style: TextStyle(fontSize: 32)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Lexi says: You're doing amazing! Keep up the great work! 🌟",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
