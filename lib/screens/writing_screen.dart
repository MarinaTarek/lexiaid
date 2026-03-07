import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart'; // تأكدي المسار صح

class WritingScreen extends StatefulWidget {
  final String userName;
  const WritingScreen({super.key, this.userName = "Friend"});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _correctedController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final Random random = Random();

  bool isScanning = false;
  bool showAI = false;

  List<_Correction> corrections = [];

  int apiWordCount = 0;
  int apiCorrectWords = 0;
  int apiToFix = 0;
  double apiSimilarity = 0;

  @override
  void initState() {
    super.initState();
    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _fadeAnimation =
        Tween<double>(begin: 0.3, end: 0.7).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _correctedController.dispose();
    super.dispose();
  }

  Future<void> fetchCorrection() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      isScanning = true;
      showAI = true;
      corrections.clear();
      _correctedController.clear();
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.183.157:3000/correct"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final correctedText = data['correctedText'] ?? "";
        final apiCorrections = data['corrections'] ?? [];

        List<_Correction> found = [];
        for (var item in apiCorrections) {
          found.add(_Correction(item['text'], item['correction']));
        }

        setState(() {
          corrections = found;
          _correctedController.text = correctedText;

          apiWordCount = data['word_count'] ?? 0;
          apiCorrectWords = data['correct_words'] ?? 0;
          apiToFix = data['to_fix'] ?? 0;
          apiSimilarity = (data['similarity'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      setState(() {
        corrections = [_Correction("Error", "$e")];
      });
    } finally {
      setState(() => isScanning = false);
    }
  }

  Color getCorrectColor() {
    if (apiSimilarity >= 80) return Colors.green.shade600;
    if (apiSimilarity >= 50) return Colors.orange.shade700;
    return Colors.red.shade600;
  }

  Color getToFixColor() {
    if (apiSimilarity <= 20) return Colors.green.shade600;
    if (apiSimilarity <= 50) return Colors.orange.shade700;
    return Colors.red.shade600;
  }

  List<TextSpan> buildHighlightedText() {
    final words = _controller.text.trim().split(RegExp(r'\s+'));
    return words.map((w) {
      final correction = corrections.firstWhere(
            (c) => c.text == w,
        orElse: () => _Correction(w, w),
      );
      final isCorrected = correction.text != correction.correction;
      return TextSpan(
        text: '$w ',
        style: TextStyle(
          color: isCorrected ? Colors.red.shade700 : Colors.black87,
          fontWeight: isCorrected ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3F2FD),
                  Color(0xFF52A9E8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Animated floating circles
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main content scrollable
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header مع السهم في اليسار والنص في الوسط
                Row(
                  children: [
                    // السهم للعودة
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        },
                      ),
                    ),

                    // Spacer لإبعاد النص عن السهم
                    const SizedBox(width: 12),

                    // النص في المنتصف
                    Expanded(
                      child: Center(
                        child: Text(
                          'Hi, ${widget.userName} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B98E1),
                          ),
                        ),
                      ),
                    ),

                    // Spacer صغير على اليمين للتوازن
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 20),

                // باقي الصفحة: AI feedback + Writing box + Stats كما كانت
                if (showAI)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isScanning
                                ? 'Scanning your writing...'
                                : apiToFix == 0
                                ? 'Perfect! No errors found! 🌟'
                                : 'Found $apiToFix suggestion(s)! 🎯',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 16),
                          children: buildHighlightedText(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: "Start writing here...",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      if (_correctedController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Corrected Version ✨",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _correctedController,
                                readOnly: true,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFACACF3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: fetchCorrection,
                  child: Text(isScanning ? "Scanning..." : "Check Writing"),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: '📝',
                      label: 'Words',
                      value: apiWordCount.toString(),
                      color: Colors.purple.shade600,
                    ),
                    _StatItem(
                      icon: '✅',
                      label: 'Correct',
                      value:
                      "$apiCorrectWords (${apiSimilarity.toStringAsFixed(0)}%)",
                      color: getCorrectColor(),
                    ),
                    _StatItem(
                      icon: '⚡',
                      label: 'To Fix',
                      value:
                      "$apiToFix (${(100 - apiSimilarity).toStringAsFixed(0)}%)",
                      color: getToFixColor(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}