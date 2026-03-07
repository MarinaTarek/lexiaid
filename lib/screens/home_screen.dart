import 'dart:math';
import 'package:flutter/material.dart';
import 'streak_service.dart';
import 'custom_taskbar.dart';
import 'profile_screen.dart';
import 'SelectQuestionCountScreen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, this.userName = "Friend"});

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
        if (!snapshot.hasData) return const SizedBox();

        int streak = snapshot.data![0] as int;
        int points = snapshot.data![1] as int;

        return Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text("🔥", style: TextStyle(fontSize: 20)),
                        SizedBox(width: 6),
                        Text(
                          "STREAK",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$streak Day",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text("⭐", style: TextStyle(fontSize: 20)),
                        SizedBox(width: 6),
                        Text(
                          "TOTAL XP",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$points Points",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: startColor.withAlpha(77),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
      bottomNavigationBar: CustomTaskBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, "/chat");
          if (index == 2) Navigator.pushNamed(context, "/progress");
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(userName: widget.userName),
              ),
            );
          }
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      getGreeting(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildStreakBox(),
                    const SizedBox(height: 20),
                    const Text(
                      "Main Hub",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Pick your next challenge",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: buildFeatureCard(
                                title: 'Reading Tracker',
                                description: 'Track and improve your reading',
                                emoji: '📚',
                                startColor: const Color(0xFFFFD54F),
                                endColor: const Color(0xFFFFB74D),
                                onTap: () => Navigator.pushNamed(context, '/writing'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildFeatureCard(
                                title: 'Writing Detective',
                                description: 'Get instant help with your writing',
                                emoji: '✍️',
                                startColor: const Color(0xFF81C784),
                                endColor: const Color(0xFF4CAF50),
                                onTap: () => Navigator.pushNamed(context, '/writingWriting'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: buildFeatureCard(
                                title: 'AI Speaking Practice',
                                description: 'Practice speaking and get feedback from AI',
                                emoji: '🗣️',
                                startColor: const Color(0xFFBA68C8),
                                endColor: const Color(0xFF8E24AA),
                                onTap: () => Navigator.pushNamed(context, '/ai'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildFeatureCard(
                                title: 'AI Chat',
                                description: 'Talk with Lexi AI assistant',
                                emoji: '💬',
                                startColor: const Color(0xFF4FC3F7),
                                endColor: const Color(0xFF0288D1),
                                onTap: () => Navigator.pushNamed(context, '/chat'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: buildFeatureCard(
                                title: 'Focus Zone',
                                description: 'Stay focused and learn better',
                                emoji: '🎯',
                                startColor: const Color(0xFFFF8A65),
                                endColor: const Color(0xFFFF7043),
                                onTap: () => Navigator.pushNamed(context, '/focus'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildFeatureCard(
                                title: 'Quiz Pro',
                                description: 'Challenge yourself & earn XP',
                                emoji: '🏆',
                                startColor: const Color(0xFFF06292),
                                endColor: const Color(0xFFE91E63),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SelectQuestionCountScreen(),
                                    ),
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: buildFeatureCard(
                                title: 'My Progress',
                                description: "See how much you've grown",
                                emoji: '📈',
                                startColor: const Color(0xFF4DB6AC),
                                endColor: const Color(0xFF00897B),
                                onTap: () => Navigator.pushNamed(context, '/progress'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildFeatureCard(
                                title: 'About LexiAid',
                                description: 'Learn about our mission & team',
                                emoji: '💡',
                                startColor: const Color(0xFFBA68C8),
                                endColor: const Color(0xFF7B1FA2),
                                onTap: () => Navigator.pushNamed(context, '/about'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}