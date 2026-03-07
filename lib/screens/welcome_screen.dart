import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void handleStart() {
    Navigator.pushReplacementNamed(
      context,
      "/home",
      arguments: "Friend",
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD), // أزرق فاتح
              Color(0xFFBBDEFB), // أزرق أفتح شوي
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // النجوم المتحركة
            ...List.generate(20, (index) {
              final random = Random();
              return Positioned(
                left: random.nextDouble() * screenWidth,
                top: random.nextDouble() * screenHeight,
                child: FadeTransition(
                  opacity: _animationController,
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF2196F3), // أزرق متناسق مع الزرار
                    size: 18,
                  ),
                ),
              );
            }),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 350,
                      child: Carousel3D(),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Welcome! 🌈",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Your learning journey starts here!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3), // أزرق متناسق
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        onPressed: handleStart,
                        child: const Text(
                          "Start Learning",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      "Made with 💜 for learners",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
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

// ========================
// 3D Carousel
// ========================
class Carousel3D extends StatefulWidget {
  const Carousel3D({super.key});

  @override
  State<Carousel3D> createState() => _Carousel3DState();
}

class _Carousel3DState extends State<Carousel3D> {
  late PageController _controller;
  late Timer _timer;

  final List<String> images = [
    'assets/images/avatar9.png',
    'assets/images/avatar8.png',
    'assets/images/avatar11.png',
    'assets/images/avatar10.png',
    'assets/images/avatar5.png',
    'assets/images/avatar6.png',
    'assets/images/avatar7.png',
    'assets/images/avatar2.png',
    'assets/images/avatar12.png',
    'assets/images/avatar4.png',
    'assets/images/avatar3.png',
    'assets/images/avatar.png',
  ];

  late List<String> loopedImages;

  @override
  void initState() {
    super.initState();

    loopedImages = [...images, ...images];

    _controller = PageController(
      viewportFraction: 0.55,
      initialPage: images.length,
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_controller.hasClients) {
        int nextPage = _controller.page!.toInt() + 1;

        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: loopedImages.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double value = 0.0;

            if (_controller.position.haveDimensions) {
              value = _controller.page! - index;
            }

            double angle = value * 0.5;
            double scale = (1 - value.abs() * 0.3).clamp(0.7, 1.0);

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: Transform.scale(
                scale: scale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    loopedImages[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}