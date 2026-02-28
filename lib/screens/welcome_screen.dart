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
  final TextEditingController _controller = TextEditingController();
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
    _controller.dispose();
    super.dispose();
  }

  void handleStart() {
    if (_controller.text.trim().isNotEmpty) {
      Navigator.pushReplacementNamed(
        context,
        "/home",
        arguments: _controller.text.trim(),
      );
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
            colors: [
              Color(0xFFE6E6FA),
              Color(0xFFB0E0E6),
              Color(0xFF98FB98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ⭐ Floating stars
            ...List.generate(20, (index) {
              final random = Random();
              return Positioned(
                left: random.nextDouble() * screenWidth,
                top: random.nextDouble() * screenHeight,
                child: FadeTransition(
                  opacity: _animationController,
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFFF7F7F),
                    size: 16,
                  ),
                ),
              );
            }),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // ✨ 3D Animated Carousel
                    const SizedBox(
                      height: 400,
                      child: Carousel3D(),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Learn, try, and improve… your adventure starts now!✨",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6B5B95),
                      ),
                    ),

                    const SizedBox(height: 40),

                    TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: "What's your name?",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                              color: Color(0xFFE6E6FA), width: 3),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: handleStart,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF7F7F),
                              Color(0xFFFFB6C1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Start Learning! ✨",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      "Made with ❤️ for young learners",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B5B95),
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 500,
                    ),
                    child: Image.asset(
                      loopedImages[index],
                      fit: BoxFit.contain,
                    ),
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
