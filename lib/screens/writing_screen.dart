import 'package:flutter/material.dart';
import 'dart:math';

class WritingScreen extends StatefulWidget {
  final String userName; // اسم المستخدم يأتي من الشاشة السابقة
  const WritingScreen({super.key, this.userName = "Friend"});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final Random random = Random();
  bool isScanning = false;
  bool showAI = false;
  List<_Correction> corrections = [];

  @override
  void initState() {
    super.initState();
    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    // Tween لضمان ان الـ opacity دائما بين 0 و 1
    _fadeAnimation = Tween<double>(begin: 0.3, end: 0.7)
        .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void simulateDetection() {
    setState(() {
      isScanning = true;
      showAI = true;
      corrections.clear();
    });

    Future.delayed(const Duration(seconds: 2), () {
      final text = _controller.text;
      final List<_Correction> found = [];
      if (text.contains('teh')) {
        found.add(_Correction('teh', 'the'));
      }
      if (text.contains('dont')) {
        found.add(_Correction('dont', "don't"));
      }
      setState(() {
        corrections = found;
        isScanning = false;
      });
    });
  }

  int get wordCount => _controller.text.trim().isEmpty
      ? 0
      : _controller.text.trim().split(RegExp(r'\s+')).length;

  int get correctWords => max(0, wordCount - corrections.length);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Floating sparkles
          ...List.generate(6, (i) {
            final dx = random.nextDouble() * screenSize.width;
            final dy = random.nextDouble() * screenSize.height;
            return AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (_, child) {
                return Positioned(
                  left: dx,
                  top: dy + sin(_animationController.value * 2 * pi) * 20,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 50),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Writing Detective',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),

                // Welcome message with user's name
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hi, ${widget.userName} 👋',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 16),

                // AI Assistant Box
                if (showAI)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.pink.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8))
                        ]),
                    child: Row(
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lexi is checking...',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isScanning
                                    ? 'Scanning your writing for improvements! ✨'
                                    : corrections.isEmpty
                                    ? 'Perfect! No errors found! 🌟'
                                    : 'Found ${corrections.length} suggestion${corrections.length != 1 ? 's' : ''}! 🎯',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Writing Area
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _controller,
                          maxLines: 8,
                          decoration: InputDecoration(
                              hintText:
                              "Start writing here... Try typing: 'teh cat dont like water'",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                BorderSide(color: Colors.pink.shade200),
                              ),
                              filled: true,
                              fillColor: Colors.white),
                        ),
                        if (corrections.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.yellow[100],
                                borderRadius: BorderRadius.circular(20),
                                border:
                                Border.all(color: Colors.yellow.shade700)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: corrections
                                  .map((c) => Text('${c.text} → ${c.correction}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _controller.text.trim().isEmpty || isScanning
                            ? null
                            : simulateDetection,
                        icon: isScanning
                            ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                            : const Icon(Icons.check_circle),
                        label:
                        Text(isScanning ? 'Scanning...' : 'Check Writing'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Scan Paper'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent.shade100,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                        icon: '📝',
                        label: 'Words',
                        value: wordCount.toString(),
                        color: Colors.pink),
                    _StatItem(
                        icon: '✅',
                        label: 'Correct',
                        value: correctWords.toString(),
                        color: Colors.green),
                    _StatItem(
                        icon: '⚡',
                        label: 'To Fix',
                        value: corrections.length.toString(),
                        color: Colors.amber),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Correction {
  final String text;
  final String correction;
  _Correction(this.text, this.correction);
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
